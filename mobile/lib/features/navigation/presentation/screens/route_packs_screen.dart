import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../../core/widgets/primary_button.dart';

/// Screen displaying offline route packs and topographic regions cached on device.
class RoutePacksScreen extends StatelessWidget {
  const RoutePacksScreen({super.key});

  static const List<(String, String, bool)> _packs = [
    ('Cascade Alpine Loop', '340 MB • WA Pass High Alpine', true),
    ('Karakoram Highway Pass', '520 MB • 15,397 ft Peak Pass', true),
    ('Stelvio Pass Alpine', '410 MB • Eastern Alps 48 Hairpins', true),
    ('Moab Slickrock Trail', '290 MB • Red Rock Desert Grid', true),
    ('Tail of the Dragon', '180 MB • 318 Curves in 11 mi', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CampAppBar(
                    leading: CampAppBarLeading.back,
                    titleText: 'Route Packs',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.tacticalOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.cloud_download_outlined,
                          color: AppColors.tacticalOrange,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Route Packs',
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '5 Topo regions cached & ready offline',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ..._packs.map(
                    (pack) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.statusGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pack.$1,
                                  style: AppTextStyles.itemTitle,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pack.$2,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.clayDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ready',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.statusGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'All Packs Synchronized',
                    icon: Icons.sync_rounded,
                    isFullWidth: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Offline Route Packs verified: 1.74 GB cached',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          backgroundColor: AppColors.darkCharcoal,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: CampBottomNav(
                selectedIndex: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
