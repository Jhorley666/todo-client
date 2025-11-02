class TaskStatusModel {
  final int id;
  final String name;

  TaskStatusModel({
    required this.id,
    required this.name,
  });

  factory TaskStatusModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusModel(
      id: json['statusId'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}