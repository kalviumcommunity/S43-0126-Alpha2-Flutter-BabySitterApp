import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'babysitter_profile_setup.dart';

class BabysitterDashboard extends StatelessWidget {
  const BabysitterDashboard({super.key});

  void logout(BuildContext context) async {
    await AuthService().logout();

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Babysitter Dashboard"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BabysitterProfileSetup()),
            );
          },
          child: const Text("Setup My Profile"),
        ),
      ),
    );
  }
}
