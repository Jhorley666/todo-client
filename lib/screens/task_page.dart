import 'dart:async';
import 'package:flutter/material.dart';
import 'package:todo_client/controllers/category_controller.dart';
import '../models/task_model.dart';
import '../models/task_status_model.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_status_controller.dart';
import '../controllers/priority_controller.dart';
import '../controllers/task_time_priority_controller.dart';
import '../services/category_service.dart';
import '../services/priority_service.dart';
import '../widgets/task_widgets/task_list_view.dart';
import '../widgets/task_widgets/task_form_dialog.dart';
import '../widgets/utils_widgets/delete_confirmation_dialog.dart';
import '../widgets/utils_widgets/task_progress_widget.dart';
import '../widgets/utils_widgets/task_timer_widget.dart';
import '../models/task_statistics_model.dart';
import '../layouts/base_layout.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskController _taskController = TaskController();
  final CategoryController _categoryController = CategoryController();
  final TaskStatusController _taskStatusController = TaskStatusController();
  final PriorityController _priorityController = PriorityController();
  final TaskTimePriorityController _taskTimePriorityController = TaskTimePriorityController();

  late Future<List<TaskModel>> _tasksFuture;
  late Future<TaskStatistics> _taskStatisticsFuture;
  Duration _totalTimerDuration = Duration.zero;
  final List<int> _processedCompletedTaskIds = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadTaskStatistics();
    _calculateTotalDuration();
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
    final priorities = await _priorityController.fetchPriorities();

    final categoryMap = {
      for (var category in categories) category.id: category.name
    };

    final priorityMap = {
      for (var priority in priorities) priority.priorityId: priority.priorityName
    };

    for (var task in tasks) {
      task.categoryName = categoryMap[task.categoryId] ?? 'Unknown';
      task.priorityName = priorityMap[task.priorityId] ?? 'Unknown';
    }

    // Calculate total duration after loading tasks
    _calculateTotalDuration();
    
    return tasks;
  }

  Future<void> _calculateTotalDuration() async {
    try {
      final tasks = await _taskController.fetchTasks();
      final statuses = await _taskStatusController.fetchTaskStatuses();
      
      // Find the "Completed" or "Done" status ID (case-insensitive)
      final completedStatus = statuses.firstWhere(
        (status) => status.name.toLowerCase() == 'completed' || 
                    status.name.toLowerCase() == 'done',
        orElse: () => statuses.first, // fallback to first status if not found
      );

      Duration totalDuration = Duration.zero;
      _processedCompletedTaskIds.clear();

      for (var task in tasks) {
        if (task.statusId == completedStatus.id && 
            !_processedCompletedTaskIds.contains(task.taskId)) {
          try {
            final taskTimePriority = await _taskTimePriorityController
                .getTaskTimePriorityByPriorityId(task.priorityId);
            
            // The time field is now in milliseconds
            final duration = Duration(milliseconds: taskTimePriority.time);
            
            totalDuration += duration;
            _processedCompletedTaskIds.add(task.taskId);
          } catch (e) {
            // If task time priority not found, skip this task
            debugPrint('Error fetching task time priority for task ${task.taskId}: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalTimerDuration = totalDuration;
        });
      }
    } catch (e) {
      debugPrint('Error calculating total duration: $e');
    }
  }

  Future<void> _handleTaskStatusUpdate(
    TaskModel? oldTask,
    int newStatusId,
    int priorityId,
  ) async {
    try {
      final statuses = await _taskStatusController.fetchTaskStatuses();
      final completedStatus = statuses.firstWhere(
        (status) => status.name.toLowerCase() == 'completed' || 
                    status.name.toLowerCase() == 'done',
        orElse: () => statuses.first,
      );

      // Check if task status changed to "done"
      if (newStatusId == completedStatus.id) {
        int? taskIdToProcess;
        
        if (oldTask != null) {
          // For updates, use the old task ID
          taskIdToProcess = oldTask.taskId;
        } else {
          // For new tasks, get the latest task ID
          final tasks = await _taskController.fetchTasks();
          if (tasks.isNotEmpty) {
            // Get the most recently created task (assuming it's the one just added)
            tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            taskIdToProcess = tasks.first.taskId;
          }
        }

        if (taskIdToProcess != null && 
            !_processedCompletedTaskIds.contains(taskIdToProcess)) {
          try {
            final taskTimePriority = await _taskTimePriorityController
                .getTaskTimePriorityByPriorityId(priorityId);
            
            final duration = Duration(milliseconds: taskTimePriority.time);

            if (mounted) {
              final int processedTaskId = taskIdToProcess;
              setState(() {
                _totalTimerDuration += duration;
                _processedCompletedTaskIds.add(processedTaskId);
              });
            }
          } catch (e) {
            debugPrint('Error fetching task time priority: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling task status update: $e');
    }
  } 
  
  void _editTask(TaskModel task) {
    _showTaskFormDialog(task: task);
  }

  Future<void> _deleteTask(TaskModel task) async {
    await _taskController.deleteTask(task.taskId);
    _loadTasks();
    _loadTaskStatistics();
  }

  Future<void> _updateTaskStatus(TaskModel task, int newStatusId) async {
    try {
      final oldStatusId = task.statusId;
      if (oldStatusId == newStatusId) return;

      await _taskController.updateTask(
        id: task.taskId,
        title: task.title,
        description: task.description ?? '',
        priorityId: task.priorityId,
        categoryId: task.categoryId ?? 0,
        statusId: newStatusId,
        dueDate: task.dueDate ?? DateTime.now(),
      );
      
      await _handleTaskStatusUpdate(task, newStatusId, task.priorityId);
      _loadTasks();
      _loadTaskStatistics();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
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

      // 3. Obtener prioridades del servicio
      final priorities = await PriorityService().fetchPriorities();

      // 4. Convertir a DropdownMenuItem<int>
      final priorityItems = priorities
          .map((priority) => DropdownMenuItem<int>(
                value: priority.priorityId,
                child: Text(
                  priority.priorityName,
                  overflow: TextOverflow.visible,
                  maxLines: null,
                ),
              ))
          .toList();

      // 5. Obtener estados de tareas del servicio
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
          priorityItems: priorityItems,
          taskStatuses: taskStatuses,
          onSubmit: ({
            required String title,
            required String description,
            required int priorityId,
            required int categoryId,
            required int statusId,
            required DateTime dueDate,
          }) async {
            final oldStatusId = task?.statusId;
            if (task == null) {
              await _taskController.addTask(
                title: title,
                description: description,
                priorityId: priorityId,
                categoryId: categoryId,
                statusId: statusId,
                dueDate: dueDate,
              );
              // If new task is created with "done" status, handle it
              await _handleTaskStatusUpdate(null, statusId, priorityId);
            } else {
              await _taskController.updateTask(
                id: task.taskId,
                title: title,
                description: description,
                priorityId: priorityId,
                categoryId: categoryId,
                statusId: statusId,
                dueDate: dueDate,
              );
              // Check if status changed to done
              if (oldStatusId != statusId) {
                await _handleTaskStatusUpdate(task, statusId, priorityId);
              }
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
    return BaseLayout(
      title: "Tasks",
      child: Scaffold(
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
            // Timer widget section
            TaskTimerWidget(
              totalDuration: _totalTimerDuration,
              onTimerComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Timer completed!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
                      onStatusChange: _updateTaskStatus,
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTaskFormDialog(),
          child: const Icon(Icons.add),
        ),
      )
    );
  }
}