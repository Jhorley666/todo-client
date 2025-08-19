import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController controller;
  const HomeView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: controller.fetchBranding(),
      builder: (context, snapshot) {
        final branding = snapshot.data ?? 'Welcome to the To-Do App';
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  branding,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                  onPressed: () => controller.goToLogin(context),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Sign Up'),
                  onPressed: () => controller.goToRegister(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}