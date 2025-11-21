import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';

class HomeController {
  Future<String> fetchBranding() async {
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