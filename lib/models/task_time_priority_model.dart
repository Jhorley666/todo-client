class TaskTimePriorityModel {
  final int taskTimePriorityId;
  final int time;
  final int priorityId;

  TaskTimePriorityModel({
    required this.taskTimePriorityId,
    required this.time,
    required this.priorityId,
  });

  factory TaskTimePriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskTimePriorityModel(
      taskTimePriorityId: json['taskTimePriorityId'] as int,
      time: json['time'] as int,
      priorityId: json['priorityId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskTimePriorityId': taskTimePriorityId,
      'time': time,
      'priorityId': priorityId,
    };
  }
}

