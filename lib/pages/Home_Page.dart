import 'package:daily_drop/widgets/post_box.dart';
import 'package:flutter/material.dart';
import '../models/drop.dart';
import '../widgets/drop_card.dart';
import '../services/drop_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          "Today's Drop",
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

          final drops = snapshot.data ?? [];

          return ListView(
            children: [
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: PostBox(
                  editDrop: _editDrop,
                  onUpdate: (drop) {},
                  onCancelEdit: _handleCancelEdit,
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Today's Drops",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              if (drops.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No drops yet. Be the first to share!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ...drops
                    .map(
                      (drop) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropCard(
                          drop: drop,
                          onEdit: _handleEdit,
                        ),
                      ),
                    )
                    .toList(),
            ],
          );
        },
      ),
    );
  }
}
