import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_status_model.dart';

class TaskStatusService {
  static const String baseUrl = 'http://192.168.100.9:8587/api/v1/status';
  
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}' ,
    };
  }

  Future<List<TaskStatusModel>> fetchTaskStatuses() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TaskStatusModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los estados de las tareas');
    }
  }

}