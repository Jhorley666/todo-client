import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;
  final Future<bool?> Function() showDeleteConfirmationDialog;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.showDeleteConfirmationDialog,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks available'));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Dismissible(
          key: ValueKey(task.taskId),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDeleteConfirmationDialog();
          },
          onDismissed: (direction) {
            onDelete(task);
          },
          child: ListTile(
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(task.priority.name),
                  backgroundColor: _getPriorityColor(task.priority.name),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                if (task.categoryName != null)
                  Chip(
                    label: Text(task.categoryName!),
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelStyle: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                  ),
                if (task.dueDate != null)
                  Chip(
                    label: Text(task.dueDate!.toLocal().toString().split(' ')[0]),
                    backgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(task),
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}