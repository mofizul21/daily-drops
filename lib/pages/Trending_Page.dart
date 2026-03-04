import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';
import '../services/drop_service.dart';
import '../widgets/post_box.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final DropService _dropService = DropService();
  Drop? _editDrop;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trending Today",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Drop>>(
        stream: _dropService.getAllDrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var drops = snapshot.data ?? [];

          // Sort by total reactions (love + ash)
          drops.sort((a, b) {
            final aReactions = a.reactions.length;
            final bReactions = b.reactions.length;
            return bReactions.compareTo(aReactions);
          });

          // Filter drops with at least 1 reaction
          drops = drops.where((drop) => drop.reactions.isNotEmpty).toList();

          if (drops.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No trending drops yet.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Be the first to react!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              const SizedBox(height: 16.0),
              // PostBox for edit mode
              if (_editDrop != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PostBox(
                    editDrop: _editDrop,
                    onUpdate: (drop) {},
                    onCancelEdit: _handleCancelEdit,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      "Most Reactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...drops.map(
                (drop) {
                  final totalReactions = drop.reactions.length;
                  final loveCount = drop.reactions.values.where((r) => r == 'love').length;
                  final ashCount = drop.reactions.values.where((r) => r == 'ash').length;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropCard(
                          drop: drop,
                          onEdit: _handleEdit,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.trending_up, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Text(
                                '$totalReactions reactions • $loveCount ❤️ • $ashCount 🩶',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
