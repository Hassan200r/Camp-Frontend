import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';

/// Placeholder screen for Carburetor Tuning feature.
class CarburetorTuningScreen extends StatelessWidget {
  const CarburetorTuningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clay,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CampAppBar(
                    leading: CampAppBarLeading.back,
                    titleText: 'Carburetor Tuning',
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.settings_suggest_rounded,
                          size: 48,
                          color: AppColors.mutedLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Carburetor Tuning — Coming Soon',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: CampBottomNav(
                selectedIndex: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
