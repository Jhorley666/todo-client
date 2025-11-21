import 'package:flutter/material.dart';
import '../widgets/menu_widgets/app_drawer.dart';

class BaseLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const BaseLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: const AppDrawer(), // Global menu here
      body: child,
    );
  }
}
