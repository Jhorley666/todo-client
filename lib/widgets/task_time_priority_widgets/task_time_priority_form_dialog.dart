import 'package:flutter/material.dart';
import '../../models/task_time_priority_model.dart';

class TaskTimePriorityFormDialog extends StatefulWidget {
  final TaskTimePriorityModel? taskTimePriority;
  final List<DropdownMenuItem<int>> priorityItems;
  final Future<void> Function({
    required int time,
    required int priorityId,
  }) onSubmit;

  const TaskTimePriorityFormDialog({
    super.key,
    this.taskTimePriority,
    required this.priorityItems,
    required this.onSubmit,
  });

  @override
  State<TaskTimePriorityFormDialog> createState() => _TaskTimePriorityFormDialogState();
}

class _TaskTimePriorityFormDialogState extends State<TaskTimePriorityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedPriorityId;
  double _sliderValue = 60000; // Default 1 minute in ms
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskTimePriority != null) {
      _selectedPriorityId = widget.taskTimePriority!.priorityId;
      // Ensure the value is within the slider's range (1000 - 3600000)
      double value = widget.taskTimePriority!.time.toDouble();
      if (value < 1000) value = 1000;
      if (value > 3600000) value = 3600000;
      _sliderValue = value;
    }
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours h $minutes min';
    } else if (minutes > 0) {
      return '$minutes min $seconds s';
    } else {
      return '$seconds s';
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await widget.onSubmit(
          time: _sliderValue.toInt(),
          priorityId: _selectedPriorityId!,
        );
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.taskTimePriority == null ? 'New Task Time Priority' : 'Edit Task Time Priority'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedPriorityId,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: widget.priorityItems,
                validator: (value) => value == null ? 'Please select a priority' : null,
                onChanged: (value) => setState(() => _selectedPriorityId = value),
              ),
              const SizedBox(height: 24),
              Text(
                'Time: ${_formatDuration(_sliderValue.toInt())}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _sliderValue,
                min: 1000, // 1 second
                max: 3600000, // 1 hour
                divisions: 3600 - 1, // 1 second steps roughly
                label: _formatDuration(_sliderValue.toInt()),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1s', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('1h', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
