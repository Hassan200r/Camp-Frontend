import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/expedition_log_model.dart';
import 'date_chip_widget.dart';
import 'expedition_footer_widget.dart';
import 'stat_tile_widget.dart';

/// Widget #10 — Reusable expedition card.
/// DateChipWidget + StatusChip(tag) + small icon button top row;
/// title; route→bike subtitle; row of 4 stats; footer row.
class ExpeditionCardWidget extends StatelessWidget {
  const ExpeditionCardWidget({
    required this.log,
    super.key,
    this.onMoreTap,
    this.onLinkTap,
  });

  final ExpeditionLog log;
  final VoidCallback? onMoreTap;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: date chip, status chip, icon ─────────────────────────
          Row(
            children: [
              DateChipWidget(label: log.date),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                    label: log.tag,
                    variant: log.tagVariant,
                    icon: log.tagIcon,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMoreTap,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.clay,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.skeuRaisedSmall,
                  ),
                  child: Center(
                    child: Icon(
                      log.icon,
                      size: 15,
                      color: log.tagVariant == StatusChipVariant.neutral
                          ? AppColors.mutedText
                          : AppColors.tacticalOrange,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Title ──────────────────────────────────────────────────────────
          Text(
            log.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.itemTitle,
          ),

          const SizedBox(height: 3),

          // ── Route → bike subtitle ─────────────────────────────────────────
          Text(
            '${log.route} • ${log.bike}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySecondary,
          ),

          const SizedBox(height: 12),

          // ── 4 stats — each in its own InsetTile box ──────────────────────
          Row(
            children: [
              for (int i = 0; i < log.stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: InsetTile(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: StatTileWidget(stat: log.stats[i]),
                  ),
                ),
              ],
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          ExpeditionFooterWidget(
            footer: log.footer,
            linkLabel: log.footerLink,
            onLinkTap: onLinkTap,
          ),
        ],
      ),
    );
  }
}
