import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../controllers/task_status_controller.dart';
import '../../models/task_status_model.dart';

class TaskListView extends StatefulWidget {
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
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  final TaskStatusController _statusController = TaskStatusController();
  final Map<int, String> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _loadStatuses();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    try {
      final List<TaskStatusModel> statuses = await _statusController.fetchTaskStatuses();
      if (!mounted) return;
      setState(() {
        for (final s in statuses) {
          _statusMap[s.id] = s.name;
        }
      });
    } catch (_) {
      // ignore errors, fallback names will be used
    }
  }

  String _getStatusName(int? statusId) {
    if (statusId == null) return 'Unknown';
    final fromMap = _statusMap[statusId];
    if (fromMap != null && fromMap.isNotEmpty) return fromMap;
    switch (statusId) {
      case 1:
        return 'Pending';
      case 2:
        return 'In Progress';
      case 3:
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  bool _isInProgress(TaskModel t) {
    final s = t.statusId;
    final name = _statusMap[s]?.toLowerCase();
    return s == 2 || (name != null && name.contains('progress'));
  }

  bool _isDone(TaskModel t) {
    final s = t.statusId;
    final name = _statusMap[s]?.toLowerCase();
    return s == 3 || (name != null && (name.contains('done') || name.contains('completed')));
  }

  Map<int?, List<TaskModel>> _groupByStatus(List<TaskModel> tasks) {
    final map = <int?, List<TaskModel>>{};
    for (final t in tasks) {
      final key = t.statusId;
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return const Center(child: Text('No tasks available'));
    }

    final grouped = _groupByStatus(widget.tasks);
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final va = a ?? 999;
        final vb = b ?? 999;
        return va.compareTo(vb);
      });

    return ListView(
      children: [
        for (final statusKey in sortedKeys) ...[
          _buildStatusHeader(statusKey, grouped[statusKey]!),
          ...grouped[statusKey]!.map((task) => _buildTaskTile(context, task)).toList(),
        ]
      ],
    );
  }

  Widget _buildStatusHeader(int? statusKey, List<TaskModel> tasks) {
    final title = _getStatusName(statusKey);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, TaskModel task) {
    final isInProgress = _isInProgress(task);
    final isDone = _isDone(task);

    final titleWidget = Text(
      task.title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
        color: isDone ? Colors.black.withOpacity(0.55) : Colors.black,
      ),
    );

    final tile = ListTile(
      title: titleWidget,
      subtitle: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if ((task as dynamic).priorityName != null)
            Chip(
              label: Text((task as dynamic).priorityName as String),
              backgroundColor: _getPriorityColor(task.priorityId),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              labelStyle: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          if ((task as dynamic).categoryName != null)
            Chip(
              label: Text((task as dynamic).categoryName as String),
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
        onPressed: () => widget.onEdit(task),
      ),
    );

    final wrapped = Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: tile,
    );

    if (isInProgress && !isDone) {
      return Dismissible(
        key: ValueKey(task.taskId),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async => await widget.showDeleteConfirmationDialog(),
        onDismissed: (direction) => widget.onDelete(task),
        child: _InProgressWave(
          controller: _waveController,
          child: wrapped,
        ),
      );
    }

    return Dismissible(
      key: ValueKey(task.taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async => await widget.showDeleteConfirmationDialog(),
      onDismissed: (direction) => widget.onDelete(task),
      child: wrapped,
    );
  }

  Color _getPriorityColor(int priorityId) {
    switch (priorityId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// A simple repeating left-to-right animated gradient "wave" overlay.
/// Uses a shared animation controller passed from parent to avoid many controllers.
class _InProgressWave extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _InProgressWave({
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final anim = controller;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: anim,
              builder: (context, _) {
                final t = anim.value;
                final dx = -0.8 + 1.8 * t;
                return FractionalTranslation(
                  translation: Offset(dx, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.blue.withOpacity(0.10),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}