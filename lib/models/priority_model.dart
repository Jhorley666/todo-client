class PriorityModel {
  final int priorityId;
  final String priorityName;

  PriorityModel({
    required this.priorityId,
    required this.priorityName,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) {
    return PriorityModel(
      priorityId: json['priorityId'] as int,
      priorityName: json['priorityName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priorityId': priorityId,
      'priorityName': priorityName,
    };
  }
}

