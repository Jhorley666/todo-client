import 'package:flutter/material.dart';
import '../models/category_model.dart';

class CategoryListView extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel) onEdit;
  final void Function(CategoryModel) onDelete;

  const CategoryListView({
    super.key,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No hay categorías disponibles'));
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Dismissible(
          key: ValueKey(category.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(category),
          child: ListTile(
            title: Text(category.name),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(category),
            ),
          ),
        );
      },
    );
  }
}