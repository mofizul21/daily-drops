import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(
  AuthService(),
);

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthService() {
    _googleSignIn.initialize(
      serverClientId:
          '1003232898338-5214201507655615809.apps.googleusercontent.com',
    );
  }

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Method to save additional user data to Firestore
  Future<String> saveUserData(Map<String, dynamic> userData) async {
    try {
      if (currentUser == null) {
        return 'No user logged in.';
      }
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .set(userData, SetOptions(merge: true));
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // Method to get additional user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) {
        return null;
      }
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> signInWithEmailPassword(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }

  Future<String> signUpWithEmailPassword(String email, String password) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }

  Future<String> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Get the auth tokens
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return 'Failed to obtain ID token.';
      }

      // Get access token from authorization client
      String? accessToken;
      final authClient = googleUser.authorizationClient;
      final authorization = await authClient.authorizeScopes(['email', 'profile']);
      accessToken = authorization.accessToken;

      // Create a credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase with the Google credentials
      await firebaseAuth.signInWithCredential(credential);
      return 'success';
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return 'Google Sign-In cancelled. Please try again.';
      }
      return 'Google Sign-In failed: ${e.description ?? 'Unknown error'}';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong during Google Sign-In.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signOut() async {
    await firebaseAuth.signOut();
    return 'success';
  }

  Future<String> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }

  Future<String> updatePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }

  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    final user = currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  Future<String> updateProfile(String name, String photoUrl) async {
    try {
      await currentUser?.updateProfile(displayName: name, photoURL: photoUrl);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }

  Future<String> deleteAccount() async {
    try {
      await currentUser?.delete();
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Something went wrong';
    }
  }
}
