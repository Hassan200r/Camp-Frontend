import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/stat_model.dart';
import 'stat_tile_widget.dart';

/// Widget #4 — Season summary card.
/// CampCard containing eyebrow, bike label, StatusChip, and a row of 4 stats.
class SeasonSummaryCardWidget extends StatelessWidget {
  const SeasonSummaryCardWidget({super.key});

  static const List<Stat> _stats = [
    Stat(label: 'DISTANCE', value: '14,820', unit: 'KM'),
    Stat(label: 'SADDLE', value: '418', unit: 'HRS'),
    Stat(label: 'TOTAL ELEV', value: '+142.5k'),
    Stat(label: 'AVG FUEL', value: '4.8', unit: 'L/100km'),
  ];

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow + StatusChip row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEASON 2024 SUMMARY',
                      style: AppTextStyles.overline,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'BMW GS #441 • KTM 890',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const StatusChip(
                label: '100% Synced',
                variant: StatusChipVariant.success,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 4-stat row — each in its own InsetTile box
          Row(
            children: [
              for (int i = 0; i < _stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: InsetTile(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: StatTileWidget(stat: _stats[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
