import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/maintenance_item_model.dart';
import 'maintenance_item_card_widget.dart';

/// List widget for upcoming & required maintenance items
class MaintenanceListWidget extends StatelessWidget {
  const MaintenanceListWidget({
    required this.items,
    required this.onAddMaintenanceItem,
    super.key,
    this.onItemGuidePressed,
    this.onItemTapped,
  });

  final List<MaintenanceItem> items;
  final VoidCallback onAddMaintenanceItem;
  final ValueChanged<MaintenanceItem>? onItemGuidePressed;
  final ValueChanged<MaintenanceItem>? onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Eyebrow Overline ───────────────────────────────────────────────
        Text('CONDITION TELEMETRY', style: AppTextStyles.overline),
        const SizedBox(height: 4),

        // ── Section Header with Wrench IconTile ────────────────────────────
        SectionHeader(
          title: 'Upcoming & Required\nMaintenance',
          maxLines: 2,
          padding: const EdgeInsets.only(bottom: 14),
          badge: IconTile(
            icon: Icons.build_rounded,
            size: 32,
            iconSize: 16,
            isInset: false,
            iconColor: AppColors.tacticalOrangeDark,
            onTap: onAddMaintenanceItem,
          ),
        ),

        // ── Maintenance Item Cards ─────────────────────────────────────────
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MaintenanceItemCardWidget(
              item: item,
              onActionPressed: () => onItemGuidePressed?.call(item),
              onTap: () => onItemTapped?.call(item),
            ),
          );
        }),

        const SizedBox(height: 4),

        // ── "+ Add Maintenance Item" with Trailing Chevron ──────────────────
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAddMaintenanceItem,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.clay,
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: AppColors.tacticalOrangeDark,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '+ Add Maintenance Item',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.tacticalOrangeDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
