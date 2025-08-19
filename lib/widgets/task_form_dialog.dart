import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskFormDialog extends StatefulWidget {
  final TaskModel? task;
  final List<DropdownMenuItem<int>> categoryItems;
  final void Function({
    required String title,
    required String description,
    required String priority,
    required int categoryId,
    required int statusId,
    required DateTime dueDate,
  }) onSubmit;

  const TaskFormDialog({
    super.key,
    this.task,
    required this.categoryItems,
    required this.onSubmit,
  });

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String _priority;
  late int? _categoryId;
  late int _statusId;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority.name ?? 'Low';

    // Obtén todos los valores posibles de categoría
    final categoryValues = widget.categoryItems.map((item) => item.value).toList();

    // Si la categoría de la tarea existe en la lista, úsala; si no, usa la primera o null
    if (widget.task?.categoryId != null && categoryValues.contains(widget.task!.categoryId)) {
      _categoryId = widget.task!.categoryId;
    } else if (categoryValues.isNotEmpty) {
      _categoryId = categoryValues.first;
    } else {
      _categoryId = null;
    }

    _statusId = widget.task?.statusId ?? 1;
    _dueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Nueva Tarea' : 'Editar Tarea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v == null || v.isEmpty ? 'Ingrese un título' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Low', 'Medium', 'High']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
                decoration: const InputDecoration(labelText: 'Prioridad'),
              ),
              DropdownButtonFormField<int>(
                value: _categoryId,
                items: widget.categoryItems,
                onChanged: (v) => setState(() => _categoryId = v),
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (v) => v == null ? 'Seleccione una categoría' : null,
              ),
              TextFormField(
                initialValue: _statusId.toString(),
                decoration: const InputDecoration(labelText: 'ID Estado'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _statusId = int.tryParse(v) ?? 1,
              ),
              ListTile(
                title: Text('Fecha límite: ${_dueDate.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
            ],
          ),
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
              widget.onSubmit(
                title: _titleController.text,
                description: _descController.text,
                priority: _priority,
                categoryId: _categoryId!,
                statusId: _statusId,
                dueDate: _dueDate,
              );
              Navigator.pop(context);
            }
          },
          child: Text(widget.task == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}