import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Recent Updates Feed — individual raised skeuomorphic cards per update
class RecentUpdatesFeedWidget extends StatelessWidget {
  final VoidCallback? onMarkAllRead;
  final VoidCallback? onViewRadar;
  final VoidCallback? onLocateBeacon;
  final VoidCallback? onDismissTpms;

  const RecentUpdatesFeedWidget({
    super.key,
    this.onMarkAllRead,
    this.onViewRadar,
    this.onLocateBeacon,
    this.onDismissTpms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Recent Updates',
                  style: TextStyle(
                    color: AppColors.darkCharcoal,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.tacticalOrangeLight,
                        AppColors.tacticalOrange,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.orangeGlow,
                  ),
                  child: const Text(
                    '3 New',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            // 1. First GestureDetector: "Mark all read" link
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onMarkAllRead,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.terracotta,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _updateCard(
          icon: Icons.air_rounded,
          iconColor: const Color(0xFFD97706),
          title: 'Weather Advisory',
          timeAgo: '8m ago',
          description:
          'Sudden mist and gusty winds reported at High Pass summit (Elev. 8,200ft).',
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
          description:
          'Rear tire psi optimized for dirt/gravel transit (32 PSI).',
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
    return SkeuomorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recessed icon well
          SkeuomorphicInsetContainer(
            borderRadius: 14,
            padding: const EdgeInsets.all(9),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Second GestureDetector: Raised pill action button
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAction,
                  child: SkeuomorphicContainer(
                    borderRadius: 14,
                    shadows: AppColors.skeuRaisedSmall,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(actionIcon,
                            size: 14, color: AppColors.terracotta),
                        const SizedBox(width: 6),
                        Text(
                          actionLabel,
                          style: const TextStyle(
                            color: AppColors.darkCharcoal,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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