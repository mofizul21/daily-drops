import 'package:daily_drop/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
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
        title: Text(
          "Trending Today",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const Text(
              "Trending Drops",
              textAlign: TextAlign.center,
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
