import 'package:flutter/material.dart';
import '../widgets/login_form_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: LoginFormView(),
            ),
          ),
        ),
      ),
    );
  }
}