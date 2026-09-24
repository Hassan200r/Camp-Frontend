import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Reusable raised skeuomorphic container.
/// Renders the classic dual-shadow convex "extruded clay" look.
class SkeuomorphicContainer extends StatelessWidget {
  const SkeuomorphicContainer({
    required this.child,
    super.key,
    this.borderRadius = AppColors.radiusCard,
    this.color,
    this.padding,
    this.shadows,
  });

  final Widget child;
  final double borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.clay,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppColors.skeuRaised,
      ),
      child: child,
    );
  }
}

/// Recessed / inset variant — used for voice input bars and search fields.
/// Inverts the shadow direction to simulate a pressed-in surface.
class SkeuomorphicInsetContainer extends StatelessWidget {
  const SkeuomorphicInsetContainer({
    required this.child,
    super.key,
    this.borderRadius = AppColors.radiusTile,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: AppColors.skeuRecessed,
      ),
      child: child,
    );
  }
}

/// Glowing skeuomorphic orange button — extruded with gradient and warm glow.
class SkeuomorphicOrangeButton extends StatelessWidget {
  const SkeuomorphicOrangeButton({
    required this.label,
    super.key,
    this.onTap,
    this.icon,
    this.borderRadius = AppColors.radiusPill,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.tacticalOrangeLight,
              AppColors.tacticalOrange,
              AppColors.tacticalOrangeDark,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          boxShadow: AppColors.orangeGlow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular glowing orange icon button (for arrows / AI trigger)
class SkeuomorphicOrangeIconButton extends StatelessWidget {
  const SkeuomorphicOrangeIconButton({
    required this.icon,
    super.key,
    this.onTap,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tacticalOrangeLight,
              AppColors.tacticalOrange,
              AppColors.tacticalOrangeDark,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: AppColors.orangeGlow,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: size * 0.44),
        ),
      ),
    );
  }
}
