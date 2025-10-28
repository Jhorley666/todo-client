import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskListView extends StatelessWidget {
  final List<TaskModel> tasks;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
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
          onDismissed: (direction) => onDelete(task),
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(
              'Prioridad: ${task.priority.name} | '
              'Categoría: ${task.categoryName ?? "-"} | '
              'Vence: ${task.dueDate != null ? task.dueDate!.toLocal().toString().split(' ')[0] : "-"}',
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
}