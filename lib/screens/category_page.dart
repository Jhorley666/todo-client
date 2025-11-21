import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../controllers/category_controller.dart';
import '../widgets/category_widgets/category_list_view.dart';
import '../widgets/category_widgets/category_form_dialog.dart';
import '../widgets/utils_widgets/delete_confirmation_dialog.dart';
import '../layouts/base_layout.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryController _controller = CategoryController();
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    setState(() {
      _categoriesFuture = _controller.fetchCategories();
    });
  }

  Future<void> _showCategoryFormDialog({CategoryModel? category}) async {
    await showDialog(
      context: context,
      builder: (context) => CategoryFormDialog(
        category: category,
        onSubmit: (name) async {
          if (category == null) {
            await _controller.addCategory(name);
          } else {
            await _controller.updateCategory(category.id, name);
          }
          _loadCategories();
        },
      ),
    );
  }

  void _editCategory(CategoryModel category) {
    _showCategoryFormDialog(category: category);
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    await _controller.deleteCategory(category.id);
    _loadCategories();
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return DeleteConfirmationDialog.show(
      context,
      entityName: 'category',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: "Categories",
      child: Scaffold(
        body: FutureBuilder<List<CategoryModel>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay categorías disponibles'));
            } else {
              return CategoryListView(
                categories: snapshot.data!,
                onEdit: _editCategory,
                onDelete: _deleteCategory,
                showDeleteConfirmationDialog: _showDeleteConfirmationDialog,
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCategoryFormDialog(),
          child: const Icon(Icons.add),
        ),
      )
    );
  }
}