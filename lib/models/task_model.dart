class TaskModel {
  final int taskId;
  final int userId;
  final int? categoryId;
  final int statusId;
  final String title;
  final String? description;
  final int priorityId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? categoryName;
  String? priorityName;

  TaskModel({
    required this.taskId,
    required this.userId,
    this.categoryId,
    required this.statusId,
    required this.title,
    this.description,
    required this.priorityId,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.priorityName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        taskId: json['taskId'],
        userId: json['userId'],
        categoryId: json['categoryId'],
        statusId: json['statusId'],
        title: json['title'],
        description: json['description'],
        priorityId: json['priorityId'],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
