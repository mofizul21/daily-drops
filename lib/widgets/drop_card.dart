import 'package:flutter/material.dart';
import '../models/drop.dart';

class DropCard extends StatefulWidget { // Changed to StatefulWidget
  final Drop drop;

  const DropCard({Key? key, required this.drop}) : super(key: key);

  @override
  State<DropCard> createState() => _DropCardState();
}

class _DropCardState extends State<DropCard> with TickerProviderStateMixin { // Added TickerProviderStateMixin
  late AnimationController _loveAnimationController;
  late Animation<double> _loveAnimation;

  late AnimationController _ashLoveAnimationController;
  late Animation<double> _ashLoveAnimation;

  @override
  void initState() {
    super.initState();

    _loveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Shorter duration for quick pop
      reverseDuration: const Duration(milliseconds: 400), // Longer duration to return
    );
    _loveAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _loveAnimationController, curve: Curves.easeOut),
    );

    _ashLoveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _ashLoveAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _ashLoveAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _loveAnimationController.dispose();
    _ashLoveAnimationController.dispose();
    super.dispose();
  }

  void _playLoveAnimation() {
    _loveAnimationController.forward().then((_) {
      _loveAnimationController.reverse();
    });
  }

  void _playAshLoveAnimation() {
    _ashLoveAnimationController.forward().then((_) {
      _ashLoveAnimationController.reverse();
    });
  }

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
                backgroundImage: NetworkImage(widget.drop.userIconUrl), // Use widget.drop
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.drop.userName, // Use widget.drop
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        print('Selected: $value for ${widget.drop.userName}'); // Use widget.drop
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
          Text(widget.drop.dropText, style: const TextStyle(fontSize: 16)), // Use widget.drop
          const SizedBox(height: 10),
          // Love Emojis
          Row(
            children: [
              InkWell(
                onTap: () {
                  _playLoveAnimation();
                  print(
                    'Red heart tapped for ${widget.drop.userName}. Current count: ${widget.drop.loveCount}',
                  );
                },
                child: AnimatedBuilder( // Wrap with AnimatedBuilder
                  animation: _loveAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _loveAnimation.value,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('❤️'),
                      const SizedBox(width: 4),
                      Text('${widget.drop.loveCount}'), // Use widget.drop
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  _playAshLoveAnimation();
                  print(
                    'Ash heart tapped for ${widget.drop.userName}. Current count: ${widget.drop.ashLoveCount}',
                  );
                },
                child: AnimatedBuilder( // Wrap with AnimatedBuilder
                  animation: _ashLoveAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _ashLoveAnimation.value,
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🩶'),
                      const SizedBox(width: 4),
                      Text('${widget.drop.ashLoveCount}'), // Use widget.drop
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
