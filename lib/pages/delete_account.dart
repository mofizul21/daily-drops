import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/auth/auth_service.dart'; // Import AuthService
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:daily_drop/auth/auth_wrapper.dart'; // Import AuthWrapper for navigation
import 'package:flutter/material.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _confirmDeletion = false;

  final AuthService _authService = authService.value; // Get AuthService instance

  @override
  void dispose() {
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

  Future<void> _deleteAccount() async {
    if (_formKey.currentState!.validate() && _confirmDeletion) {
      if (_authService.currentUser == null) {
        _showSnackBar('No user logged in.', isError: true);
        return;
      }

      // Re-authenticate the user with their current password before deleting the account
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: _authService.currentUser!.email!,
          password: _passwordController.text,
        );
        await _authService.currentUser!.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        _showSnackBar('Re-authentication failed: ${e.message}. Please enter your current password correctly.', isError: true);
        return;
      } catch (e) {
        _showSnackBar('An unexpected error occurred during re-authentication: $e', isError: true);
        return;
      }

      // If re-authentication is successful, proceed with account deletion
      try {
        String deleteResult = await _authService.deleteAccount();

        if (deleteResult == 'success') {
          _showSnackBar('Account deleted successfully!');
          if (mounted) {
            // Clear navigation stack and go to AuthWrapper (which will show LoginPage)
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
              (route) => false,
            );
          }
        } else {
          _showSnackBar('Failed to delete account: $deleteResult', isError: true);
        }
      } on FirebaseAuthException catch (e) {
        _showSnackBar('Failed to delete account: ${e.message}', isError: true);
      } catch (e) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      }
    } else if (!_confirmDeletion) {
      _showSnackBar(
        'Please confirm you understand the deletion consequences.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const Text(
                'WARNING: Deleting your account is a permanent action and cannot be undone. All your data, drops, and interactions will be permanently removed.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter Your Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password to confirm deletion';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                  'I understand that deleting my account is permanent and irreversible.',
                ),
                value: _confirmDeletion,
                onChanged: (bool? value) {
                  setState(() {
                    _confirmDeletion = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete Account',
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
