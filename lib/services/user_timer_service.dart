import '../models/user_timer_model.dart';
import 'base_http_service.dart';

class UserTimerService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<UserTimerModel> startTimer() async {
    try {
      final response = await _httpService.post('/user-timers/start');
      return UserTimerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al iniciar el temporizador');
    }
  }

  Future<UserTimerModel> pauseTimer() async {
    try {
      final response = await _httpService.post('/user-timers/pause');
      return UserTimerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al pausar el temporizador');
    }
  }

  Future<UserTimerModel> getTimerStatus() async {
    try {
      final response = await _httpService.get('/user-timers/status');
      return UserTimerModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener el estado del temporizador');
    }
  }
}
