import 'dart:async';
import 'package:flutter/material.dart';
import '../../controllers/user_timer_controller.dart';
import '../../models/user_timer_model.dart';

enum TimerState { stopped, playing, paused }

class TaskTimerWidget extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onTimerComplete;
  final double size;
  final double strokeWidth;

  const TaskTimerWidget({
    super.key,
    required this.totalSeconds,
    this.onTimerComplete,
    this.size = 120.0,
    this.strokeWidth = 10.0,
  });

  @override
  State<TaskTimerWidget> createState() => _TaskTimerWidgetState();
}

class _TaskTimerWidgetState extends State<TaskTimerWidget> {
  final UserTimerController _controller = UserTimerController();
  Timer? _ticker;
  Duration _remainingDuration = Duration.zero;
  TimerState _timerState = TimerState.stopped;
  bool _isLoading = false;
  DateTime? _localEndTime;

  @override
  void initState() {
    super.initState();
    _remainingDuration = Duration(seconds: widget.totalSeconds);
    _fetchStatus();
  }

  @override
  void didUpdateWidget(TaskTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalSeconds != widget.totalSeconds) {
       // If the widget receives a new total, logic might need adjustment
       // depending on whether 'remaining' is driven by this total or the server.
       // For now, valid server state takes precedence.
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await _controller.getTimerStatus();
      _syncState(status);
    } catch (e) {
      debugPrint('Error fetching timer status: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _syncState(UserTimerModel model) {
    final remainingSeconds = model.remainingSeconds ?? 0;
    _remainingDuration = Duration(seconds: remainingSeconds);

    if (model.isRunning == true) {
      _timerState = TimerState.playing;
      _startLocalTicker();
    } else {
      _timerState = TimerState.paused; // Or stopped? API only has Start/Pause usually implies Pause state.
      _stopLocalTicker();
    }
    setState(() {});
  }

  void _startLocalTicker() {
    _ticker?.cancel();
    // Calculate expected end time to prevent drift
    _localEndTime = DateTime.now().add(_remainingDuration);
    
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      if (_localEndTime != null) {
        final newRemaining = _localEndTime!.difference(now);
        
        if (newRemaining.isNegative || newRemaining.inSeconds <= 0) {
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
      }
    });
  }

  void _stopLocalTicker() {
    _ticker?.cancel();
    _localEndTime = null;
  }

  Future<void> _startTimer() async {
    setState(() => _isLoading = true);
    try {
      final model = await _controller.startTimer();
      _syncState(model);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting timer: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pauseTimer() async {
    setState(() => _isLoading = true);
    try {
      final model = await _controller.pauseTimer();
      _syncState(model);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error pausing timer: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getProgressColor() {
    if (widget.totalSeconds == 0) {
      return Colors.green;
    }

    final progress = _remainingDuration.inSeconds / widget.totalSeconds;

    if (progress <= 0.25) {
      return Colors.red;
    } else if (progress <= 0.50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  double _getProgress() {
    if (widget.totalSeconds == 0) {
      return 1.0;
    }
    final denom = widget.totalSeconds;
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
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          _timerState == TimerState.playing ? Icons.pause : Icons.play_arrow,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: _timerState == TimerState.playing ? _pauseTimer : _startTimer,
                        tooltip: _timerState == TimerState.playing ? 'Pause' : 'Play',
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