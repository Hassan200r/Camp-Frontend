import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/tactical_bottom_dock_widget.dart';

/// CAMP Rider Profile Screen
/// High-fidelity skeuomorphic cockpit profile displaying telemetry records,
/// touring tiers, trail badges, garage fleet, health status, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Navigation height constants for strict anti-overlap calculation:
  /// CampBottomNav container height (48 + 16 = 64px) + floating bottom margin (24px) + clearance (32px) = 120px
  static const double _kNavHeight = 64.0;
  static const double _kNavBottomMargin = 24.0;
  static const double _kScrollBottomPadding = _kNavHeight + _kNavBottomMargin + 32.0;

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
                  _kScrollBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Top Header Bar (Circular Back, CAMP with orange dot, PROFILE pill)
                    CampAppBar(
                      leading: CampAppBarLeading.back,
                      titleWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'CAMP',
                            style: GoogleFonts.manrope(
                              color: AppColors.darkCharcoal,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.tacticalOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      actionWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                          boxShadow: AppColors.skeuRaisedSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.tacticalOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              'PROFILE',
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

                    const SizedBox(height: 16),

                    // 2. Cockpit Hero Card
                    _buildCockpitHeroCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // 3. Stat Cards (2x2 Grid)
                    _buildStatsGrid(),

                    const SizedBox(height: AppColors.cardGap),

                    // 4. Touring Tier Progress
                    _buildTouringTierCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // 5. Earned Trail Badges
                    _buildTrailBadgesSection(),

                    const SizedBox(height: AppColors.cardGap),

                    // 6. My Garage (Horizontal Bike Carousel)
                    _buildMyGarageSection(),

                    const SizedBox(height: AppColors.cardGap),

                    // 7. Maintenance Health Card
                    _buildMaintenanceHealthCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // 8. Recent Trips
                    _buildRecentTripsSection(),

                    const SizedBox(height: AppColors.cardGap),

                    // 9. Rider Medical & SOS ID Card
                    _buildMedicalSosCard(),

                    const SizedBox(height: AppColors.cardGap),

                    // 10. Settings List Card
                    _buildSettingsSection(),

                    const SizedBox(height: AppColors.cardGap),

                    // 11. Full-width Log Out Button
                    _buildLogOutButton(),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Dock (Index 4: Profile Active) ───────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: _kNavBottomMargin,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 4, // Profile tab active
                  onIndexChanged: (index) {
                    if (index == 4) return;
                    CampBottomNav.navigateToTab(context, index, currentIndex: 4);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Cockpit Hero Card ───────────────────────────────────────────────────
  Widget _buildCockpitHeroCard() {
    return CockpitHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Avatar + Info + Online badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with orange border and verified badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.tacticalOrange,
                          width: 2.2,
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4A3223), Color(0xFF2B1A10)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Elena',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFFDE68A),
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
                const SizedBox(width: 14),

                // Name, ADV PRO tag, and vehicle link
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              AuthController.instance.riderDisplayName,
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A391D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'ADV PRO',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFFCD34D),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Cockpit Link Active • BMW R 1250 GS',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Green ONLINE pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(AppColors.radiusTile),
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
                              color: AppColors.statusGreen.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ONLINE',
                        style: GoogleFonts.manrope(
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

          // Three Info Chips Row (Time, GPS, Weather)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildHeroDarkPill(Icons.access_time_rounded, '08:42 AM'),
                _buildHeroDarkPill(Icons.satellite_alt_rounded, 'GPS Locked'),
                _buildHeroDarkPill(Icons.wb_sunny_rounded, 'Sunny 68°F - 4mph NW'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // "Ready for the Ridge Pass?" CTA Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              decoration: BoxDecoration(
                color: AppColors.cockpitBannerBg,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready for the Ridge Pass?',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ideal riding conditions on Alpine Route 4',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFD1D5DB),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pushNamed('/mechanics/map'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.tacticalOrangeLight,
                            AppColors.tacticalOrange,
                            AppColors.tacticalOrangeDark,
                          ],
                        ),
                        boxShadow: AppColors.orangeGlow,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Passport & Garmin InReach Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'PASSPORT: CAMP-9942-GS',
                    style: GoogleFonts.manrope(
                      color: AppColors.tacticalOrangeLight,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'GARMIN INREACH SYNC',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Action Row: "Edit Profile" + QR Code Icon Button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppColors.radiusTile),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 19,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showNotification('Rider Passport QR code generated'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppColors.radiusTile),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
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

  Widget _buildHeroDarkPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.statusYellow),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFFE5E7EB),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Stat Cards (2x2 Grid) ───────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: 'LIFETIME DISTANCE',
                icon: Icons.explore_outlined,
                iconColor: AppColors.tacticalOrange,
                statValue: '14,820',
                statUnit: 'KM',
                isUnitOrange: true,
                subtitle: 'Elev. +142,500m',
              ),
            ),
            const SizedBox(width: AppColors.cardGap),
            Expanded(
              child: _buildStatTile(
                title: 'PASSES & REGIONS',
                icon: Icons.landscape_outlined,
                iconColor: AppColors.tacticalOrange,
                statValue: '8',
                statUnit: 'Regions',
                isUnitOrange: false,
                subtitle: 'Alps, Pyrenees, Balk.',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppColors.cardGap),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                title: 'SADDLE TIME',
                icon: Icons.access_time_rounded,
                iconColor: AppColors.mutedText,
                statValue: '124',
                statUnit: 'Days',
                isUnitOrange: false,
                subtitle: '418 Active Hours',
              ),
            ),
            const SizedBox(width: AppColors.cardGap),
            Expanded(
              child: _buildStatTile(
                title: 'LONGEST SINGLE DAY',
                icon: Icons.bolt_rounded,
                iconColor: AppColors.mutedText,
                statValue: '780',
                statUnit: 'KM',
                isUnitOrange: true,
                subtitle: 'TET Sector 04',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String statValue,
    required String statUnit,
    required bool isUnitOrange,
    required String subtitle,
  }) {
    return CampCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.overline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.clayDark,
                  boxShadow: AppColors.skeuRecessed,
                ),
                child: Center(
                  child: Icon(icon, size: 14, color: iconColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                statValue,
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statUnit,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isUnitOrange ? AppColors.tacticalOrange : AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── 4. Touring Tier Progress ───────────────────────────────────────────────
  Widget _buildTouringTierCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOURING TIER PROGRESS',
            style: AppTextStyles.overline,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level 4: Master Explorer',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  '78%',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.tacticalOrangeDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radiusPill),
            child: Container(
              height: 8,
              color: AppColors.clayDeep,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.78,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.tacticalOrange,
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Current: 14,820 KM',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Next Tier: 16,000 KM (1,180 KM to go)',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5. Earned Trail Badges ─────────────────────────────────────────────────
  Widget _buildTrailBadgesSection() {
    final badges = [
      {'title': 'Alps Explorer', 'icon': Icons.landscape_rounded, 'color': AppColors.tacticalOrange},
      {'title': 'Iron Butt 1000k', 'icon': Icons.speed_rounded, 'color': AppColors.darkCharcoal},
      {'title': 'Sand Dune Master', 'icon': Icons.person_pin_circle_outlined, 'color': AppColors.darkCharcoal},
      {'title': 'Babusar Summit', 'icon': Icons.change_history_rounded, 'color': AppColors.darkCharcoal},
      {'title': 'Off-Grid', 'icon': Icons.cell_tower_rounded, 'color': AppColors.darkCharcoal},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EARNED TRAIL BADGES',
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: badges.map((b) {
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppColors.radiusTile),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: Center(
                        child: Icon(
                          b['icon'] as IconData,
                          size: 26,
                          color: b['color'] as Color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 72,
                      child: Text(
                        b['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── 6. My Garage (Horizontal Bike Carousel) ────────────────────────────────
  Widget _buildMyGarageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'MY GARAGE',
          actionWidget: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pushNamed('/add-bike'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
                border: Border.all(
                  color: AppColors.tacticalOrange.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 15,
                    color: AppColors.tacticalOrange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Recognize bike with camera',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildBikeGarageCard(
                model: 'BMW R 1250 GS Adv',
                year: '2023',
                mileage: '14,820 km',
                statusLabel: 'Good',
                isStatusGood: true,
                footerLeading: 'Primary Ride',
                footerTrailing: 'Active',
                isPrimary: true,
                imagePath: 'assets/images/bmw_r1250_scan_placeholder.jpg',
              ),
              const SizedBox(width: 14),
              _buildBikeGarageCard(
                model: 'Honda Rebel 500',
                year: '2022',
                mileage: '4,120 km',
                statusLabel: 'Service Due',
                isStatusGood: false,
                footerLeading: 'Oil Due in 180km',
                footerTrailing: '',
                isPrimary: false,
                imagePath: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBikeGarageCard({
    required String model,
    required String year,
    required String mileage,
    required String statusLabel,
    required bool isStatusGood,
    required String footerLeading,
    required String footerTrailing,
    required bool isPrimary,
    required String? imagePath,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pushNamed('/garage'),
      child: Container(
        width: 236,
        padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.clay,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        boxShadow: AppColors.skeuRaised,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bike Image with top-right pill
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFE2E8F0),
                  child: imagePath != null
                      ? Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.two_wheeler_rounded, size: 48, color: AppColors.mutedText),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.two_wheeler_rounded, size: 48, color: Colors.white70),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isStatusGood ? const Color(0xFF10B981) : AppColors.tacticalOrange,
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            model,
            style: GoogleFonts.manrope(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(year, style: AppTextStyles.caption),
              Text(mileage, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPrimary ? AppColors.statusGreen : AppColors.tacticalOrange,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    footerLeading,
                    style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? AppColors.statusGreen : AppColors.tacticalOrangeDark,
                    ),
                  ),
                ],
              ),
              if (footerTrailing.isNotEmpty)
                Text(
                  footerTrailing,
                  style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  // ── 7. Maintenance Health Card ─────────────────────────────────────────────
  Widget _buildMaintenanceHealthCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with Shield + Title + Telemetry Monitored pill
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: AppColors.tacticalOrange,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'MAINTENANCE HEALTH',
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                    letterSpacing: 0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  'Telemetry Monitored',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tacticalOrangeDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sub-card with Health Ring + Service forecast
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: Row(
              children: [
                // 82% Health circular ring
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: 0.82,
                        strokeWidth: 6,
                        backgroundColor: AppColors.clayDark,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.tacticalOrange),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '82%',
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          Text(
                            'HEALTH',
                            style: GoogleFonts.manrope(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mutedText,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                          children: const [
                            TextSpan(text: 'Next service due in '),
                            TextSpan(
                              text: '640 km',
                              style: TextStyle(color: AppColors.tacticalOrange, fontWeight: FontWeight.w800),
                            ),
                            TextSpan(text: ' or '),
                            TextSpan(
                              text: '12 days',
                              style: TextStyle(color: AppColors.tacticalOrange, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'BMW R 1250 GS Adv • 15,000 km Inspection',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Top At-Risk Components header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top At-Risk Components',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Text(
                'Wear Severity',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Component 1: Drive Chain & Sprocket
          _buildRiskComponentRow(
            name: 'Drive Chain & Sprocket',
            wearPercent: '78% Wear',
            isRed: true,
            progressFraction: 0.78,
            warningReason: 'Rough terrain & river crossing on last trip',
          ),

          const SizedBox(height: 10),

          // Component 2: Front Brake Pads
          _buildRiskComponentRow(
            name: 'Front Brake Pads',
            wearPercent: '65% Wear',
            isRed: false,
            progressFraction: 0.65,
            warningReason: 'Heavy descent braking on Alpine Route 4',
          ),

          const SizedBox(height: 14),

          // View Full Report Button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pushNamed('/mechanics'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Report',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.darkCharcoal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskComponentRow({
    required String name,
    required String wearPercent,
    required bool isRed,
    required double progressFraction,
    required String warningReason,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusTile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isRed ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  wearPercent,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isRed ? AppColors.alertRed : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radiusPill),
            child: Container(
              height: 5,
              color: AppColors.clayDark,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressFraction,
                child: Container(
                  decoration: BoxDecoration(
                    color: isRed ? AppColors.alertRed : AppColors.tacticalOrange,
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Color(0xFFD97706),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  warningReason,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 8. Recent Trips Section ────────────────────────────────────────────────
  Widget _buildRecentTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'RECENT TRIPS',
          actionLabel: 'See all',
          onAction: () => _showNotification('Opening full trip logbook...'),
        ),
        _buildTripCard(
          title: 'Babusar Pass Summit & Alpine Ridge',
          tag: 'Mixed',
          tagBg: const Color(0xFFFEF3C7),
          tagFg: const Color(0xFFD97706),
          subtitle: 'Yesterday, Oct 14 • 286.4 km',
          impactIcon: Icons.explore_outlined,
          impactColor: AppColors.tacticalOrange,
          impactText: 'High wear (+3.4% chain wear)',
          duration: '5h 42m',
        ),
        const SizedBox(height: 10),
        _buildTripCard(
          title: 'Karakoram High-Altitude Corridor',
          tag: 'Highway',
          tagBg: const Color(0xFFEFF6FF),
          tagFg: const Color(0xFF2563EB),
          subtitle: 'Oct 11, 2024 • 412.0 km',
          impactIcon: Icons.check_circle_outline_rounded,
          impactColor: AppColors.statusGreen,
          impactText: 'Nominal impact',
          duration: '6h 15m',
        ),
        const SizedBox(height: 10),
        _buildTripCard(
          title: 'Cholistan Desert Sand Nav Loop',
          tag: 'Off-road',
          tagBg: const Color(0xFFFFEDD5),
          tagFg: AppColors.tacticalOrangeDark,
          subtitle: 'Sep 15, 2024 • 188.0 km',
          impactIcon: Icons.air_rounded,
          impactColor: AppColors.tacticalOrange,
          impactText: 'High dust impact (air filter)',
          duration: '3h 50m',
        ),
      ],
    );
  }

  Widget _buildTripCard({
    required String title,
    required String tag,
    required Color tagBg,
    required Color tagFg,
    required String subtitle,
    required IconData impactIcon,
    required Color impactColor,
    required String impactText,
    required String duration,
  }) {
    return CampCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagBg,
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: tagFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(impactIcon, size: 14, color: impactColor),
                  const SizedBox(width: 5),
                  Text(
                    impactText,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              Text(
                duration,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 9. Rider Medical & SOS ID Card ─────────────────────────────────────────
  Widget _buildMedicalSosCard() {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.alertRed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'RIDER MEDICAL & SOS ID',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                ),
                child: Text(
                  'Telemetry Armed',
                  style: GoogleFonts.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.statusGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoKeyValueRow(
            label: 'Emergency ICE:',
            valueWidget: Text(
              'Sarah Henderson (Spouse) • +1 (555) 019-4821',
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoKeyValueRow(
            label: 'Blood & Allergies:',
            valueWidget: RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.w800),
                children: const [
                  TextSpan(
                    text: 'O+ POS',
                    style: TextStyle(color: AppColors.alertRed),
                  ),
                  TextSpan(
                    text: ' • Penicillin (Severe)',
                    style: TextStyle(color: AppColors.darkCharcoal, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoKeyValueRow(
            label: 'Satellite SOS Beacon:',
            valueWidget: Text(
              'Iridium #IR-88210-GS',
              style: GoogleFonts.manrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 16),
          // View Emergency Protocols button
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showNotification('Emergency ICE & Health Protocols: Iridium #IR-88210-GS active'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                border: Border.all(
                  color: AppColors.alertRed.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'View Emergency Protocols & Health Card',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.alertRed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.alertRed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoKeyValueRow({
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Expanded(child: valueWidget),
      ],
    );
  }

  // ── 10. Settings Section ───────────────────────────────────────────────────
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: AppTextStyles.overline,
        ),
        const SizedBox(height: 10),
        CampCard(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          borderRadius: AppColors.radiusCard,
          color: AppColors.clay,
          shadows: AppColors.skeuRaised,
          child: Column(
            children: [
              _buildSettingsRow(
                icon: Icons.person_outline_rounded,
                title: 'Edit Personal Info',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
                onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                icon: Icons.straighten_rounded,
                title: 'Units',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.clayDark,
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  ),
                  child: Text(
                    'Metric (KM, °C)',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                onTap: () => _showNotification('Units Configuration'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enabled',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
                  ],
                ),
                onTap: () => _showNotification('Notifications Config'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                icon: Icons.cloud_download_outlined,
                title: 'Offline Maps',
                subtitle: '1.4 GB / 8.2 GB cached',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
                onTap: () => _showNotification('Offline Maps: 1.4 GB / 8.2 GB cached across 5 route packs'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                icon: Icons.security_rounded,
                title: 'Privacy & Telemetry Sharing',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
                onTap: () => _showNotification('Privacy & Telemetry'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
                onTap: () => _showNotification('Help & Support'),
              ),
              const Divider(height: 1, color: Color(0x12000000)),
              _buildSettingsRow(
                customLeading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.clayDark,
                    borderRadius: BorderRadius.circular(AppColors.radiusTile),
                    boxShadow: AppColors.skeuRecessed,
                  ),
                  child: Center(
                    child: Text(
                      'CAMP',
                      style: GoogleFonts.manrope(
                        color: AppColors.tacticalOrange,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                title: 'About CAMP',
                trailing: Text(
                  'v1.0.0 (Build 890-GS)',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                onTap: () => _showNotification('CAMP Mobility Suite v1.0.0'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow({
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
    IconData? icon,
    Widget? customLeading,
    String? subtitle,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            customLeading ??
                IconTile(
                  icon: icon ?? Icons.settings_outlined,
                  size: 36,
                  iconSize: 18,
                  iconColor: AppColors.darkCharcoal,
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // ── 11. Full-width Log Out Button ──────────────────────────────────────────
  Widget _buildLogOutButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showNotification('Rider session disconnected'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(AppColors.radiusTile),
          border: Border.all(
            color: AppColors.alertRed.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              size: 19,
              color: AppColors.alertRed,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.alertRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
