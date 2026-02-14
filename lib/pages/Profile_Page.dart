import 'package:daily_drop/auth/auth_wrapper.dart';
import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/pages/delete_account.dart';
import 'package:daily_drop/pages/edit_profile_page.dart';
import 'package:daily_drop/pages/update_email.dart';
import 'package:daily_drop/pages/update_password.dart';
import 'package:daily_drop/widgets/post_box.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_drop/auth/auth_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  String? _userGender;
  DateTime? _userDateOfBirth;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await authService.value.getUserData();
    if (userData != null) {
      setState(() {
        _userGender = userData['gender'];
        if (userData['dateOfBirth'] != null) {
          _userDateOfBirth = (userData['dateOfBirth'] as Timestamp).toDate();
        }
      });
    }
  }

  String _generateGravatarUrl(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final emailHash = md5.convert(utf8.encode(normalizedEmail)).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=200&d=identicon';
  }

  final List<Drop> _sampleDrops = [
    Drop(
      userName: 'John Doe',
      userIconUrl:
          'https://via.placeholder.com/80/0000FF/FFFFFF?text=JD', // Example image
      dropText:
          'Had a great productive morning working on my side project! #coding #flutter',
      loveCount: 32,
      ashLoveCount: 5,
    ),
    Drop(
      userName: 'Jane Smith',
      userIconUrl: 'https://via.placeholder.com/80/FF0000/FFFFFF?text=JS',
      dropText:
          'Enjoyed a relaxing evening with a good book. Sometimes you just need to unwind.',
      loveCount: 18,
      ashLoveCount: 2,
    ),
    Drop(
      userName: 'Peter Jones',
      userIconUrl: 'https://via.placeholder.com/80/00FF00/FFFFFF?text=PJ',
      dropText:
          'Finally finished that difficult task at work. Feeling accomplished!',
      loveCount: 45,
      ashLoveCount: 10,
    ),
    Drop(
      userName: 'Alice Brown',
      userIconUrl: 'https://via.placeholder.com/80/FFFF00/000000?text=AB',
      dropText:
          'Discovered a new cafe with amazing coffee! Highly recommend it.',
      loveCount: 21,
      ashLoveCount: 3,
    ),
    Drop(
      userName: 'Bob White',
      userIconUrl: 'https://via.placeholder.com/80/FFA500/FFFFFF?text=BW',
      dropText:
          'Went for a long walk and cleared my head. Nature always helps.',
      loveCount: 28,
      ashLoveCount: 7,
    ),
  ];

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
              currentAccountPicture: CircleAvatar(
                backgroundImage: _currentUser?.email != null
                    ? NetworkImage(_generateGravatarUrl(_currentUser!.email!))
                    : const AssetImage('assets/images/user_icon.png')
                          as ImageProvider,
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
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _currentUser?.email != null
                      ? NetworkImage(_generateGravatarUrl(_currentUser!.email!))
                      : const AssetImage('assets/images/user_icon.png')
                            as ImageProvider, // Default user icon
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser?.displayName ?? "User Name",
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
                          child: const Text(
                            '4 days',
                            style: TextStyle(color: Colors.black, fontSize: 16),
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
            child: ListView.builder(
              itemCount: _sampleDrops.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                    child: PostBox(),
                  );
                }
                final drop = _sampleDrops[index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropCard(drop: drop),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
