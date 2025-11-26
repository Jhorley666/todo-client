import 'package:flutter/material.dart';
import '../models/priority_model.dart';
import '../controllers/priority_controller.dart';
import '../widgets/priority_widgets/priority_list_view.dart';
import '../widgets/priority_widgets/priority_form_dialog.dart';

class PriorityPage extends StatefulWidget {
  const PriorityPage({super.key});

  @override
  State<PriorityPage> createState() => _PriorityPageState();
}

class _PriorityPageState extends State<PriorityPage> {
  final PriorityController _controller = PriorityController();
  late Future<List<PriorityModel>> _prioritiesFuture;

  @override
  void initState() {
    super.initState();
    _loadPriorities();
  }

  void _loadPriorities() {
    setState(() {
      _prioritiesFuture = _controller.fetchPriorities();
    });
  }

  Future<void> _showForm({PriorityModel? priority}) async {
    await showDialog(
      context: context,
      builder: (context) => PriorityFormDialog(
        priority: priority,
        onSubmit: (name) async {
          if (priority == null) {
            await _controller.addPriority(name);
          } else {
            await _controller.updatePriority(priority.priorityId, priority.priorityName);
          }
          _loadPriorities();
        },
      ),
    );
  }

  void _edit(PriorityModel p) => _showForm(priority: p);

  void _delete(PriorityModel p) async {
    await _controller.deletePriority(p.priorityId);
    _loadPriorities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Priorities')),
      body: FutureBuilder<List<PriorityModel>>(
        future: _prioritiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No priorities found'));
          } else {
            return PriorityListView(
              priorities: snapshot.data!,
              onEdit: _edit,
              onDelete: _delete,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}