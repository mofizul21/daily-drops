import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const ProfileAvatar({super.key, this.imageUrl, this.radius = 30, this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
          ? NetworkImage(imageUrl!)
          : const AssetImage('assets/images/user_icon.png') as ImageProvider,
      onBackgroundImageError: (_, __) {},
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: avatar,
      );
    }

    return avatar;
  }
}
