import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(
  AuthService(),
);

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Method to save additional user data to Firestore
  Future<String> saveUserData(Map<String, dynamic> userData) async {
    print('[AuthService.saveUserData] Method started.');
    try {
      if (currentUser == null) {
        print('[AuthService.saveUserData] No user logged in. Returning.');
        return 'No user logged in.';
      }
      print('[AuthService.saveUserData] Attempting to save data for UID: ${currentUser!.uid} with data: $userData');
      await _firestore.collection('users').doc(currentUser!.uid).set(userData, SetOptions(merge: true));
      print('[AuthService.saveUserData] Data successfully saved to Firestore. Returning "success".');
      return 'success';
    } catch (e) {
      print('[AuthService.saveUserData] Error saving data to Firestore: $e. Returning error string.');
      return e.toString();
    }
  }

  // Method to get additional user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (currentUser == null) {
        return null;
      }
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
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
