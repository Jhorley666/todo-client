import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../controllers/task_status_controller.dart';
import '../../models/task_status_model.dart';

class TaskListView extends StatefulWidget {
  final List<TaskModel> tasks;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;
  final Future<bool?> Function() showDeleteConfirmationDialog;
  final TaskStatusController? statusController;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.showDeleteConfirmationDialog,
    this.statusController,
  });

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  late final TaskStatusController _statusController;
  final Map<int, String> _statusMap = {};

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
    _statusController = widget.statusController ?? TaskStatusController();
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
      // fallback silent
    }
  }

  Map<int?, List<TaskModel>> _groupByStatus(List<TaskModel> tasks) {
    final map = <int?, List<TaskModel>>{};
    for (final t in tasks) {
      final key = t.statusId;
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  String _statusName(int? id) {
    if (id == null) return 'Unknown';
    return _statusMap[id] ?? {
          1: 'Pending',
          2: 'In Progress',
          3: 'Done',
        }[id] ??
        'Status $id';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) return const Center(child: Text('No tasks available'));

    final grouped = _groupByStatus(widget.tasks);
    final keys = grouped.keys.toList()..sort((a, b) => (a ?? 999).compareTo(b ?? 999));

    return ListView(
      children: [
        for (final statusKey in keys) ...[
          StatusSection(
            statusId: statusKey,
            title: _statusName(statusKey),
            tasks: grouped[statusKey]!,
            waveController: _waveController,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
            showDeleteConfirmationDialog: widget.showDeleteConfirmationDialog,
          ),
        ],
      ],
    );
  }
}

/// Header + list for a single status (SRP)
class StatusSection extends StatelessWidget {
  final int? statusId;
  final String title;
  final List<TaskModel> tasks;
  final AnimationController waveController;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;
  final Future<bool?> Function() showDeleteConfirmationDialog;

  const StatusSection({
    super.key,
    required this.statusId,
    required this.title,
    required this.tasks,
    required this.waveController,
    required this.onEdit,
    required this.onDelete,
    required this.showDeleteConfirmationDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Text(
            title.toUpperCase(), // distinct style for status header
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade700, letterSpacing: 0.6),
          ),
        ),
        ...tasks.map((t) => TaskTile(
              task: t,
              waveController: waveController,
              onEdit: onEdit,
              onDelete: onDelete,
              showDeleteConfirmationDialog: showDeleteConfirmationDialog,
            )),
      ],
    );
  }
}

/// Tile for a single task (SRP). Handles visual state: in-progress wave, done style, dismissible.
class TaskTile extends StatelessWidget {
  final TaskModel task;
  final AnimationController waveController;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;
  final Future<bool?> Function() showDeleteConfirmationDialog;

  const TaskTile({
    super.key,
    required this.task,
    required this.waveController,
    required this.onEdit,
    required this.onDelete,
    required this.showDeleteConfirmationDialog,
  });

  // Use statusId only (TaskModel has no statusName)
  bool get _isInProgress => task.statusId == 2;
  bool get _isDone => task.statusId == 3;

  Color _priorityColor(int priorityId) {
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

  @override
  Widget build(BuildContext context) {
    final title = Text(
      task.title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        decoration: _isDone ? TextDecoration.lineThrough : TextDecoration.none,
        color: _isDone ? Colors.black.withOpacity(0.6) : Colors.black,
      ),
    );

    // a slim colored bar to visually separate title from status header
    final leftBar = Container(width: 6, height: 56, decoration: BoxDecoration(color: _priorityColor(task.priorityId), borderRadius: BorderRadius.circular(4)));

    final content = ListTile(
      leading: leftBar,
      title: title,
      subtitle: _buildSubtitle(context),
      trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(task)),
      tileColor: _isDone ? Colors.grey.shade50 : null,
    );

    final dismissible = Dismissible(
      key: ValueKey(task.taskId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async => await showDeleteConfirmationDialog(),
      onDismissed: (direction) => onDelete(task),
      child: Opacity(opacity: _isDone ? 0.55 : 1.0, child: content),
    );

    if (_isInProgress && !_isDone) {
      return _InProgressWave(controller: waveController, child: dismissible);
    }
    return dismissible;
  }

  Widget _buildSubtitle(BuildContext context) {
    final List<Widget> chips = [];
    if (task.priorityName != null) {
      chips.add(Chip(label: Text(task.priorityName!), backgroundColor: _priorityColor(task.priorityId), labelStyle: const TextStyle(color: Colors.white, fontSize: 12)));
    }
    if (task.categoryName != null) {
      chips.add(Chip(label: Text(task.categoryName!), backgroundColor: Colors.blue.shade50, labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 12)));
    }
    if (task.dueDate != null) {
      chips.add(Chip(label: Text(task.dueDate!.toLocal().toString().split(' ')[0]), backgroundColor: Colors.grey.shade100, labelStyle: TextStyle(color: Colors.grey.shade800, fontSize: 12)));
    }
    return Wrap(spacing: 6, runSpacing: 4, children: chips);
  }
}

/// Animated overlay used when a task is in progress (keeps single controller).
class _InProgressWave extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _InProgressWave({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final t = controller.value;
                final dx = -0.8 + 1.8 * t;
                return FractionalTranslation(
                  translation: Offset(dx, 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.blue.withOpacity(0.10), Colors.transparent],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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