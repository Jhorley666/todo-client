import 'package:flutter/material.dart';
import '../../screens/task_page.dart';
import '../../screens/category_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Time by tasks", style: TextStyle(color: Colors.white)),
          ),
          ListTile(
            leading: const Icon(Icons.task),
            title: const Text("Tasks"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text("Categories"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_suggest),
            title: const Text("Priorities"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/priorities');
            },
          ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sign Out"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/signout');
              },
            ),          
        ],
      ),
    );
  }
}
