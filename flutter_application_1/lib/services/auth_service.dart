import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection("users").doc(userCred.user!.uid).set({
        "name": name,
        "email": email,
        "role": role,
        "createdAt": Timestamp.now(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // GET USER ROLE (returns null if doc missing or role field missing)
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Try server first
      final doc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      
      if (doc.exists && doc.data() != null) {
        final role = doc.get("role");
        return role is String ? role.trim().toLowerCase() : null;
      }
      // Document doesn't exist - return null (user needs to sign up)
      return null;
    } on FirebaseException catch (e) {
      // If server fails with offline/unavailable, try cache
      if (e.code == 'unavailable' || 
          e.code == 'deadline-exceeded' ||
          e.message?.toLowerCase().contains('offline') == true ||
          e.message?.toLowerCase().contains('failed to get document') == true ||
          e.message?.toLowerCase().contains('network') == true) {
        try {
          final cachedDoc = await _firestore
              .collection("users")
              .doc(user.uid)
              .get(const GetOptions(source: Source.cache));
          
          if (cachedDoc.exists && cachedDoc.data() != null) {
            final role = cachedDoc.get("role");
            return role is String ? role.trim().toLowerCase() : null;
          }
          // Document doesn't exist in cache either - return null
          return null;
        } catch (_) {
          // Cache read also failed - return null (don't throw)
          return null;
        }
      }
      // For permission errors or other Firebase errors, return null
      // Let the UI handle it gracefully
      return null;
    } catch (_) {
      // Any other error - return null instead of throwing
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
