import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';

/// CAMP Add Motorcycle Screen.
/// Allows riders to quickly scan their motorcycle with the camera or view their garage.
class AddMotorcycleScreen extends StatelessWidget {
  const AddMotorcycleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        drawer: const AppDrawerWidget(),
        backgroundColor: AppColors.clay,
        body: Stack(
          children: [
            // ── Scrollable Body Content ─────────────────────────────────────
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppColors.screenPadding,
                  8.0,
                  AppColors.screenPadding,
                  120.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Header Bar (Back Button, CAMP Logo with Dot, ADD BIKE Pill)
                    const CampAppBar(
                      leading: CampAppBarLeading.back,
                      titleWidget: CampLogo(showIcon: false),
                      actionText: 'ADD BIKE',
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 24),

                    // 2. Title & Subtitle
                    Text(
                      'Add a Motorcycle',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scan your bike or open your garage.',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 24),

                    // 3. "Scan Bike" Card
                    _buildScanBikeCard(context),

                    const SizedBox(height: AppColors.cardGap),

                    // 4. "View Garage" Card
                    _buildViewGarageCard(context),

                    const SizedBox(height: AppColors.cardGap),

                    // 5. Tip Card
                    _buildTipCard(),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Dock (Index 1: Bike Scan Active) ─────────────
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: CampBottomNav(
                  selectedIndex: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Option 1: Scan Bike Card ──────────────────────────────────────────────
  Widget _buildScanBikeCard(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      borderRadius: AppColors.radiusCard,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.tacticalOrangeLight,
          AppColors.tacticalOrangeDark,
        ],
      ),
      shadows: AppColors.orangeGlow,
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Point to the new camera screen when it exists.
        Navigator.of(context).pushNamed('/bike-scan');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Bike',
                  style: GoogleFonts.manrope(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a photo and we\'ll fill in the details',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Option 2: View Garage Card ────────────────────────────────────────────
  Widget _buildViewGarageCard(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      borderRadius: AppColors.radiusCard,
      color: Colors.white,
      shadows: AppColors.skeuRaised,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/garage');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IconTile(
            icon: Icons.garage_rounded,
            size: 48,
            iconSize: 24,
            borderRadius: AppColors.radiusTile,
            isInset: true,
            backgroundColor: AppColors.clayDark,
            iconColor: AppColors.darkCharcoal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'View Garage',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'See your registered bikes',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.clay,
              shape: BoxShape.circle,
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: const Center(
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedText,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tip Card ──────────────────────────────────────────────────────────────
  Widget _buildTipCard() {
    return InsetTile(
      borderRadius: AppColors.radiusCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.tacticalOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb_rounded,
                color: AppColors.tacticalOrange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tip: a clear side-view photo works best.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }
}
