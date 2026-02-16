import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

/// Service for uploading verification documents to Firebase Storage.
class VerificationService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a verification document (ID, certificate, etc.)
  Future<String> uploadVerificationDocument({
    required dynamic file, // File on mobile, PlatformFile on web
    required String documentType, // e.g., 'id', 'background_check', 'certificate'
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fileName = '${user.uid}_${documentType}_${DateTime.now().millisecondsSinceEpoch}';
    final ref = _storage.ref().child('verifications/${user.uid}/$fileName');

    try {
      if (kIsWeb) {
        // Web: use bytes
        final PlatformFile platformFile = file as PlatformFile;
        await ref.putData(
          platformFile.bytes!,
          SettableMetadata(contentType: platformFile.extension == 'pdf' ? 'application/pdf' : 'image/jpeg'),
        );
      } else {
        // Mobile: use File
        final File fileObj = file as File;
        await ref.putFile(fileObj);
      }
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Upload multiple verification documents and save URLs to Firestore
  Future<void> saveVerificationDocuments({
    required Map<String, String> documentUrls, // {type: url}
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('babysitters').doc(user.uid).update({
      'verificationDocuments': documentUrls,
      'verificationUploadedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get verification document URLs for a babysitter
  Future<Map<String, String>?> getVerificationDocuments(String babysitterId) async {
    final doc = await _firestore.collection('babysitters').doc(babysitterId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    
    final docs = data['verificationDocuments'];
    if (docs is Map) {
      return Map<String, String>.from(docs);
    }
    return null;
  }
}
