import 'package:todo_client/models/register_model.dart';

import '../models/login_model.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<bool> login(LoginModel loginModel) {
    return _authService.login(loginModel.username, loginModel.password);
  }

  Future<bool> register(RegisterModel registerModel){
    return _authService.register(registerModel.username, registerModel.password, registerModel.email);
  }

  Future<void> logout() {
    return _authService.logout();
  }

  Future<String?> getToken() {
    return _authService.getToken();
  }
}