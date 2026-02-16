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

    if (!mounted) return;
    if (error != null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Get user role - this now returns null gracefully on errors
    final role = await _authService.getUserRole();

    if (!mounted) return;
    setState(() => loading = false);

    if (role == null || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Could not load your account data. This might be a network issue or your account may need to be set up.\n\nPlease try again or sign up if you haven't already.",
          ),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: "Retry",
            onPressed: () => login(),
          ),
        ),
      );
      return;
    }

    final route = role == "parent"
        ? MaterialPageRoute(builder: (_) => const ParentHomeScreen())
        : MaterialPageRoute(builder: (_) => const BabysitterDashboard());
    Navigator.of(context).pushAndRemoveUntil(route, (r) => false);
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
