class CategoryModel {
  final int id;
  final int userId;
  final String name;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['categoryId'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
    };
  }
}