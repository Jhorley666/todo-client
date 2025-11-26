import 'package:flutter/material.dart';
import '../../models/task_statistics_model.dart';

/// A reusable circular progress widget that displays task completion statistics
/// Shows a circular progress indicator with X/Y format text (e.g., 1/10)
class TaskProgressWidget extends StatelessWidget {
  final TaskStatistics? statistics;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const TaskProgressWidget({
    super.key,
    required this.statistics,
    this.size = 120.0,
    this.strokeWidth = 10.0,
    this.progressColor,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Handle loading state (statistics is null)
    if (statistics == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final total = statistics!.totalTasks;
    final completed = statistics!.completedTasks;
    final percentage = statistics!.completionPercentage;

    // Default colors based on theme
    final defaultProgressColor = progressColor ?? Theme.of(context).primaryColor;
    final defaultBackgroundColor = backgroundColor ?? 
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final defaultTextStyle = textStyle ?? 
        Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ) ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: defaultBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(defaultBackgroundColor),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(defaultProgressColor),
            ),
          ),
          // Text label in center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$completed/$total',
                style: defaultTextStyle,
                textAlign: TextAlign.center,
              ),
              if (total > 0)
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ) ?? const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A variant that handles loading and error states internally
class TaskProgressWidgetWithStates extends StatelessWidget {
  final Future<TaskStatistics>? statisticsFuture;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Widget? errorWidget;

  const TaskProgressWidgetWithStates({
    super.key,
    required this.statisticsFuture,
    this.size = 120.0,
    this.strokeWidth = 10.0,
    this.progressColor,
    this.backgroundColor,
    this.textStyle,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (statisticsFuture == null) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<TaskStatistics>(
      future: statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: size,
            height: size,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return errorWidget ??
              SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, 
                        color: Colors.red, 
                        size: size * 0.3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
        }

        return TaskProgressWidget(
          statistics: snapshot.data,
          size: size,
          strokeWidth: strokeWidth,
          progressColor: progressColor,
          backgroundColor: backgroundColor,
          textStyle: textStyle,
        );
      },
    );
  }
}


