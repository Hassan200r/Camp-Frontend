import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Skeuomorphic tactical drawer menu for navigation and profile settings
class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.clay,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drawer Header ──────────────────────────────────────────────
              SkeuomorphicContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A3223), Color(0xFF2B1A10)],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Elena',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Elena Vance',
                            style: TextStyle(
                              color: AppColors.darkCharcoal,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'ADV PRO • Level 4',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Navigation Items ───────────────────────────────────────────
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _drawerItem(
                      icon: Icons.explore_rounded,
                      title: 'Explore & Routes',
                      isSelected: true,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 8),
                    _drawerItem(
                      icon: Icons.two_wheeler_rounded,
                      title: 'My Garage (BMW R1250)',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 8),
                    _drawerItem(
                      icon: Icons.build_circle_rounded,
                      title: 'Service & Telemetry',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 8),
                    _drawerItem(
                      icon: Icons.map_rounded,
                      title: 'Offline Topo Maps',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 8),
                    _drawerItem(
                      icon: Icons.tune_rounded,
                      title: 'Tactical Cockpit Settings',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // ── Drawer Footer ──────────────────────────────────────────────
              SkeuomorphicInsetContainer(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CAMP OS v2.4',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ALL SYSTEMS OK',
                      style: TextStyle(
                        color: AppColors.terracotta,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: isSelected
          ? SkeuomorphicContainer(
              borderRadius: 14,
              shadows: AppColors.skeuRaisedSmall,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.terracotta, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.mutedText, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
