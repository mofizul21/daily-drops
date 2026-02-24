import 'package:daily_drop/auth/auth_service.dart';
import 'package:daily_drop/pages/login_page.dart';
import 'package:daily_drop/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final User? user = snapshot.data;

        // Check if user is verified
        final bool isVerified = user?.emailVerified ?? false;

        if (user != null && isVerified) {
          return const WidgetTree();
        }

        return const LoginPage();
      },
    );
  }
}
