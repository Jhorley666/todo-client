import 'package:intl/intl.dart';
import '../models/category_model.dart';
import 'base_http_service.dart';

class CategoryService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response = await _httpService.get('/categories/$id');
      return CategoryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener la categoría');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _httpService.get('/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener categorías');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);
      await _httpService.post(
        '/categories',
        data: {'name': name, 'createdAt': formattedDate},
      );
    } catch (e) {
      throw Exception('Error al agregar categoría');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _httpService.delete('/categories/$id');
    } catch (e) {
      throw Exception('Error al eliminar categoría');
    }
  }

  Future<void> updateCategory(int id, String name) async {
    try {
      await _httpService.put(
        '/categories/$id',
        data: {'name': name},
      );
    } catch (e) {
      throw Exception('Error al actualizar categoría');
    }
  }
}