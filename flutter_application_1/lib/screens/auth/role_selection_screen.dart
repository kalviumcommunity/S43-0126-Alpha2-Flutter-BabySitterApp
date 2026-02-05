import 'package:flutter/material.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void navigate(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignUpScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Role")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigate(context, "parent"),
              child: const Text("I am a Parent"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigate(context, "babysitter"),
              child: const Text("I am a Babysitter"),
            ),
          ],
        ),
      ),
    );
  }
}
