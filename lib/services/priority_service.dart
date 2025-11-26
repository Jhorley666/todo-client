import '../models/priority_model.dart';
import 'base_http_service.dart';

class PriorityService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<void> addPriority(String name) async {
    try {
      await _httpService.post(
        '/priorities',
        data: {'priorityName': name},
      );
    } catch (e) {
      throw Exception('Error al agregar prioridad');
    }
  }

  Future<List<PriorityModel>> fetchPriorities() async {
    try {
      final response = await _httpService.get('/priorities');
      final List<dynamic> data = response.data;
      return data.map((json) => PriorityModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener prioridades');
    }
  }

  Future<PriorityModel> getPriorityById(int id) async {
    try {
      final response = await _httpService.get('/priorities/$id');
      return PriorityModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener la prioridad');
    }
  }

  Future<void> updatePriority(int id, String priorityName) async {
    try {
      await _httpService.put(
        '/priorities/$id',
        data: {'priorityName': priorityName},
      );
    } catch (e) {
      throw Exception('Error al actualizar prioridad');
    }
  }

  Future<void> deletePriority(int id) async {
    try {
      await _httpService.delete('/priorities/$id');
    } catch (e) {
      throw Exception('Error al eliminar prioridad');
    }
  }
}

