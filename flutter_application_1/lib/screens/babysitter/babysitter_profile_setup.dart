import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool loading = false;

  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("babysitters").doc(uid).set({
        "experience": _experience.text.trim(),
        "skills": _skills.text.trim(),
        "pricePerHour": _price.text.trim(),
        "availability": _availability.text.trim(),
        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Saved Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Babysitter Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _experience,
              decoration: const InputDecoration(labelText: "Experience (years)"),
            ),
            TextField(
              controller: _skills,
              decoration: const InputDecoration(labelText: "Skills"),
            ),
            TextField(
              controller: _price,
              decoration: const InputDecoration(labelText: "Price per hour"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _availability,
              decoration: const InputDecoration(labelText: "Availability"),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: saveProfile,
                    child: const Text("Save Profile"),
                  ),
          ],
        ),
      ),
    );
  }
}
