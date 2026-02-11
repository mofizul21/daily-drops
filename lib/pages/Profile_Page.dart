import 'package:daily_drop/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
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
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1a?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80",
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "John Doe",
                      style: TextStyle(
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
                            style: TextStyle(color: Colors.black, fontSize: 16),
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
              itemCount: _sampleDrops.length,
              itemBuilder: (context, index) {
                final drop = _sampleDrops[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropCard(drop: drop),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
