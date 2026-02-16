import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/babysitter_profile.dart';
import 'static_babysitter_data.dart';

/// Service for fetching and updating babysitter profiles with real-time updates.
class BabysitterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time stream of all babysitter profiles for parent discovery.
  /// Falls back to static data if database is empty or unavailable.
  Stream<List<BabysitterProfile>> getBabysittersStream() {
    return _firestore.collection('babysitters').snapshots().map((snap) {
      final dbBabysitters = snap.docs
          .map((doc) => BabysitterProfile.fromFirestore(doc.id, doc.data()))
          .toList();
      
      // If database has babysitters, return them
      if (dbBabysitters.isNotEmpty) {
        return dbBabysitters;
      }
      
      // Otherwise, return static/mock data for demonstration
      return StaticBabysitterData.getMockBabysitters();
    }).handleError((error) {
      // On error, emit static data as fallback
      return StaticBabysitterData.getMockBabysitters();
    });
  }

  /// Get a single babysitter profile with real-time updates.
  /// Falls back to static data if not found in database.
  Stream<BabysitterProfile?> getBabysitterStream(String uid) {
    // Check if it's a static ID
    if (uid.startsWith('static_')) {
      final staticBabysitters = StaticBabysitterData.getMockBabysitters();
      final staticProfile = staticBabysitters.firstWhere(
        (p) => p.id == uid,
        orElse: () => staticBabysitters.first,
      );
      return Stream.value(staticProfile);
    }

    return _firestore.collection('babysitters').doc(uid).snapshots().map(
          (doc) => doc.exists
              ? BabysitterProfile.fromFirestore(doc.id, doc.data()!)
              : null,
        );
  }

  /// One-time fetch for a babysitter profile.
  /// Falls back to static data if not found in database.
  Future<BabysitterProfile?> getBabysitter(String uid) async {
    // Check if it's a static ID
    if (uid.startsWith('static_')) {
      final staticBabysitters = StaticBabysitterData.getMockBabysitters();
      try {
        return staticBabysitters.firstWhere((p) => p.id == uid);
      } catch (_) {
        return staticBabysitters.first;
      }
    }

    try {
      final doc = await _firestore.collection('babysitters').doc(uid).get();
      if (doc.exists) {
        return BabysitterProfile.fromFirestore(doc.id, doc.data()!);
      }
    } catch (_) {
      // On error, try static data
    }
    
    // Fallback to static data if not found
    final staticBabysitters = StaticBabysitterData.getMockBabysitters();
    if (staticBabysitters.isNotEmpty) {
      return staticBabysitters.first;
    }
    return null;
  }

  /// Update real-time availability (parents see this live).
  Future<void> updateAvailability(String uid, bool isAvailableNow) async {
    await _firestore.collection('babysitters').doc(uid).update({
      'isAvailableNow': isAvailableNow,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Save or update full babysitter profile. Preserves existing ratings when updating.
  Future<void> saveProfile({
    required String uid,
    required String name,
    String? experience,
    String? skills,
    String? pricePerHour,
    String? availability,
    bool backgroundVerified = false,
  }) async {
    final ref = _firestore.collection('babysitters').doc(uid);
    bool exists = false;
    try {
      final existing = await ref.get();
      exists = existing.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.toLowerCase().contains('offline') == true) {
        try {
          final cached = await ref.get(const GetOptions(source: Source.cache));
          exists = cached.exists;
        } catch (_) {
          // Assume new profile if we can't read
        }
      } else {
        rethrow;
      }
    }
    final data = <String, dynamic>{
      'name': name,
      'experience': experience ?? '',
      'skills': skills ?? '',
      'pricePerHour': pricePerHour ?? '',
      'availability': availability ?? '',
      'backgroundVerified': backgroundVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!exists) {
      data['ratingAverage'] = 0;
      data['ratingCount'] = 0;
      data['isAvailableNow'] = false;
    }
    await ref.set(data, SetOptions(merge: true));
  }
}
