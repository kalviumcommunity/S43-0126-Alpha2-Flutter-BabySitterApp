import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../parent/parent_home_screen.dart';
import '../babysitter/babysitter_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final AuthService _authService = AuthService();
  bool loading = false;

  void login() async {
    setState(() => loading = true);

    String? error = await _authService.login(
      email: _email.text.trim(),
      password: _pass.text.trim(),
    );

    if (error != null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    String? role = await _authService.getUserRole();

    setState(() => loading = false);

    if (role == "parent") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BabysitterDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _pass,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
