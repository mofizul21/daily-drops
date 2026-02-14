import 'package:flutter/material.dart';
import 'package:daily_drop/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_drop/includes/constants.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final AuthService _authService = authService.value;
  User? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _nameController.text = _currentUser!.displayName ?? '';
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getUserData();
    if (userData != null) {
      setState(() {
        _selectedGender = userData['gender'];
        if (userData['dateOfBirth'] != null) {
          _selectedDateOfBirth = (userData['dateOfBirth'] as Timestamp)
              .toDate();
          _dateController.text = _selectedDateOfBirth!
              .toLocal()
              .toString()
              .split(' ')[0];
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
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

  String _generateGravatarUrl(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final emailHash = md5.convert(utf8.encode(normalizedEmail)).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=200&d=identicon';
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('Name cannot be empty', isError: true);
      return;
    }
    if (_selectedGender == null) {
      _showSnackBar('Please select your gender', isError: true);
      return;
    }
    if (_selectedDateOfBirth == null) {
      _showSnackBar('Please select your birth date', isError: true);
      return;
    }

    String? gravatarUrl;
    if (_currentUser?.email != null) {
      gravatarUrl = _generateGravatarUrl(_currentUser!.email!);
    }

    try {
      String authResult = await _authService.updateProfile(
        _nameController.text,
        gravatarUrl ?? '',
      );

      if (authResult != 'success') {
        _showSnackBar(
          'Failed to update profile (Auth): $authResult',
          isError: true,
        );
        return;
      }

      Map<String, dynamic> userData = {
        'gender': _selectedGender,
        'dateOfBirth': _selectedDateOfBirth != null
            ? Timestamp.fromDate(_selectedDateOfBirth!)
            : null,
      };
      String firestoreResult = await _authService.saveUserData(userData);

      if (firestoreResult == 'success') {
        await _currentUser?.reload();
        setState(() {
          _currentUser = _auth.currentUser;
        });
        _showSnackBar('Profile updated successfully!');
        Navigator.of(context).pop(true);
      } else {
        _showSnackBar(
          'Failed to update profile (Firestore): $firestoreResult',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('An unexpected error occurred: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (_currentUser?.email != null) {
      profileImage = NetworkImage(_generateGravatarUrl(_currentUser!.email!));
    } else {
      profileImage = const AssetImage('assets/images/user_icon.png');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 60, backgroundImage: profileImage),
            const SizedBox(height: 10),
            Text(
              'Profile photo is loading from Gravatar.',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: <String>['Male', 'Female', 'Other', 'Prefer not to say']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateOfBirth ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDateOfBirth = pickedDate;
                    _dateController.text = pickedDate
                        .toLocal()
                        .toString()
                        .split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateProfile,
              style: CommonStyles.primaryButtonStyle.copyWith(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue.shade700,
                ),
              ),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
