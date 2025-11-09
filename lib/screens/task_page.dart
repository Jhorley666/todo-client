import 'package:flutter/material.dart';
import 'package:todo_client/controllers/category_controller.dart';
import '../models/task_model.dart';
import '../models/task_status_model.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_status_controller.dart';
import '../services/category_service.dart';
import '../widgets/task_widgets/task_list_view.dart';
import '../widgets/task_widgets/task_form_dialog.dart';
import '../widgets/utils_widgets/delete_confirmation_dialog.dart';
import '../widgets/utils_widgets/task_progress_widget.dart';
import '../models/task_statistics_model.dart';
import 'category_page.dart'; // Asegúrate de importar la página de categorías

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskController _taskController = TaskController();
  final CategoryController _categoryController = CategoryController();
  final TaskStatusController _taskStatusController = TaskStatusController();

  late Future<List<TaskModel>> _tasksFuture;
  late Future<TaskStatistics> _taskStatisticsFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTaskStatistics();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = _loadTasksWithCategoryNames();
    });
  }

  void _loadTaskStatistics() {
    setState(() {
      _taskStatisticsFuture = _taskController.fetchTaskStatistics();
    });
  }

  Future<List<TaskModel>> _loadTasksWithCategoryNames() async {
    final tasks = await _taskController.fetchTasks();
    final categories = await _categoryController.fetchCategories();

    final categoryMap = {
      for (var category in categories) category.id: category.name
    };

    for (var task in tasks) {
      task.categoryName = categoryMap[task.categoryId] ?? 'Unknown';
    }

    return tasks;
  } 
  
  void _editTask(TaskModel task) {
    _showTaskFormDialog(task: task);
  }

  Future<void> _deleteTask(TaskModel task) async {
    await _taskController.deleteTask(task.taskId);
    _loadTasks();
    _loadTaskStatistics();
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return DeleteConfirmationDialog.show(
      context,
      entityName: 'task',
    );
  }

  Future<void> _showTaskFormDialog({TaskModel? task}) async {
    try {
      // 1. Obtener categorías del servicio
      final categories = await CategoryService().fetchCategories();

      // 2. Convertir a DropdownMenuItem<int>
      final categoryItems = categories
          .map((cat) => DropdownMenuItem<int>(
                value: cat.id,
                child: Text(
                  cat.name,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                ),
              ))
          .toList();

      // 3. Obtener estados de tareas del servicio
      List<TaskStatusModel> taskStatuses;
      try {
        taskStatuses = await _taskStatusController.fetchTaskStatuses();
      } catch (e) {
        // Show error dialog if statuses can't be fetched
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('No se pudieron cargar los estados de las tareas.\n\nError: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => TaskFormDialog(
          task: task,
          categoryItems: categoryItems,
          taskStatuses: taskStatuses,
          onSubmit: ({
            required String title,
            required String description,
            required String priority,
            required int categoryId,
            required int statusId,
            required DateTime dueDate,
          }) async {
            if (task == null) {
              await _taskController.addTask(
                title: title,
                description: description,
                priority: priority,
                categoryId: categoryId,
                statusId: statusId,
                dueDate: dueDate,
              );
            } else {
              await _taskController.updateTask(
                id: task.taskId,
                title: title,
                description: description,
                priority: priority,
                categoryId: categoryId,
                statusId: statusId,
                dueDate: dueDate,
              );
            }
            _loadTasks();
            _loadTaskStatistics();
          },
        ),
      );
    } catch (e) {
      // Handle any other errors
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error al abrir el formulario: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          // Progress widget section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Task Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TaskProgressWidgetWithStates(
                      statisticsFuture: _taskStatisticsFuture,
                      size: 120.0,
                      strokeWidth: 10.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Task list section
          Expanded(
            child: FutureBuilder<List<TaskModel>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tasks available'));
                } else {
                  return TaskListView(
                    tasks: snapshot.data!,
                    onEdit: _editTask,
                    onDelete: _deleteTask,
                    showDeleteConfirmationDialog: _showDeleteConfirmationDialog,
                  );
                }
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menú', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryPage()),
                );
              },
            ),
            // Puedes agregar más opciones aquí si lo deseas
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}