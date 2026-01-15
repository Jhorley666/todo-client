import 'package:shared_preferences/shared_preferences.dart';
import 'base_http_service.dart';
import '../models/logout_response.dart';

class AuthService {
  final BaseHttpService _httpService = BaseHttpService();

  Future<bool> login(String username, String password) async {
    try {
      final response = await _httpService.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<LogoutResponse?> logout() async {
    try {
      final response = await _httpService.post('/auth/logout');
      if (response.statusCode == 200) {
        return LogoutResponse.fromJson(response.data);
      }
    } catch (e) {
      // Proceed to local logout even if server fails
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    }
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<bool> register(String username, String password, String email) async {
    try {
      final response = await _httpService.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
