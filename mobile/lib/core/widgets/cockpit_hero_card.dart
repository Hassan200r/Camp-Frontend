import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Cockpit Hero Card Container
/// Features the signature dark espresso cockpit gradient wrapped in a tactile skeuomorphic clay bezel ring.
/// Permitted exclusively on Home and Profile screens per design specifications.
class CockpitHeroCard extends StatelessWidget {
  const CockpitHeroCard({
    required this.child,
    super.key,
    this.padding = EdgeInsets.zero,
    this.innerPadding,
    this.borderRadius = AppColors.radiusCard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? innerPadding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(borderRadius + 2),
        boxShadow: AppColors.cockpitBezel,
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        padding: innerPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cockpitGradientStart,
              AppColors.cockpitGradientMid,
              AppColors.cockpitGradientEnd,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
