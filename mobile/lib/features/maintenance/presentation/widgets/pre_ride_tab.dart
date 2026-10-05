import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_card.dart';

/// Tab 3 — Pre-Ride Safety Audit checklist.
/// Holds its own local checkbox state; no external dependencies beyond AppColors.
class PreRideTab extends StatefulWidget {
  const PreRideTab({super.key});

  @override
  State<PreRideTab> createState() => _PreRideTabState();
}

class _PreRideTabState extends State<PreRideTab> {
  final Map<String, bool> _checklist = {
    'Tire Pressures & Tread Inspection': false,
    'Chain Slack (25-35mm) & Lubrication': false,
    'Engine Oil Sight Glass Level Check': false,
    'Front & Rear Brake Lever Pressure': false,
    'Throttle Return & Clutch Cable Freeplay': false,
    'Headlight, Brake Lamp & Turn Signals': false,
    'Luggage Straps & Crash Bars Torqued': false,
  };

  @override
  Widget build(BuildContext context) {
    final completedCount = _checklist.values.where((v) => v).length;
    final totalCount = _checklist.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Card
        CampCard(
          padding: const EdgeInsets.all(16),
          borderRadius: AppColors.radiusCard,
          color: AppColors.clay,
          shadows: AppColors.skeuRaised,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRE-RIDE SAFETY AUDIT',
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '$completedCount of $totalCount Done',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: completedCount == totalCount
                          ? AppColors.statusGreen
                          : AppColors.tacticalOrangeDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.clayDark,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completedCount == totalCount
                        ? AppColors.statusGreen
                        : AppColors.tacticalOrange,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete all physical inspection checkpoints prior to high-speed or off-grid departure.',
                style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Checkpoint Items
        ..._checklist.keys.map((checkpoint) {
          final isChecked = _checklist[checkpoint] ?? false;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                _checklist[checkpoint] = !isChecked;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isChecked
                    ? AppColors.clay
                    : AppColors.clayDark.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                boxShadow: isChecked ? AppColors.skeuRaisedSmall : null,
                border: Border.all(
                  color: isChecked
                      ? AppColors.statusGreen.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isChecked
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: isChecked ? AppColors.statusGreen : AppColors.mutedLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      checkpoint,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: isChecked ? FontWeight.w700 : FontWeight.w600,
                        color: isChecked ? AppColors.darkCharcoal : AppColors.mutedText,
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 14),

        // Start Ride Button
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  completedCount == totalCount
                      ? 'All checkpoints verified! Have a safe expedition.'
                      : '$completedCount of $totalCount items checked. Proceed with caution.',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
                ),
                backgroundColor: completedCount == totalCount
                    ? AppColors.statusGreen
                    : AppColors.tacticalOrangeDark,
                duration: const Duration(seconds: 3),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.tacticalOrangeLight,
                  AppColors.tacticalOrange,
                  AppColors.tacticalOrangeDark,
                ],
              ),
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              boxShadow: AppColors.orangeGlow,
            ),
            child: Center(
              child: Text(
                'Start Ride',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
