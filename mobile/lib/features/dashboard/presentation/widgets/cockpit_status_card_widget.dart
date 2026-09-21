import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Dark Rider Banner wrapped in a soft tactile bezel ring
class CockpitStatusCardWidget extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback? onCtaPressed;
  final VoidCallback? onProfilePressed;

  const CockpitStatusCardWidget({
    super.key,
    this.avatarUrl,
    this.onCtaPressed,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Outer bezel — skeuomorphic clay ring creating depth around dark card
    return Container(
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cockpitBezel,
      ),
      padding: const EdgeInsets.all(6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.cockpitGradientStart,
              AppColors.cockpitGradientMid,
              AppColors.cockpitGradientEnd,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Section: Avatar + Rider Info + ONLINE pill ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.statusYellow,
                              width: 2.5,
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A3223), Color(0xFF2B1A10)],
                            ),
                          ),
                          child: Center(
                            child: avatarUrl != null
                                ? CircleAvatar(
                                    radius: 26,
                                    backgroundImage: NetworkImage(avatarUrl!),
                                  )
                                : const Text(
                                    'Elena',
                                    style: TextStyle(
                                      color: Color(0xFFFDE68A),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0F172A),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: AppColors.statusYellow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Rider info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Elena Vance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5A391D),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ADV PRO',
                                style: TextStyle(
                                  color: Color(0xFFFCD34D),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Cockpit Link Active',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ONLINE pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14241B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.statusGreen.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.statusGreen,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.statusGreen
                                    .withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ONLINE',
                          style: TextStyle(
                            color: AppColors.statusGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Status Tag Pills ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _darkPill(Icons.access_time_rounded, '08:42 AM'),
                  _darkPill(Icons.satellite_alt_rounded, 'GPS Locked, Lahore'),
                  _darkPill(Icons.wb_sunny_rounded, 'Sunny 68°F • 4mph NW'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── CTA Banner (raised extruded bottom pill) ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: BoxDecoration(
                  color: AppColors.cockpitBannerBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready for the Ridge Pass?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Ideal riding conditions on Alpine Route 4',
                            style: TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Glowing extruded orange arrow button
                    SkeuomorphicOrangeIconButton(
                      icon: Icons.arrow_forward_rounded,
                      size: 44,
                      onTap: onCtaPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.statusYellow),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
