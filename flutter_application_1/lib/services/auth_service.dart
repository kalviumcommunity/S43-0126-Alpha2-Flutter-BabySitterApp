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

  // GET USER ROLE
  Future<String?> getUserRole() async {
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(uid).get();

    return doc["role"];
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
