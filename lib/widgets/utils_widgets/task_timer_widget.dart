import 'dart:async';
import 'package:flutter/material.dart';

enum TimerState { stopped, playing, paused }

class TaskTimerWidget extends StatefulWidget {
  final Duration totalDuration;
  final VoidCallback? onTimerComplete;
  final double size;
  final double strokeWidth;

  const TaskTimerWidget({
    super.key,
    required this.totalDuration,
    this.onTimerComplete,
    this.size = 120.0,
    this.strokeWidth = 10.0,
  });

  @override
  State<TaskTimerWidget> createState() => _TaskTimerWidgetState();
}

class _TaskTimerWidgetState extends State<TaskTimerWidget> {
  Timer? _timer;
  Duration _remainingDuration = Duration.zero;
  TimerState _timerState = TimerState.stopped;
  DateTime? _startTime;
  Duration _elapsedBeforePause = Duration.zero;
  DateTime? _pauseTime;

  @override
  void initState() {
    super.initState();
    _remainingDuration = widget.totalDuration;
  }

  @override
  void didUpdateWidget(TaskTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalDuration != widget.totalDuration) {
      if (_timerState == TimerState.stopped) {
        _remainingDuration = widget.totalDuration;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_timerState == TimerState.paused) {
      // Resume: adjust start time to account for pause duration
      final pauseDuration = DateTime.now().difference(_pauseTime!);
      _startTime = _startTime!.add(pauseDuration);
      _pauseTime = null;
    } else {
      // Start fresh
      _startTime = DateTime.now();
      _elapsedBeforePause = Duration.zero;
    }

    _timerState = TimerState.playing;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_startTime!);
      final newRemaining = widget.totalDuration - elapsed;

      if (newRemaining.isNegative || newRemaining <= Duration.zero) {
        setState(() {
          _remainingDuration = Duration.zero;
          _timerState = TimerState.stopped;
        });
        timer.cancel();
        widget.onTimerComplete?.call();
      } else {
        setState(() {
          _remainingDuration = newRemaining;
        });
      }
    });
  }

  void _pauseTimer() {
    if (_timerState == TimerState.playing) {
      _timer?.cancel();
      _pauseTime = DateTime.now();
      _timerState = TimerState.paused;
      setState(() {});
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _remainingDuration = widget.totalDuration;
      _timerState = TimerState.stopped;
      _startTime = null;
      _pauseTime = null;
      _elapsedBeforePause = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getProgressColor() {
    if (widget.totalDuration == Duration.zero) {
      return Colors.green;
    }

    final progress = _remainingDuration.inSeconds / widget.totalDuration.inSeconds;

    if (progress <= 0.25) {
      return Colors.red;
    } else if (progress <= 0.50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  double _getProgress() {
    if (widget.totalDuration == Duration.zero) {
      return 1.0;
    }
    final denom = widget.totalDuration.inSeconds;
    if (denom == 0) return 1.0;
    return (_remainingDuration.inSeconds / denom).clamp(0.0, 1.0);
  }

  Widget _buildLinearProgress() {
    final progressColor = _getProgressColor();
    final progress = _getProgress();
    final Color defaultBackgroundColor = Colors.grey.shade300;

    // Use widget.size as width for the linear bar container
    final double width = widget.size;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.strokeWidth),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: widget.strokeWidth,
              backgroundColor: defaultBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 8),
          // Time text and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_remainingDuration),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ) ??
                    TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Controls and progress aligned horizontally
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Control buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _timerState == TimerState.playing ? Icons.pause : Icons.play_arrow,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: _timerState == TimerState.playing ? _pauseTimer : _startTimer,
                      tooltip: _timerState == TimerState.playing ? 'Pause' : 'Play',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      color: Colors.red,
                      onPressed: _timerState != TimerState.stopped ? _stopTimer : null,
                      tooltip: 'Stop',
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Expanded linear progress to take remaining width
                Expanded(child: _buildLinearProgress()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}