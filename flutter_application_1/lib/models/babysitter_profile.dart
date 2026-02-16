/// Represents a babysitter's public profile for discovery and trust.
class BabysitterProfile {
  final String id;
  final String name;
  final String? experience;
  final String? skills;
  final String? pricePerHour;
  final String? availability;
  final double ratingAverage;
  final int ratingCount;
  final bool backgroundVerified;
  final bool isAvailableNow;
  final DateTime? updatedAt;
  final Map<String, String>? verificationDocuments; // {type: url}

  const BabysitterProfile({
    required this.id,
    required this.name,
    this.experience,
    this.skills,
    this.pricePerHour,
    this.availability,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.backgroundVerified = false,
    this.isAvailableNow = false,
    this.updatedAt,
    this.verificationDocuments,
  });

  factory BabysitterProfile.fromFirestore(String id, Map<String, dynamic> data) {
    return BabysitterProfile(
      id: id,
      name: data['name'] as String? ?? 'Babysitter',
      experience: data['experience'] as String?,
      skills: data['skills'] as String?,
      pricePerHour: data['pricePerHour'] as String?,
      availability: data['availability'] as String?,
      ratingAverage: (data['ratingAverage'] as num?)?.toDouble() ?? 0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      backgroundVerified: data['backgroundVerified'] as bool? ?? false,
      isAvailableNow: data['isAvailableNow'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      verificationDocuments: data['verificationDocuments'] != null
          ? Map<String, String>.from(data['verificationDocuments'] as Map)
          : null,
    );
  }

  String get ratingDisplay {
    if (ratingCount == 0) return 'No reviews yet';
    return '${ratingAverage.toStringAsFixed(1)} ★ ($ratingCount ${ratingCount == 1 ? 'review' : 'reviews'})';
  }
}
