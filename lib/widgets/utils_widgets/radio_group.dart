import 'package:flutter/material.dart';
import 'package:todo_client/models/task_status_model.dart';

class RadioGroup extends StatelessWidget {

  final List<TaskStatusModel> taskStatuses;
  final List<Widget> children;
  final int? groupValue;
  final ValueChanged<int?>? onChanged;

  const RadioGroup({
    super.key,
    required this.children,
    required this.taskStatuses,
    this.groupValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.map((child) {
        final index = children.indexOf(child);
        return RadioListTile<int>(
          value: index,
          groupValue: groupValue,
          onChanged: onChanged,
          title: child,
        );
      }).toList(),
    );
  }
} 