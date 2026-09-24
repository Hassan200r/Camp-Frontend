import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Inset / Recessed Tile
/// Skeuomorphic sunken surface utilizing [AppColors.clayDark], [AppColors.radiusTile],
/// and [AppColors.skeuRecessed] inverted shadow system.
class InsetTile extends StatelessWidget {
  const InsetTile({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = AppColors.radiusTile,
    this.color,
    this.border,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final BoxBorder? border;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.clayDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1,
            ),
        boxShadow: AppColors.skeuRecessed,
      ),
      child: child,
    );
  }
}
