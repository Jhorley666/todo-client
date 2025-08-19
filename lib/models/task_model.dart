enum Priority { Low, Medium, High }

class TaskModel {
  final int taskId;
  final int userId;
  final int? categoryId;
  final int statusId;
  final String title;
  final String? description;
  final Priority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.taskId,
    required this.userId,
    this.categoryId,
    required this.statusId,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        taskId: json['taskId'],
        userId: json['userId'],
        categoryId: json['categoryId'],
        statusId: json['statusId'],
        title: json['title'],
        description: json['description'],
        priority: Priority.values.firstWhere(
          (e) => e.name.toLowerCase() == json['priority'].toString().toLowerCase(),
        ),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
