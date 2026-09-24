import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Raised Card
/// Skeuomorphic tactile card utilizing [AppColors.clay], [AppColors.radiusCard],
/// and [AppColors.skeuRaised] dual-shadow elevation.
class CampCard extends StatelessWidget {
  const CampCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(AppColors.cardPadding),
    this.borderRadius = AppColors.radiusCard,
    this.color,
    this.shadows,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final List<BoxShadow>? shadows;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color ?? AppColors.clay,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppColors.skeuRaised,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
