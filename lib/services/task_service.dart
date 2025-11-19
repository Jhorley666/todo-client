import '../models/task_model.dart';
import '../models/task_statistics_model.dart';
import '../models/task_status_model.dart';
import 'package:intl/intl.dart';
import 'base_http_service.dart';
import 'task_status_service.dart';

class TaskService {
  final BaseHttpService _httpService = BaseHttpService();
  final TaskStatusService _taskStatusService = TaskStatusService();

  Future<List<TaskModel>> fetchTasks() async {
    try {
      final response = await _httpService.get('/tasks');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas');
    }
  }

  Future<void> addTask(String title, String description, int priorityId, 
  int categoryId, int statusId, DateTime dueDate) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
      final nowFormattedDate = DateFormat('yyyy-MM-dd').format(now);
      await _httpService.post(
        '/tasks',
        data: {
          'title': title, 
          'description': description, 
          'priorityId': priorityId, 
          'categoryId': categoryId, 
          'statusId': statusId, 
          'createdAt': nowFormattedDate,
          'updatedAt': nowFormattedDate,
          'dueDate': formattedDate
        },
      );
    } catch (e) {
      throw Exception('Error al agregar tarea');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _httpService.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Error al eliminar tarea');
    }
  }

  Future<void> toggleTask(int id, bool completed) async {
    try {
      await _httpService.put(
        '/tasks/$id',
        data: {'completed': completed},
      );
    } catch (e) {
      throw Exception('Error al actualizar estado de tarea');
    }
  }

  Future<void> updateTask(
    int id,
    String title,
    String description,
    int priorityId,
    int categoryId,
    int statusId,
    DateTime dueDate,
  ) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
      final nowFormattedDate = DateFormat('yyyy-MM-dd').format(now);
      await _httpService.put(
        '/tasks/$id',
        data: {
          'title': title,
          'description': description,
          'priorityId': priorityId,
          'categoryId': categoryId,
          'statusId': statusId,
          'dueDate': formattedDate,
          'updatedAt': nowFormattedDate,
        },
      );
    } catch (e) {
      throw Exception('Error al actualizar tarea');
    }
  }

  /// Fetches task statistics including total tasks and completed tasks count
  /// A task is considered completed if its status name is "Completed" (case-insensitive)
  Future<TaskStatistics> fetchTaskStatistics() async {
    try {
      // Fetch all tasks and statuses in parallel
      final tasksFuture = fetchTasks();
      final statusesFuture = _taskStatusService.fetchTaskStatuses();
      
      final tasks = await tasksFuture;
      final statuses = await statusesFuture;
      
      // Find the "Completed" status ID (case-insensitive)
      final completedStatusList = statuses.where(
        (status) => status.name.toLowerCase() == 'completed',
      ).toList();
      
      // If no "Completed" status exists, return statistics with 0 completed
      if (completedStatusList.isEmpty) {
        return TaskStatistics(
          totalTasks: tasks.length,
          completedTasks: 0,
        );
      }
      
      final completedStatusId = completedStatusList.first.id;
      
      // Count completed tasks
      final completedCount = tasks.where(
        (task) => task.statusId == completedStatusId,
      ).length;
      
      return TaskStatistics(
        totalTasks: tasks.length,
        completedTasks: completedCount,
      );
    } catch (e) {
      throw Exception('Error al obtener estadísticas de tareas: ${e.toString()}');
    }
  }
}
