import '../models/task_time_priority_model.dart';
import 'base_http_service.dart';

class TaskTimePriorityService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<List<TaskTimePriorityModel>> fetchTaskTimePriorities() async {
    try {
      final response = await _httpService.get('/tasks-time-priority/user');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskTimePriorityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener las prioridades de tiempo de tareas');
    }
  }

  Future<TaskTimePriorityModel> getTaskTimePriorityById(int id) async {
    try {
      final response = await _httpService.get('/tasks-time-priority/$id');
      return TaskTimePriorityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener la prioridad de tiempo de tarea');
    }
  }

  Future<TaskTimePriorityModel> getTaskTimePriorityByPriorityId(int priorityId) async {
    try {
      final response = await _httpService.get('/tasks-time-priority/priority/$priorityId');
      return TaskTimePriorityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener la prioridad de tiempo por ID de prioridad');
    }
  }

  Future<void> updateTaskTimePriority(
    int id,
    int time,
    int priorityId,
  ) async {
    try {
      await _httpService.put(
        '/tasks-time-priority/$id',
        data: {
          'time': time,
          'priorityId': priorityId,
        },
      );
    } catch (e) {
      throw Exception('Error al actualizar la prioridad de tiempo de tarea');
    }
  }

  Future<void> createTaskTimePriority(
    int time,
    int priorityId,
  ) async {
    try {
      await _httpService.post(
        '/tasks-time-priority',
        data: {
          'time': time,
          'priorityId': priorityId,
        },
      );
    } catch (e) {
      throw Exception('Error al crear la prioridad de tiempo de tarea');
    }
  }

  Future<void> deleteTaskTimePriority(int id) async {
    try {
      await _httpService.delete('/tasks-time-priority/$id');
    } catch (e) {
      throw Exception('Error al eliminar la prioridad de tiempo de tarea');
    }
  }
}

