import 'package:flutter/material.dart';
import '../../models/priority_model.dart';

class PriorityListView extends StatelessWidget {
  final List<PriorityModel> priorities;
  final void Function(PriorityModel) onEdit;
  final void Function(PriorityModel) onDelete;

  const PriorityListView({
    super.key,
    required this.priorities,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (priorities.isEmpty) {
      return const Center(child: Text('No priorities available'));
    }
    return ListView.builder(
      itemCount: priorities.length,
      itemBuilder: (context, index) {
        final p = priorities[index];
        return Dismissible(
          key: ValueKey(p.priorityId),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(p),
          child: ListTile(
            title: Text(p.priorityName),    
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(p),
            ),
          ),
        );
      },
    );
  }
}