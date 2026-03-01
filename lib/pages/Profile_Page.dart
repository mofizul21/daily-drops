import 'package:daily_drop/auth/auth_wrapper.dart';
import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/pages/delete_account.dart';
import 'package:daily_drop/pages/edit_profile_page.dart';
import 'package:daily_drop/pages/update_email.dart';
import 'package:daily_drop/pages/update_password.dart';
import 'package:daily_drop/widgets/post_box.dart';
import 'package:daily_drop/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_drop/auth/auth_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/drop_service.dart';

class ProfilePage extends StatefulWidget {
  final String? viewUserId;
  final String? viewUserName;
  final String? viewUserIconUrl;

  const ProfilePage({
    super.key,
    this.viewUserId,
    this.viewUserName,
    this.viewUserIconUrl,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DropService _dropService = DropService();
  User? _currentUser;
  String? _userGender;
  DateTime? _userDateOfBirth;
  Drop? _editDrop;
  Map<String, dynamic>? _viewUserData;
  int _viewUserDropCount = 0;

  // Check if viewing another user's profile
  bool get _isViewingOtherUser => widget.viewUserId != null;
  String get _displayUserId => widget.viewUserId ?? _currentUser!.uid;
  String get _displayUserName =>
      widget.viewUserName ?? _currentUser?.displayName ?? "User Name";
  String get _displayUserIconUrl =>
      widget.viewUserIconUrl ?? _currentUser?.photoURL ?? '';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    if (!_isViewingOtherUser) {
      _loadUserData();
    } else {
      _loadViewUserData();
    }
  }

  Future<void> _loadViewUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_displayUserId)
        .get();
    if (doc.exists) {
      setState(() {
        _viewUserData = doc.data();
      });
    }

    final dropsSnapshot = await FirebaseFirestore.instance
        .collection('drops')
        .where('userId', isEqualTo: _displayUserId)
        .get();
    setState(() {
      _viewUserDropCount = dropsSnapshot.docs.length;
    });
  }

  void _handleEdit(Drop drop) {
    setState(() {
      _editDrop = drop;
    });
  }

  void _handleCancelEdit() {
    setState(() {
      _editDrop = null;
    });
  }

  Future<void> _loadUserData() async {
    final userData = await authService.value.getUserData();
    if (userData != null) {
      setState(() {
        _userGender = userData['gender'];
        if (userData['dateOfBirth'] != null) {
          _userDateOfBirth = (userData['dateOfBirth'] as Timestamp).toDate();
        }
        _viewUserData = userData;
      });
    }
    
    // Load streak
    final streak = await _dropService.getUserStreak(_currentUser!.uid);
    setState(() {
      if (_viewUserData == null) {
        _viewUserData = {'streak': streak};
      } else {
        _viewUserData!['streak'] = streak;
      }
    });
  }

  String _generateGravatarUrl(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final emailHash = md5.convert(utf8.encode(normalizedEmail)).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=200&d=identicon';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Builder(
            builder: (BuildContext innerContext) {
              return IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Scaffold.of(innerContext).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(_currentUser?.displayName ?? "User Name"),
              accountEmail: Text(_currentUser?.email ?? "user@example.com"),
              currentAccountPicture: ProfileAvatar(
                imageUrl: _currentUser?.email != null
                    ? _generateGravatarUrl(_currentUser!.email!)
                    : null,
                radius: 40,
              ),
              decoration: BoxDecoration(color: Colors.blue.shade900),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Profile'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilePage(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    _currentUser = _auth.currentUser;
                    _loadUserData();
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Update Email'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateEmailPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Update Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdatePasswordPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Account'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeleteAccountPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                String signOutResult = await authService.value.signOut();
                if (signOutResult == 'success') {
                  selectedPageNotifier.value = 0;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthWrapper(),
                    ),
                    (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $signOutResult'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.blue.shade900),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProfileAvatar(
                  imageUrl: _isViewingOtherUser
                      ? (_displayUserIconUrl.isNotEmpty
                            ? _displayUserIconUrl
                            : null)
                      : (_currentUser?.email != null
                            ? _generateGravatarUrl(_currentUser!.email!)
                            : null),
                  radius: 40,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayUserName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Streak:',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade200,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            '${_viewUserData?['streak'] ?? 0} days',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                // Show PostBox for own profile or when editing
                if (!_isViewingOtherUser || _editDrop != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: PostBox(
                      editDrop: _editDrop,
                      onUpdate: (drop) {},
                      onCancelEdit: _handleCancelEdit,
                    ),
                  ),
                Expanded(
                  child: StreamBuilder<List<Drop>>(
                    stream: _dropService.getUserDrops(_displayUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final drops = snapshot.data ?? [];

                      if (drops.isEmpty) {
                        return Center(
                          child: Text(
                            _isViewingOtherUser
                                ? "No drops yet."
                                : "You haven't posted any drops yet.",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: drops.length,
                        itemBuilder: (context, index) {
                          final drop = drops[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: DropCard(drop: drop, onEdit: _handleEdit),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
