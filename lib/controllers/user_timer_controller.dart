import '../models/user_timer_model.dart';
import '../services/user_timer_service.dart';

class UserTimerController {
  final UserTimerService _userTimerService = UserTimerService();

  Future<UserTimerModel> startTimer() {
    return _userTimerService.startTimer();
  }

  Future<UserTimerModel> pauseTimer() {
    return _userTimerService.pauseTimer();
  }

  Future<UserTimerModel> getTimerStatus() {
    return _userTimerService.getTimerStatus();
  }
}
