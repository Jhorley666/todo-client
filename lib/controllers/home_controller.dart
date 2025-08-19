import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';

class HomeController {
  // Métodos para cargar información de la app
  Future<String> fetchBranding() async {
    // TODO: Replace with actual branding fetch logic
    return "Branding info";
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }
}