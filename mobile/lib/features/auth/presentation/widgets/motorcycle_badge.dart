import 'package:flutter/material.dart';
import '../theme/auth_colors.dart';

/// Glowing circular amber badge with tactical motorcycle emblem
class MotorcycleBadge extends StatelessWidget {
  const MotorcycleBadge({
    super.key,
    this.size = 62,
    this.iconSize = 30,
  });

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AuthColors.orangeBadgeBg,
        shape: BoxShape.circle,
        border: Border.all(
          color: AuthColors.orangeBadgeBorder,
          width: 1.8,
        ),
        boxShadow: AuthColors.badgeGlow,
      ),
      child: Center(
        child: Icon(
          Icons.two_wheeler_rounded,
          color: AuthColors.orangeLight,
          size: iconSize,
        ),
      ),
    );
  }
}
