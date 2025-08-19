import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskService {
  static const String baseUrl = 'http://192.168.100.9:8587/api/v1/tasks';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}' ,
    };
  }

  Future<List<TaskModel>> fetchTasks() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener tareas');
    }
  }

  Future<void> addTask(String title, String description, String priority, 
  int categoryId, int statusId, DateTime dueDate) async {
    final headers = await _getHeaders();
        final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
    final nowFormattedDate = DateFormat('yyyy-MM-dd').format(now);
    await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'title': title, 'description': description, 
      'priority': priority, 'categoryId': categoryId, 'statusId': statusId, 
      'createdAt': nowFormattedDate,
      'updatedAt': nowFormattedDate,
      'dueDate': formattedDate}),
    );
  }

  Future<void> deleteTask(int id) async {
    final headers = await _getHeaders();
    await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
  }

  Future<void> toggleTask(int id, bool completed) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: json.encode({'completed': completed}),
    );
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
    final headers = await _getHeaders();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(dueDate);
    final nowFormattedDate = DateFormat('yyyy-MM-dd').format(now);
    await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: json.encode({
        'title': title,
        'description': description,
        'priority': priority,
        'categoryId': categoryId,
        'statusId': statusId,
        'dueDate': formattedDate,
        'updatedAt': nowFormattedDate,
      }),
    );
  }
}
