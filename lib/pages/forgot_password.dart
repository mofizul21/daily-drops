import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:daily_drop/includes/constants.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white), // AppBar title to white
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // Back button color
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              child: Lottie.asset(
                'assets/lotties/register_page_bg.json', // Corrected Lottie asset
                fit: BoxFit.cover,
                repeat: true,
                reverse: true,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Reset Your Password',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white), // Welcome back text to white
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white), // Input text color
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70), // Label text color
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1), // Translucent fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70), // Border color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white70), // Border color when enabled
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white), // Border color when focused
                      ),
                      prefixIcon: const Icon(Icons.email, color: Colors.white70), // Prefix icon color
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement forgot password logic
                      print('Reset password for: ${_emailController.text}');
                    },
                    style: CommonStyles.primaryButtonStyle.copyWith(
                      // Override primaryButtonStyle for this button
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent), // Text color for login button
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // Background for login button
                    ),
                    child: const Text('Send Reset Link'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
