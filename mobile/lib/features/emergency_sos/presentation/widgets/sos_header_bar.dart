import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

/// Top bar with back button, CAMP • logo, and pulsating SOS READY badge
class SosHeaderBar extends StatelessWidget {
  const SosHeaderBar({
    super.key,
    this.onBackPressed,
  });

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Skeuomorphic Back Button
          GestureDetector(
            onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.darkCharcoal,
                  size: 18,
                ),
              ),
            ),
          ),

          // Center: CAMP •
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CAMP',
                style: GoogleFonts.manrope(
                  color: AppColors.darkCharcoal,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 4, top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.tacticalOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Right: SOS READY Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              border: Border.all(
                color: const Color(0xFFFFCDD2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'SOS READY',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFD32F2F),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
