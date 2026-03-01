import 'package:cloud_firestore/cloud_firestore.dart';
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
      userIconUrl: 'assets/images/user_icon.png', // Example image
      dropText:
          'Had a great productive morning working on my side project! #coding #flutter',
      loveCount: 32,
      ashLoveCount: 5,
      userId: '1',
      id: '1',
      timestamp: Timestamp.now(),
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
