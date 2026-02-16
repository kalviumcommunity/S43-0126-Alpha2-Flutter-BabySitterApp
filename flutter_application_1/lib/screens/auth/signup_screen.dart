import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../parent/parent_home_screen.dart';
import '../babysitter/babysitter_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  final String role;

  const SignUpScreen({super.key, required this.role});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  final AuthService _authService = AuthService();
  bool loading = false;

  void signUp() async {
    setState(() => loading = true);

    String? error = await _authService.signUp(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _pass.text.trim(),
      role: widget.role,
    );

    if (!mounted) return;
    if (error != null) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed: $error")));
      return;
    }

    // Data is stored in Firebase; user is signed in. Go straight to home.
    if (!mounted) return;
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Welcome!")));
    final isParent = widget.role.trim().toLowerCase() == "parent";
    final route = isParent
        ? MaterialPageRoute(builder: (_) => const ParentHomeScreen())
        : MaterialPageRoute(builder: (_) => const BabysitterDashboard());
    Navigator.of(context).pushAndRemoveUntil(route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup as ${widget.role}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
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
                : ElevatedButton(
                    onPressed: signUp,
                    child: const Text("Sign Up"),
                  ),
          ],
        ),
      ),
    );
  }
}
