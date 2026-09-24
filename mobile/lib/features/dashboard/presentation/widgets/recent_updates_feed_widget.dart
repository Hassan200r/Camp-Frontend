import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Recent Updates Feed — individual raised skeuomorphic cards per update
class RecentUpdatesFeedWidget extends StatelessWidget {
  const RecentUpdatesFeedWidget({
    super.key,
    this.onMarkAllRead,
    this.onViewRadar,
    this.onLocateBeacon,
    this.onDismissTpms,
  });

  final VoidCallback? onMarkAllRead;
  final VoidCallback? onViewRadar;
  final VoidCallback? onLocateBeacon;
  final VoidCallback? onDismissTpms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ─────────────────────────────────────────────────
        SectionHeader(
          title: 'Recent Updates',
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange]),
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              boxShadow: AppColors.orangeGlow,
            ),
            child: const Text(
              '3 New',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
          actionLabel: 'Mark all read',
          onAction: onMarkAllRead,
        ),

        _updateCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFFD97706),
          title: 'Weather Advisory',
          timeAgo: '8m ago',
          description: 'Sudden mist and gusty winds reported at High Pass summit (Elev. 2,500 m).',
          actionLabel: 'View Radar',
          actionIcon: Icons.radar_rounded,
          onAction: onViewRadar,
        ),

        const SizedBox(height: 10),

        _updateCard(
          icon: Icons.track_changes_rounded,
          iconColor: const Color(0xFF0D9488),
          title: 'Group Beacon Synced',
          timeAgo: '12m ago',
          description: 'Rider Marcus checked in at Waypoint Echo 12 mins ago.',
          actionLabel: 'Locate',
          actionIcon: Icons.near_me_rounded,
          onAction: onLocateBeacon,
        ),

        const SizedBox(height: 10),

        _updateCard(
          icon: Icons.speed_rounded,
          iconColor: AppColors.terracotta,
          title: 'TPMS Update',
          timeAgo: '25m ago',
          description: 'Rear tire pressure optimized for dirt/gravel transit (2.2 bar).',
          actionLabel: 'Dismiss',
          actionIcon: Icons.check_rounded,
          onAction: onDismissTpms,
        ),
      ],
    );
  }

  Widget _updateCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String timeAgo,
    required String description,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback? onAction,
  }) {
    return CampCard(
      borderRadius: AppColors.radiusTile + 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recessed icon well
          IconTile(icon: icon, iconColor: iconColor, size: 42, borderRadius: 14),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(title, style: AppTextStyles.itemTitle)),
                    Text(timeAgo, style: AppTextStyles.caption),
                  ],
                ),

                const SizedBox(height: 5),

                Text(description, style: AppTextStyles.bodySecondary),

                const SizedBox(height: 10),

                // Raised pill action button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.clay,
                      borderRadius: BorderRadius.circular(AppColors.radiusTile),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(actionIcon, size: 14, color: AppColors.terracotta),
                        const SizedBox(width: 6),
                        Text(actionLabel, style: AppTextStyles.overlineTerracotta.copyWith(letterSpacing: 0.4)),
                      ],
                    ),
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