import '../models/task_time_priority_model.dart';
import '../services/task_time_priority_service.dart';

class TaskTimePriorityController {
  final TaskTimePriorityService _taskTimePriorityService = TaskTimePriorityService();

  Future<List<TaskTimePriorityModel>> fetchTaskTimePriorities() {
    return _taskTimePriorityService.fetchTaskTimePriorities();
  }

  Future<TaskTimePriorityModel> getTaskTimePriorityById(int id) {
    return _taskTimePriorityService.getTaskTimePriorityById(id);
  }

  Future<TaskTimePriorityModel> getTaskTimePriorityByPriorityId(int priorityId) {
    return _taskTimePriorityService.getTaskTimePriorityByPriorityId(priorityId);
  }

  Future<void> updateTaskTimePriority(
    int id,
    DateTime time,
    int priorityId,
  ) {
    return _taskTimePriorityService.updateTaskTimePriority(id, time, priorityId);
  }

  Future<void> deleteTaskTimePriority(int id) {
    return _taskTimePriorityService.deleteTaskTimePriority(id);
  }
}

