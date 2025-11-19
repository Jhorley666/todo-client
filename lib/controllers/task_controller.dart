import '../models/task_model.dart';
import '../models/task_statistics_model.dart';
import '../services/task_service.dart';

class TaskController {
  final TaskService _taskService = TaskService();

  Future<List<TaskModel>> fetchTasks() {
    return _taskService.fetchTasks();
  }

  Future<void> addTask({
    required String title,
    required String description,
    required int priorityId,
    required int categoryId,
    required int statusId,
    required DateTime dueDate,
  }) {
    return _taskService.addTask(
      title,
      description,
      priorityId,
      categoryId,
      statusId,
      dueDate,
    );
  }

  Future<void> updateTask({
    required int id,
    required String title,
    required String description,
    required int priorityId,
    required int categoryId,
    required int statusId,
    required DateTime dueDate,
  }) {
    return _taskService.updateTask(
      id,
      title,
      description,
      priorityId,
      categoryId,
      statusId,
      dueDate,
    );
  }

  Future<void> deleteTask(int id) {
    return _taskService.deleteTask(id);
  }

  Future<TaskStatistics> fetchTaskStatistics() {
    return _taskService.fetchTaskStatistics();
  }
}