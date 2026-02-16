import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/babysitter_service.dart';
import '../../services/static_babysitter_data.dart';
import '../../models/babysitter_profile.dart';
import 'babysitter_detail_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  void logout(BuildContext context) async {
    await AuthService().logout();
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find caregivers"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/database-check');
            },
            icon: const Icon(Icons.storage),
            tooltip: 'Check Database',
          ),
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              "Trusted babysitters & caregivers",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BabysitterProfile>>(
              stream: BabysitterService().getBabysittersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // On error, show static data as fallback
                List<BabysitterProfile> list;
                if (snapshot.hasError) {
                  list = StaticBabysitterData.getMockBabysitters();
                } else {
                  list = snapshot.data ?? [];
                  // If empty, use static data
                  if (list.isEmpty) {
                    list = StaticBabysitterData.getMockBabysitters();
                  }
                }
                
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No caregivers yet",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Ask babysitters to complete their profile.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final profile = list[index];
                    return _CaregiverCard(
                      profile: profile,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BabysitterDetailScreen(babysitterId: profile.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CaregiverCard extends StatelessWidget {
  final BabysitterProfile profile;
  final VoidCallback onTap;

  const _CaregiverCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          profile.ratingCount == 0
                              ? 'No reviews'
                              : '${profile.ratingAverage.toStringAsFixed(1)} (${profile.ratingCount})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (profile.backgroundVerified) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                        ],
                      ],
                    ),
                    if (profile.isAvailableNow) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.green.shade600),
                          const SizedBox(width: 4),
                          Text(
                            "Available now",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (profile.pricePerHour != null && profile.pricePerHour!.isNotEmpty)
                Text(
                  "\$${profile.pricePerHour}/hr",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
