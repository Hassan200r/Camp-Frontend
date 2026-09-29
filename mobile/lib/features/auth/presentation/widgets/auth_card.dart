import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/auth_colors.dart';

/// Glassmorphism frosted dark card container matching the screenshots
class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AuthColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AuthColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: AuthColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
