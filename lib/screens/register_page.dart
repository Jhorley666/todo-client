import 'package:flutter/material.dart';
import 'package:todo_client/widgets/register_form_view.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: RegisterFormView(),
            ),
          ),
        ),
      ),
    );
  }
}