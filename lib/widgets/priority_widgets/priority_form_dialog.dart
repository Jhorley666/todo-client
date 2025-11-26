import 'package:flutter/material.dart';
import '../../models/priority_model.dart';

class PriorityFormDialog extends StatefulWidget {
  final PriorityModel? priority;
  final Future<void> Function(String name) onSubmit;

  const PriorityFormDialog({
    super.key,
    this.priority,
    required this.onSubmit,
  });

  @override
  State<PriorityFormDialog> createState() => _PriorityFormDialogState();
}

class _PriorityFormDialogState extends State<PriorityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.priority?.priorityName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final name = _nameController.text.trim();
    await widget.onSubmit(name);
    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.priority == null ? 'New Priority' : 'Edit Priority'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(widget.priority == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}