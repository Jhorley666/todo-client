import 'package:flutter/material.dart';
import '../../models/category_model.dart';

class CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;
  final void Function(String name) onSubmit;

  const CategoryFormDialog({
    super.key,
    this.category,
    required this.onSubmit,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Nueva Categoría' : 'Editar Categoría'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: (v) => v == null || v.isEmpty ? 'Ingrese un nombre' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(_nameController.text);
              Navigator.pop(context);
            }
          },
          child: Text(widget.category == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}