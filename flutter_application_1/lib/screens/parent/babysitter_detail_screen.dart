import 'package:flutter/material.dart';
import '../../models/babysitter_profile.dart';
import '../../services/babysitter_service.dart';

/// Full babysitter profile for parents: ratings, verification, real-time status.
class BabysitterDetailScreen extends StatelessWidget {
  final String babysitterId;

  const BabysitterDetailScreen({super.key, required this.babysitterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Profile"),
      ),
      body: StreamBuilder<BabysitterProfile?>(
        stream: BabysitterService().getBabysitterStream(babysitterId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data!;
          return _ProfileContent(profile: profile);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final BabysitterProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              profile.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          _ProfileContent._buildTrustRow(context, profile),
          const SizedBox(height: 24),
          if (profile.experience != null && profile.experience!.isNotEmpty) ...[
            _ProfileContent._sectionTitle(context, "Experience"),
            Text(profile.experience!, style: _ProfileContent._bodyStyle(context)),
            const SizedBox(height: 16),
          ],
          if (profile.skills != null && profile.skills!.isNotEmpty) ...[
            _ProfileContent._sectionTitle(context, "Skills"),
            Text(profile.skills!, style: _ProfileContent._bodyStyle(context)),
            const SizedBox(height: 16),
          ],
          if (profile.availability != null && profile.availability!.isNotEmpty) ...[
            _ProfileContent._sectionTitle(context, "Availability"),
            Text(profile.availability!, style: _ProfileContent._bodyStyle(context)),
            const SizedBox(height: 16),
          ],
          if (profile.pricePerHour != null && profile.pricePerHour!.isNotEmpty) ...[
            _ProfileContent._sectionTitle(context, "Rate"),
            Text("\$${profile.pricePerHour}/hour", style: _ProfileContent._bodyStyle(context)),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Request sent! (MVP: contact flow coming soon)")),
                );
              },
              icon: const Icon(Icons.message),
              label: const Text("Request to book"),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTrustRow(BuildContext context, BabysitterProfile profile) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        Chip(
          avatar: const Icon(Icons.star, color: Colors.amber, size: 20),
          label: Text(profile.ratingCount == 0 ? 'No reviews yet' : '${profile.ratingAverage.toStringAsFixed(1)} (${profile.ratingCount})'),
        ),
        if (profile.backgroundVerified)
          const Chip(
            avatar: Icon(Icons.verified, color: Colors.green, size: 20),
            label: Text("Background verified"),
          ),
        if (profile.isAvailableNow)
          Chip(
            backgroundColor: Colors.green.shade100,
            avatar: const Icon(Icons.circle, color: Colors.green, size: 12),
            label: const Text("Available now"),
          ),
      ],
    );
  }

  static Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  static TextStyle? _bodyStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge;
  }
}
