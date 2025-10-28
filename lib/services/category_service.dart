import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/category_model.dart';


class CategoryService {
  static const String baseUrl = 'http://192.168.100.9:8587/api/v1/categories';
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}' ,
    };
  }

  Future<CategoryModel> getCategoryById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Error al obtener la categoría');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener categorías');
    }
  }

  Future<void> addCategory(String name) async {
    final headers = await _getHeaders();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);
    await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: json.encode({'name': name, 'createdAt': formattedDate}),
    );
  }

  Future<void> deleteCategory(int id) async {
    final headers = await _getHeaders();
    await http.delete(Uri.parse('$baseUrl/$id'), headers: headers);
  }

  Future<void> updateCategory(int id, String name) async {
    final headers = await _getHeaders();
    await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
      body: json.encode({'name': name}),
    );
  }

}