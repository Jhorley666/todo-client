import '../models/task_status_model.dart';
import 'base_http_service.dart';

class TaskStatusService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<List<TaskStatusModel>> fetchTaskStatuses() async {
    try {
      final response = await _httpService.get('/status');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskStatusModel.fromJson(json)).toList();
    } catch (e) {
      // Include the actual error message for debugging
      throw Exception('Error al obtener los estados de las tareas: ${e.toString()}');
    }
  }
}