import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/task_status_model.dart';

class TaskFormDialog extends StatefulWidget {
  final TaskModel? task;
  final List<DropdownMenuItem<int>> categoryItems;
  final List<TaskStatusModel> taskStatuses;
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
    required this.taskStatuses,
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
  late TaskStatusModel? _selectedStatus;
  late DateTime _dueDate;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.task != null;
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

    // Initialize status: For new tasks, default to 'Pending'; for editing, use task's status
    if (_isEditing && widget.task != null) {
      // Find the status that matches the task's statusId
      _selectedStatus = widget.taskStatuses.firstWhere(
        (status) => status.id == widget.task!.statusId,
        orElse: () => widget.taskStatuses.first,
      );
    } else {
      // For new tasks, find 'Pending' status
      _selectedStatus = widget.taskStatuses.firstWhere(
        (status) => status.name.toLowerCase() == 'pending',
        orElse: () => widget.taskStatuses.isNotEmpty ? widget.taskStatuses.first : throw StateError('No task statuses available'),
      );
    }

    _dueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
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
                itemHeight: null,
                onChanged: (v) => setState(() => _categoryId = v),
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (v) => v == null ? 'Seleccione una categoría' : null,
                isExpanded: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Estado',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...widget.taskStatuses.map((status) {
                return RadioListTile<TaskStatusModel>(
                  title: Text(status.name),
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: _isEditing ? (TaskStatusModel? value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  } : null, // Disable for new tasks
                );
              }).toList(),
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
            if (_formKey.currentState!.validate() && _selectedStatus != null) {
              // Convert TaskStatusModel.id (String) to int for statusId
              final statusId = _selectedStatus!.id ?? 1;
              widget.onSubmit(
                title: _titleController.text,
                description: _descController.text,
                priority: _priority,
                categoryId: _categoryId!,
                statusId: statusId,
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