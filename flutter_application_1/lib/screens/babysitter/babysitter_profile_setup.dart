import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/babysitter_service.dart';

class BabysitterProfileSetup extends StatefulWidget {
  const BabysitterProfileSetup({super.key});

  @override
  State<BabysitterProfileSetup> createState() => _BabysitterProfileSetupState();
}

class _BabysitterProfileSetupState extends State<BabysitterProfileSetup> {
  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _price = TextEditingController();
  final _availability = TextEditingController();

  final BabysitterService _babysitterService = BabysitterService();
  bool loading = false;
  bool backgroundVerified = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await _babysitterService.getBabysitter(uid);
    if (profile != null && mounted) {
      setState(() {
        _experience.text = profile.experience ?? '';
        _skills.text = profile.skills ?? '';
        _price.text = profile.pricePerHour ?? '';
        _availability.text = profile.availability ?? '';
        backgroundVerified = profile.backgroundVerified;
      });
    }
  }

  Future<String> _getUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Babysitter';
    // Prefer displayName (no network) then try Firestore with cache fallback
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      if (doc.exists) {
        final name = doc.get('name');
        if (name is String && name.trim().isNotEmpty) return name.trim();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.toLowerCase().contains('offline') == true) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(const GetOptions(source: Source.cache));
        if (doc.exists) {
          final name = doc.get('name');
          if (name is String && name.trim().isNotEmpty) return name.trim();
        }
      }
    }
    return user.email?.split('@').first ?? 'Babysitter';
  }

  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final name = await _getUserName();

      await _babysitterService.saveProfile(
        uid: uid,
        name: name,
        experience: _experience.text.trim().isEmpty ? null : _experience.text.trim(),
        skills: _skills.text.trim().isEmpty ? null : _skills.text.trim(),
        pricePerHour: _price.text.trim().isEmpty ? null : _price.text.trim(),
        availability: _availability.text.trim().isEmpty ? null : _availability.text.trim(),
        backgroundVerified: backgroundVerified,
      );

      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved. Parents can now find you.")),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      final isOffline = e.code == 'unavailable' ||
          e.message?.toLowerCase().contains('offline') == true ||
          e.message?.toLowerCase().contains('failed to get document') == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOffline
                ? "Could not save: network error. Check your internet and try again."
                : "Could not save: ${e.message ?? e.code}",
          ),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Retry",
            onPressed: () => saveProfile(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving profile: $e"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Retry",
            onPressed: () => saveProfile(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Babysitter Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _experience,
              decoration: const InputDecoration(
                labelText: "Experience (e.g. 3 years)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _skills,
              decoration: const InputDecoration(
                labelText: "Skills (e.g. CPR, first aid)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: "Price per hour (\$)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _availability,
              decoration: const InputDecoration(
                labelText: "Availability (e.g. Weekends, evenings)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text("Background verified"),
                subtitle: const Text("I have completed a background check"),
                value: backgroundVerified,
                onChanged: (v) => setState(() => backgroundVerified = v),
              ),
            ),
            const SizedBox(height: 24),
            loading
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(
                    onPressed: saveProfile,
                    child: const Text("Save Profile"),
                  ),
          ],
        ),
      ),
    );
  }
}
