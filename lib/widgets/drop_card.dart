import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/drop.dart';
import '../services/drop_service.dart';
import '../pages/profile_page.dart';
import 'profile_avatar.dart';

class DropCard extends StatefulWidget {
  final Drop drop;
  final Function(Drop)? onEdit;

  const DropCard({Key? key, required this.drop, this.onEdit}) : super(key: key);

  @override
  State<DropCard> createState() => _DropCardState();
}

class _DropCardState extends State<DropCard> with TickerProviderStateMixin {
  final DropService _dropService = DropService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AnimationController _loveAnimationController;
  late Animation<double> _loveAnimation;

  late AnimationController _ashLoveAnimationController;
  late Animation<double> _ashLoveAnimation;

  bool _isOwner = false;

  String? get _userReaction {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null && widget.drop.reactions.containsKey(currentUserId)) {
      return widget.drop.reactions[currentUserId];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _checkOwnership();

    _loveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 400),
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

  void _checkOwnership() {
    final currentUserId = _auth.currentUser?.uid;
    setState(() {
      _isOwner = currentUserId != null && currentUserId == widget.drop.userId;
    });
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

  Future<void> _handleLoveTap() async {
    _playLoveAnimation();
    if (widget.drop.id != null) {
      await _dropService.toggleLoveReaction(widget.drop.id!, widget.drop);
    }
  }

  Future<void> _handleAshLoveTap() async {
    _playAshLoveAnimation();
    if (widget.drop.id != null) {
      await _dropService.toggleAshLoveReaction(widget.drop.id!, widget.drop);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drop'),
        content: const Text('Are you sure you want to delete this drop?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.drop.id != null) {
      final result = await _dropService.deleteDrop(widget.drop.id!);
      if (result == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Drop deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $result'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleEdit() {
    if (widget.onEdit != null) {
      widget.onEdit!(widget.drop);
    }
  }

  void _handleReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The drop has been reported.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleBlock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The user has been blocked.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navigateToUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          viewUserId: widget.drop.userId,
          viewUserName: widget.drop.userName,
          viewUserIconUrl: widget.drop.userIconUrl,
        ),
      ),
    );
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
              InkWell(
                onTap: _navigateToUserProfile,
                child: ProfileAvatar(
                  imageUrl: widget.drop.userIconUrl.isNotEmpty
                      ? widget.drop.userIconUrl
                      : null,
                  radius: 30,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: _navigateToUserProfile,
                      child: Text(
                        widget.drop.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _handleEdit();
                        } else if (value == 'delete') {
                          _handleDelete();
                        } else if (value == 'report') {
                          _handleReport();
                        } else if (value == 'block') {
                          _handleBlock();
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        if (_isOwner) {
                          return <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        } else {
                          return <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'report',
                              child: Text('Report'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'block',
                              child: Text('Block'),
                            ),
                          ];
                        }
                      },
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
                onTap: _handleLoveTap,
                child: AnimatedBuilder(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: _userReaction == 'love'
                            ? BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: const Text('❤️'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.drop.loveCount}',
                        style: _userReaction == 'love'
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: _handleAshLoveTap,
                child: AnimatedBuilder(
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: _userReaction == 'ash'
                            ? BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              )
                            : null,
                        child: const Text('🩶'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.drop.ashLoveCount}',
                        style: _userReaction == 'ash'
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              )
                            : null,
                      ),
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
