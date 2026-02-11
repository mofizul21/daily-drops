import 'package:flutter/material.dart';
import '../models/drop.dart';

class DropCard extends StatelessWidget {
  final Drop drop;

  const DropCard({Key? key, required this.drop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(drop.userIconUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      drop.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('Selected: $value for ${drop.userName}');
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'report',
                              child: Text('Report'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'block',
                              child: Text('Block'),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Drop Text
          Text(drop.dropText, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          // Love Emojis
          Row(
            children: [
              const Text('❤️'),
              const SizedBox(width: 4),
              Text('${drop.loveCount}'),
              const SizedBox(width: 16),
              const Text('🩶'),
              const SizedBox(width: 4),
              Text('${drop.ashLoveCount}'),
            ],
          ),
        ],
      ),
    );
  }
}
