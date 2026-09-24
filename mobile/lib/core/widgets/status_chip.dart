import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// Supported variants for [StatusChip]
enum StatusChipVariant {
  success,
  warning,
  danger,
  neutral,
  gold,
}

/// CAMP Status Chip
/// Pill badge representing health, alerts, modes, and telemetry status.
/// Guaranteed single-line display with no wrapping.
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    super.key,
    this.variant = StatusChipVariant.neutral,
    this.icon,
    this.showDot = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  });

  final String label;
  final StatusChipVariant variant;
  final IconData? icon;
  final bool showDot;
  final EdgeInsetsGeometry padding;

  Color get _textColor {
    switch (variant) {
      case StatusChipVariant.success:
        return AppColors.statusGreen;
      case StatusChipVariant.warning:
        return AppColors.tacticalOrangeDark;
      case StatusChipVariant.danger:
        return AppColors.alertRed;
      case StatusChipVariant.gold:
        return const Color(0xFFD97706);
      case StatusChipVariant.neutral:
        return AppColors.darkCharcoal;
    }
  }

  Color get _backgroundColor {
    switch (variant) {
      case StatusChipVariant.success:
        return const Color(0xFFDCFCE7);
      case StatusChipVariant.warning:
        return const Color(0xFFFFEDD5);
      case StatusChipVariant.danger:
        return AppColors.alertRedBg;
      case StatusChipVariant.gold:
        return const Color(0xFFFEF3C7);
      case StatusChipVariant.neutral:
        return AppColors.clayDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _textColor;
    final bg = _backgroundColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppColors.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: fg,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
