import 'package:flutter/material.dart';
import '../widgets/home_view.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do App')),
      body: HomeView(controller: HomeController()),
    );
  }
}