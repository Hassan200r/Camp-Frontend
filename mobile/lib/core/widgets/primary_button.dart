import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Primary Button
/// Extruded tactical orange pill button with gradient, white bold text, and [AppColors.orangeGlow].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    super.key,
    this.onTap,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.borderRadius = AppColors.radiusPill,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
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
        ),
        boxShadow: AppColors.orangeGlow,
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: isFullWidth ? SizedBox(width: double.infinity, child: content) : content,
    );
  }
}
