import 'package:daily_drop/widgets/post_box.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Drop> _sampleDrops = [
    Drop(
      userName: 'John Doe',
      userIconUrl: 'assets/images/user_icon.png', // Example image
      dropText:
          'Had a great productive morning working on my side project! #coding #flutter',
      loveCount: 32,
      ashLoveCount: 5,
    ),
    Drop(
      userName: 'Jane Smith',
      userIconUrl: 'assets/images/user_icon.png',
      dropText:
          'Enjoyed a relaxing evening with a good book. Sometimes you just need to unwind.',
      loveCount: 18,
      ashLoveCount: 2,
    ),
    Drop(
      userName: 'Peter Jones',
      userIconUrl: 'assets/images/user_icon.png',
      dropText:
          'Finally finished that difficult task at work. Feeling accomplished!',
      loveCount: 45,
      ashLoveCount: 10,
    ),
    Drop(
      userName: 'Alice Brown',
      userIconUrl: 'assets/images/user_icon.png',
      dropText:
          'Discovered a new cafe with amazing coffee! Highly recommend it.',
      loveCount: 21,
      ashLoveCount: 3,
    ),
    Drop(
      userName: 'Bob White',
      userIconUrl: 'assets/images/user_icon.png',
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
        title: Text(
          "Today's Drop",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16.0),
          Padding( // Added Padding here
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: PostBox(),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "Today's Drops",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ..._sampleDrops
              .map(
                (drop) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropCard(drop: drop),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
