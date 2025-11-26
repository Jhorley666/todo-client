import 'package:flutter/material.dart';
import '../models/register_model.dart';
import '../controllers/auth_controller.dart';

class RegisterFormView extends StatefulWidget {
  const RegisterFormView({super.key});

  @override
  State<RegisterFormView> createState() => _RegisterFormViewState();
}

class _RegisterFormViewState extends State<RegisterFormView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final registerModel = RegisterModel(
      username: _usernameController.text,
      email: _usernameController.text, // Assuming email is the same as username for simplicity
      password: _passwordController.text,
    );

    final success = await _authController.register(registerModel);

    setState(() {
      _loading = false;
    });

    if (success) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      setState(() {
        _error = 'Registration failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
            validator: (v) => v == null || v.isEmpty ? 'Write a username' : null,
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? 'Write a password' : null,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Write an email';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
              if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
              return null;
            },
            onChanged: (v) {
              // You may want to add an _emailController and use it here
              // Or update your RegisterModel accordingly
            },
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 16),
          if (_loading)
            const CircularProgressIndicator()
          else
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _register();
                }
              },
              child: const Text('Sign Up'),
            ),
        ],
      ),
    );
  }
}