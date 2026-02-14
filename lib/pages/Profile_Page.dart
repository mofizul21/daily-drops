import 'package:daily_drop/includes/constants.dart';
import 'package:daily_drop/pages/delete_account.dart';
import 'package:daily_drop/pages/login_page.dart';
import 'package:daily_drop/pages/update_email.dart';
import 'package:daily_drop/pages/update_password.dart';
import 'package:daily_drop/pages/update_password.dart';
import 'package:daily_drop/pages/delete_account.dart';
import 'package:daily_drop/widget_tree.dart';
import 'package:daily_drop/widgets/bottom_navigation.dart';
import 'package:daily_drop/widgets/post_box.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth
  User? _currentUser; // Current logged-in user

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Get current user when the state initializes
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
                backgroundImage: _currentUser?.photoURL != null
                    ? NetworkImage(_currentUser!.photoURL!)
                    : const AssetImage('assets/images/user_icon.png')
                        as ImageProvider, // Default user icon
              ),
              decoration: BoxDecoration(color: Colors.blue.shade900),
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
            const Divider(), // Add a divider for separation
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Close the drawer
                Navigator.pop(context);
                String signOutResult = await authService.value.signOut();
                if (signOutResult == 'success') {
                  // Reset selectedPageNotifier to 0 (LoginPage)
                  selectedPageNotifier.value = 0;
                  // Navigate to AuthWrapper, which will then show LoginPage
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
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
                  backgroundImage: _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
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
