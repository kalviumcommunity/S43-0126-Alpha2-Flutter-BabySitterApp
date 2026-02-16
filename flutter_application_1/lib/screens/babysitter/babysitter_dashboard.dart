import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/babysitter_service.dart';
import 'babysitter_profile_setup.dart';
import 'verification_upload_screen.dart';

class BabysitterDashboard extends StatefulWidget {
  const BabysitterDashboard({super.key});

  @override
  State<BabysitterDashboard> createState() => _BabysitterDashboardState();
}

class _BabysitterDashboardState extends State<BabysitterDashboard> {
  final BabysitterService _babysitterService = BabysitterService();

  void logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My dashboard"),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder(
        stream: _babysitterService.getBabysitterStream(uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final hasProfile = profile != null;
          final isAvailableNow = profile?.isAvailableNow ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasProfile)
                  Card(
                    child: SwitchListTile(
                      title: const Text("I'm available now"),
                      subtitle: Text(
                        isAvailableNow
                            ? "Parents can see you and contact you"
                            : "Turn on when you're free to accept bookings",
                      ),
                      value: isAvailableNow,
                      onChanged: (value) async {
                        await _babysitterService.updateAvailability(uid, value);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? "You're now visible to parents" : "Availability off",
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Set up your profile first so parents can find you. Then you can turn on \"I'm available now\".",
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  "Your profile is what parents see. Keep it up to date and turn on background verification if you've completed a check.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BabysitterProfileSetup(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: Text(hasProfile ? "Edit my profile" : "Setup my profile"),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VerificationUploadScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user),
                  label: const Text("Upload verification documents"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
