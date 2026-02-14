import 'package:daily_drop/auth/auth_service.dart';
import 'package:daily_drop/pages/login_page.dart';
import 'package:daily_drop/widget_tree.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.value.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return WidgetTree();
        }
        return const LoginPage();
      },
    );
  }
}
