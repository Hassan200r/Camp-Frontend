import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Upcoming Pitstop card showing appointment schedule, location, and quick actions
class PitstopCardWidget extends StatelessWidget {
  const PitstopCardWidget({
    super.key,
    this.dateLabel = 'Oct 18, 10:00 AM',
    this.locationLabel = 'Peak Moto Dealership & Prep • Denver, CO',
    this.onCallDealer,
    this.onDirections,
  });

  final String dateLabel;
  final String locationLabel;
  final VoidCallback? onCallDealer;
  final VoidCallback? onDirections;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Overline + Confirmed Status Chip ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'UPCOMING PITSTOP',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.overline,
                ),
              ),
              const SizedBox(width: 8),
              const StatusChip(
                label: 'Confirmed',
                variant: StatusChipVariant.success,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Date, Time & Location Row ────────────────────────────────────
          Row(
            children: [
              const IconTile(
                icon: Icons.calendar_today_rounded,
                size: 42,
                iconSize: 20,
                isInset: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Action Buttons Row ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Center(
                  child: GhostButton(
                    label: '📞 Call Dealer',
                    color: AppColors.darkCharcoal,
                    onTap: onCallDealer ??
                        () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Dialing Peak Moto Dealership...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppColors.darkCharcoal,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(milliseconds: 1500),
                            ),
                          );
                        },
                  ),
                ),
              ),
              Container(
                height: 20,
                width: 1,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              Expanded(
                child: Center(
                  child: GhostButton(
                    label: '🗺 Directions (42 mi)',
                    color: AppColors.tacticalOrangeDark,
                    onTap: onDirections ??
                        () {
                          Navigator.of(context).pushNamed('/mechanics/map');
                        },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
