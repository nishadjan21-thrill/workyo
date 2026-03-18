import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp(
    String email,
    String password,
    String phoneNumber,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException {
      
      return null;
    }
  }

  Future<User?> logIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      return user;
    } on FirebaseAuthException {
      
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send reset email");
    }
  }
}
