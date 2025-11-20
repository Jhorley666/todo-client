class TaskTimePriorityModel {
  final int taskTimePriorityId;
  final DateTime time;
  final int priorityId;

  TaskTimePriorityModel({
    required this.taskTimePriorityId,
    required this.time,
    required this.priorityId,
  });

  factory TaskTimePriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskTimePriorityModel(
      taskTimePriorityId: json['taskTimePriorityId'] as int,
      time: DateTime.parse(json['time'] as String),
      priorityId: json['priorityId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskTimePriorityId': taskTimePriorityId,
      'time': time.toIso8601String(),
      'priorityId': priorityId,
    };
  }
}

