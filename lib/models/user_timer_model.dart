class UserTimerModel {
  final int? idUserTimer;
  final int? userId;
  final int? totalSecondsAccumulated;
  final int? remainingSeconds;
  final DateTime? startedAt;
  final bool? isRunning;
  final DateTime? updatedAt;

  UserTimerModel({
    this.idUserTimer,
    this.userId,
    this.totalSecondsAccumulated,
    this.remainingSeconds,
    this.startedAt,
    this.isRunning,
    this.updatedAt,
  });

  factory UserTimerModel.fromJson(Map<String, dynamic> json) {
    return UserTimerModel(
      idUserTimer: json['idUserTimer'] as int?,
      userId: json['userId'] as int?,
      totalSecondsAccumulated: json['totalSecondsAccumulated'] as int?,
      remainingSeconds: json['remainingSeconds'] as int?,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt']) : null,
      isRunning: json['isRunning'] as bool?,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUserTimer': idUserTimer,
      'userId': userId,
      'totalSecondsAccumulated': totalSecondsAccumulated,
      'remainingSeconds': remainingSeconds,
      'startedAt': startedAt?.toIso8601String(),
      'isRunning': isRunning,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
