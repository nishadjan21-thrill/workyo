import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ================= SIGN UP =================
  Future<String?> signUp(
    String email,
    String password,
    String phoneNumber,
    String name,
  ) async {
    try {
      // 🔹 Validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        return "Please fill all required fields";
      }

      if (password.length < 6) {
        return "Password must be at least 6 characters";
      }

      // 🔹 Create user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) {
        return "User creation failed. Try again.";
      }

      // 🔹 Save to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phoneNumber.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // ✅ success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "This email is already registered";
        case 'invalid-email':
          return "Invalid email format";
        case 'weak-password':
          return "Password is too weak";
        case 'operation-not-allowed':
          return "Email/password login is disabled";
        case 'network-request-failed':
          return "No internet connection";
        default:
          return e.message ?? "Authentication failed";
      }
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // ================= LOGIN =================
  Future<String?> logIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return "Email and password are required";
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null; // ✅ success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email";
        case 'wrong-password':
          return "Incorrect password";
        case 'invalid-email':
          return "Invalid email format";
        case 'user-disabled':
          return "This account has been disabled";
        case 'network-request-failed':
          return "Check your internet connection";
        default:
          return e.message ?? "Login failed";
      }
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // ================= RESET PASSWORD =================
  Future<String?> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return "Please enter your email";
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      return null; // ✅ success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email";
        case 'invalid-email':
          return "Invalid email format";
        case 'network-request-failed':
          return "Check your internet connection";
        default:
          return e.message ?? "Failed to send reset email";
      }
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
