import 'package:flutter/material.dart';
import 'package:daily_drop/auth/auth_service.dart'; // Import AuthService
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class UpdateEmailPage extends StatefulWidget {
  // Renamed class
  const UpdateEmailPage({super.key});

  @override
  State<UpdateEmailPage> createState() => _UpdateEmailPageState();
}

class _UpdateEmailPageState extends State<UpdateEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _confirmNewEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = authService.value; // Get AuthService instance

  @override
  void initState() {
    super.initState();
    // Initialize current email with actual user email
    _currentEmailController.text = _authService.currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _confirmNewEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _updateEmail() async {
    if (_formKey.currentState!.validate()) {
      if (_authService.currentUser == null) {
        _showSnackBar('No user logged in.', isError: true);
        return;
      }

      try {
        await _authService.updateEmail(
          newEmail: _newEmailController.text,
          password: _passwordController.text,
        );
        _showSnackBar(
            'Verification email sent. Please check your inbox to confirm the new email.');
        if (mounted) {
          Navigator.pop(context); // Go back to previous screen (ProfilePage)
        }
      } on FirebaseAuthException catch (e) {
        _showSnackBar('Failed to update email: ${e.message}', isError: true);
      } catch (e) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Email'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Using ListView for scrollability
            children: <Widget>[
              const Text(
                'Please enter your new email address and current password to update your email.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentEmailController,
                readOnly: true, // Typically pre-filled and read-only
                decoration: const InputDecoration(
                  labelText: 'Current Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                // initialValue is not used with a controller, set controller.text in initState
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'New Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmNewEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new email';
                  }
                  if (value != _newEmailController.text) {
                    return 'Emails do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Update Email',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
