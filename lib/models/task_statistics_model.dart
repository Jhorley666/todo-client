class TaskStatistics {
  final int totalTasks;
  final int completedTasks;

  TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
  });

  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
}


