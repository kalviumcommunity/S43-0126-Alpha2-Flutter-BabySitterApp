import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  void logout(BuildContext context) async {
    await AuthService().logout();

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Home"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Search Babysitters Here",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
