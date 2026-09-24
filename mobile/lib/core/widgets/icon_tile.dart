import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Icon Tile
/// Rounded-square soft skeuomorphic container for outlined icons.
/// Supports both recessed (inset) and raised tactile styles.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    super.key,
    this.size = 40,
    this.iconSize,
    this.iconColor = AppColors.darkCharcoal,
    this.isInset = true,
    this.borderRadius = 13,
    this.backgroundColor,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Color iconColor;
  final bool isInset;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (size * 0.48);

    final container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isInset ? AppColors.clayDark : AppColors.clay),
        borderRadius: BorderRadius.circular(borderRadius),
        border: isInset
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1,
              )
            : null,
        boxShadow: isInset ? AppColors.skeuRecessed : AppColors.skeuRaisedSmall,
      ),
      child: Center(
        child: Icon(
          icon,
          size: effectiveIconSize,
          color: iconColor,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}
