import 'package:flutter/material.dart';
import '../controllers/priority_controller.dart';
import '../controllers/task_time_priority_controller.dart';
import '../models/task_time_priority_model.dart';
import '../widgets/menu_widgets/app_drawer.dart';
import '../widgets/task_time_priority_widgets/task_time_priority_form_dialog.dart';
import '../widgets/utils_widgets/delete_confirmation_dialog.dart';
import '../layouts/base_layout.dart';

class TaskTimePriorityPage extends StatefulWidget {
  const TaskTimePriorityPage({super.key});

  @override
  State<TaskTimePriorityPage> createState() => _TaskTimePriorityPageState();
}

class _TaskTimePriorityPageState extends State<TaskTimePriorityPage> {
  final TaskTimePriorityController _controller = TaskTimePriorityController();
  final PriorityController _priorityController = PriorityController();
  late Future<List<TaskTimePriorityModel>> _taskTimePrioritiesFuture;
  Map<int, String> _priorityNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _taskTimePrioritiesFuture = _controller.fetchTaskTimePriorities();
    });
    _loadPriorities();
  }

  Future<void> _loadPriorities() async {
    try {
      final priorities = await _priorityController.fetchPriorities();
      if (mounted) {
        setState(() {
          _priorityNames = {
            for (var p in priorities) p.priorityId: p.priorityName
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading priorities: $e');
    }
  }

  Future<void> _showFormDialog({TaskTimePriorityModel? taskTimePriority}) async {
    try {
      final priorities = await _priorityController.fetchPriorities();
      final priorityItems = priorities
          .map((p) => DropdownMenuItem<int>(
                value: p.priorityId,
                child: Text(p.priorityName),
              ))
          .toList();

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => TaskTimePriorityFormDialog(
          taskTimePriority: taskTimePriority,
          priorityItems: priorityItems,
          onSubmit: ({required int time, required int priorityId}) async {
            if (taskTimePriority == null) {
              await _controller.createTaskTimePriority(time, priorityId);
            } else {
              await _controller.updateTaskTimePriority(
                taskTimePriority.taskTimePriorityId,
                time,
                priorityId,
              );
            }
            _loadData();
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening form: $e')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      title: 'Task Time Priorities',
      child: Scaffold(
        drawer: const AppDrawer(),
        body: FutureBuilder<List<TaskTimePriorityModel>>(
          future: _taskTimePrioritiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No task time priorities found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  final priorityName = _priorityNames[item.priorityId] ?? 'Unknown Priority';
                  final timeString = _formatDuration(item.time);

                  return Dismissible(
                    key: ValueKey(item.taskTimePriorityId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await DeleteConfirmationDialog.show(
                        context,
                        entityName: 'task time priority',
                      );
                    },
                    onDismissed: (direction) async {
                      try {
                        await _controller.deleteTaskTimePriority(item.taskTimePriorityId);
                        // No need to reload data as the item is removed from the list visually by Dismissible
                        // But to keep state consistent and if there are other side effects, we might want to.
                        // However, Dismissible removes the child from the tree.
                        // If we reload data, the FutureBuilder will rebuild the list.
                        // Let's reload to be safe and ensure sync with server.
                        _loadData(); 
                      } catch (e) {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error deleting item: $e')),
                          );
                          // If error, we might need to reload to bring the item back
                          _loadData();
                        }
                      }
                    },
                    child: ListTile(
                      title: Text(priorityName),
                      subtitle: Text('Time: $timeString'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showFormDialog(taskTimePriority: item),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showFormDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
