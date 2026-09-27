import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';

/// CAMP Add Motorcycle Screen (Step 1 of 4 in the Add Bike flow).
/// Allows the rider to choose their onboarding route: Camera Scan,
/// Photo Upload, or Manual Telemetry Entry.
class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  State<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

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
        key: _scaffoldKey,
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
                  115.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Header Bar (Back Button, CAMP Pill, ADD BIKE Pill)
                    CampAppBar(
                      leading: CampAppBarLeading.back,
                      titleWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                          boxShadow: AppColors.skeuRaisedSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomPaint(
                              size: Size(18, 14),
                              painter: CampMountainLogoPainter(),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CAMP',
                              style: GoogleFonts.manrope(
                                color: AppColors.darkCharcoal,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actionWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                          boxShadow: AppColors.skeuRaisedSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.tacticalOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              'ADD BIKE',
                              style: GoogleFonts.manrope(
                                color: AppColors.terracotta,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Progress Row: Step Indicator & 4-Segment Progress Bar
                    _buildProgressRow(),

                    const SizedBox(height: 18),

                    // 3. Title & Subtitle
                    Text(
                      'Add a Motorcycle',
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how you would like to register your bike into the telemetry system.',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 22),

                    // 4. Three Option Cards
                    // Option 1: Scan with Camera (Highlighted with RECOMMENDED badge)
                    _buildScanWithCameraCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // Option 2: Upload Photo
                    _buildUploadPhotoCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // Option 3: Enter Manually
                    _buildEnterManuallyCard(),

                    const SizedBox(height: 20),

                    // 5. Info Banner
                    _buildInfoBanner(),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Dock (Index 1: Bike Scan Active) ─────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 1, // Scan tab active
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(context, index, currentIndex: 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress Row (Step 1 of 4) ─────────────────────────────────────────────
  Widget _buildProgressRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 1 OF 4',
          style: AppTextStyles.overlineOrange,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Segment 1 (Filled - Tactical Orange)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 2 (Unfilled - Clay Deep)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.clayDeep,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 3 (Unfilled - Clay Deep)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.clayDeep,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Segment 4 (Unfilled - Clay Deep)
            Expanded(
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.clayDeep,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Option 1: Scan with Camera (Recommended) ──────────────────────────────
  Widget _buildScanWithCameraCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      border: Border.all(
        color: AppColors.tacticalOrange.withValues(alpha: 0.35),
        width: 1.5,
      ),
      shadows: [
        ...AppColors.skeuRaised,
        ...AppColors.orangeGlow,
      ],
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pushNamed('/bike-scan');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with "RECOMMENDED" badge aligned right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: GoogleFonts.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Content row with IconTile, Title, Subtitle, Chevron
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const IconTile(
                icon: Icons.camera_alt_rounded,
                size: 48,
                iconSize: 24,
                borderRadius: AppColors.radiusTile,
                isInset: false,
                backgroundColor: Colors.white,
                iconColor: AppColors.tacticalOrange,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan with Camera',
                      style: AppTextStyles.itemTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instant VIN, ODO & telemetry recognition via CAMP AI Vision.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedLight,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Option 2: Upload Photo ────────────────────────────────────────────────
  Widget _buildUploadPhotoCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Implement upload photo gallery / image-picker flow once available.
        _showNotification('Photo gallery upload coming soon');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IconTile(
            icon: Icons.photo_library_rounded,
            size: 48,
            iconSize: 24,
            borderRadius: AppColors.radiusTile,
            isInset: false,
            backgroundColor: Colors.white,
            iconColor: AppColors.darkCharcoal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Photo',
                  style: AppTextStyles.itemTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Analyze an existing photo or registration document from your mobile device gallery.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedLight,
            size: 24,
          ),
        ],
      ),
    );
  }

  // ── Option 3: Enter Manually ──────────────────────────────────────────────
  Widget _buildEnterManuallyCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Navigate to manual vehicle entry screen once created (e.g. /manual-bike-entry).
        _showNotification('Manual vehicle entry wizard coming soon');
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const IconTile(
            icon: Icons.edit_note_rounded,
            size: 48,
            iconSize: 26,
            borderRadius: AppColors.radiusTile,
            isInset: false,
            backgroundColor: Colors.white,
            iconColor: AppColors.darkCharcoal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Manually',
                  style: AppTextStyles.itemTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in make, model, displacement, specs, and maintenance logs step-by-step.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mutedLight,
            size: 24,
          ),
        ],
      ),
    );
  }

  // ── Info Banner ───────────────────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.tacticalOrangeDark,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Have your steering stem VIN plate or registration card accessible for 1-tap recognition.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
