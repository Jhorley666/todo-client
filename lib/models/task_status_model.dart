class TaskStatusModel {
  final String id;
  final String name;

  TaskStatusModel({
    required this.id,
    required this.name,
  });

  factory TaskStatusModel.fromJson(Map<String, dynamic> json) {
    return TaskStatusModel(
      id: json['id'] as String,
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