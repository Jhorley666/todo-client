import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../controllers/task_controller.dart';
import '../services/category_service.dart';
import '../widgets/task_list_view.dart';
import '../widgets/task_form_dialog.dart';
import 'category_page.dart'; // Asegúrate de importar la página de categorías

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskController _controller = TaskController();
  late Future<List<TaskModel>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = _controller.fetchTasks();
    });
  }

  void _editTask(TaskModel task) {
    _showTaskFormDialog(task: task);
  }

  void _deleteTask(TaskModel task) async {
    await _controller.deleteTask(task.taskId);
    _loadTasks();
  }

  Future<void> _showTaskFormDialog({TaskModel? task}) async {
    // 1. Obtener categorías del servicio
    final categories = await CategoryService().fetchCategories();

    // 2. Convertir a DropdownMenuItem<int>
    final categoryItems = categories
        .map((cat) => DropdownMenuItem<int>(
              value: cat.id,
              child: Text(cat.name),
            ))
        .toList();

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => TaskFormDialog(
        task: task,
        categoryItems: categoryItems,
        onSubmit: ({
          required String title,
          required String description,
          required String priority,
          required int categoryId,
          required int statusId,
          required DateTime dueDate,
        }) async {
          if (task == null) {
            await _controller.addTask(
              title: title,
              description: description,
              priority: priority,
              categoryId: categoryId,
              statusId: statusId,
              dueDate: dueDate,
            );
          } else {
            await _controller.updateTask(
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: FutureBuilder<List<TaskModel>>(
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
            );
          }
        },
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