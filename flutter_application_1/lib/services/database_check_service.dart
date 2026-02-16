import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to check if Firestore database is accessible and properly configured.
class DatabaseCheckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if Firestore is accessible by attempting a simple read operation.
  Future<Map<String, dynamic>> checkDatabaseConnection() async {
    final result = <String, dynamic>{
      'isConnected': false,
      'projectId': '',
      'collections': <String>[],
      'error': null,
      'userCount': 0,
      'babysitterCount': 0,
    };

    try {
      // Get project info
      result['projectId'] = _firestore.app.options.projectId;

      // Try to read from users collection (should exist if database is set up)
      try {
        final usersSnapshot = await _firestore.collection('users').limit(1).get();
        result['userCount'] = usersSnapshot.size;
        result['collections'].add('users');
      } catch (e) {
        result['error'] = 'Cannot access users collection: $e';
      }

      // Try to read from babysitters collection
      try {
        final babysittersSnapshot = await _firestore.collection('babysitters').limit(1).get();
        result['babysitterCount'] = babysittersSnapshot.size;
        result['collections'].add('babysitters');
      } catch (e) {
        if (result['error'] == null) {
          result['error'] = 'Cannot access babysitters collection: $e';
        } else {
          result['error'] = '${result['error']}\nCannot access babysitters collection: $e';
        }
      }

      // If we got here without exceptions, database is accessible
      result['isConnected'] = true;
    } catch (e) {
      result['error'] = 'Database connection failed: $e';
      result['isConnected'] = false;
    }

    return result;
  }

  /// Get current user info if logged in
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return {
        'uid': user.uid,
        'email': user.email,
        'hasUserDoc': userDoc.exists,
        'userData': userDoc.data(),
      };
    } catch (e) {
      return {
        'uid': user.uid,
        'email': user.email,
        'error': e.toString(),
      };
    }
  }
}
