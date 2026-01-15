class TaskTimePriorityModel {
  final int taskTimePriorityId;
  final int time;
  final int priorityId;
  final int userId;

  TaskTimePriorityModel({
    required this.taskTimePriorityId,
    required this.time,
    required this.priorityId,
    required this.userId,
  });

  factory TaskTimePriorityModel.fromJson(Map<String, dynamic> json) {
    return TaskTimePriorityModel(
      taskTimePriorityId: json['taskTimePriorityId'] as int,
      time: json['time'] as int,
      priorityId: json['priorityId'] as int,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskTimePriorityId': taskTimePriorityId,
      'time': time,
      'priorityId': priorityId,
      'userId': userId,
    };
  }
}

