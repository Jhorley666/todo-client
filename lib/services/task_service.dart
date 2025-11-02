import '../models/task_model.dart';
import 'package:intl/intl.dart';
import 'base_http_service.dart';

class TaskService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<List<TaskModel>> fetchTasks() async {
    try {
      final response = await _httpService.get('/tasks');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener tareas');
    }
  }

  Future<void> addTask(String title, String description, String priority, 
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
          'priority': priority, 
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
    String priority,
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
          'priority': priority,
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
}
