import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier<AuthService>(
  AuthService(),
);

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

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
