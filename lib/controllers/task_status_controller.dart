import 'package:todo_client/models/task_status_model.dart';
import 'package:todo_client/services/task_status_service.dart';

class TaskStatusController {

  final TaskStatusService _taskStatusService = TaskStatusService();

  Future<List<TaskStatusModel>> fetchTaskStatuses() {
    return _taskStatusService.fetchTaskStatuses();
  }

}