import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryController {
  final CategoryService _categoryService = CategoryService();

  Future<List<CategoryModel>> fetchCategories() {
    return _categoryService.fetchCategories();
  }

  Future<void> addCategory(String name) {
    return _categoryService.addCategory(name);
  }

  Future<void> updateCategory(int id, String name) {
    return _categoryService.updateCategory(id, name);
  }

  Future<void> deleteCategory(int id) {
    return _categoryService.deleteCategory(id);
  }
}