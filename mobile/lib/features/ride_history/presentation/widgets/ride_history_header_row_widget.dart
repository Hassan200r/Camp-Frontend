import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Widget #1 — "EXPEDITION TELEMETRY ARCHIVE" eyebrow + "Ride History" title
/// + "24 Logged" count badge + circular download icon button on the right.
///
/// SectionHeader already supports a [badge] and an [actionWidget] trailing
/// slot, so this widget wraps SectionHeader rather than duplicating its
/// internal Row/Flexible structure.
class RideHistoryHeaderRowWidget extends StatelessWidget {
  const RideHistoryHeaderRowWidget({
    required this.count,
    super.key,
    this.onDownload,
  });

  final int count;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXPEDITION TELEMETRY ARCHIVE',
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: 4),
        SectionHeader(
          title: 'Ride History',
          padding: EdgeInsets.zero,
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: Text(
              '$count Logged',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
                letterSpacing: 0.4,
              ),
            ),
          ),
          actionWidget: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDownload,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.clay,
                shape: BoxShape.circle,
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Center(
                child: Icon(
                  Icons.download_rounded,
                  size: 18,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
