import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/tactical_bottom_dock_widget.dart';

/// CAMP Rider Profile Screen
/// Features the Hero cockpit gradient card, rider statistics,
/// and CampCard sections for ride history, bike connections, and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDockIndex = 0;

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
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
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  AppColors.screenPadding,
                  8.0,
                  AppColors.screenPadding,
                  110.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── App Bar ─────────────────────────────────────────────
                    CampAppBar(
                      leading: CampAppBarLeading.back,
                      titleText: 'RIDER PROFILE',
                    ),

                    const SizedBox(height: 14),

                    // ── Hero Cockpit Card ───────────────────────────────────
                    CockpitHeroCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.statusYellow, width: 2.5),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF4A3223), Color(0xFF2B1A10)],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.person_rounded, color: Color(0xFFFDE68A), size: 32),
                                      ),
                                    ),
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: _OnlineDot(),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                // Rider info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Alex Henderson',
                                              style: GoogleFonts.manrope(
                                                color: Colors.white,
                                                fontSize: 18,
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
                                              'PRO TOURING',
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
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cockpit Link Active • Lahore, PK',
                                        style: GoogleFonts.manrope(color: const Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Stats row
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.cockpitBannerBg,
                                borderRadius: BorderRadius.circular(AppColors.radiusTile),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _statCol('14,820', 'km Logged'),
                                  _divider(),
                                  _statCol('42', 'Routes'),
                                  _divider(),
                                  _statCol('3', 'Bikes'),
                                  _divider(),
                                  _statCol('99.4%', 'Health'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Active Bike Summary ─────────────────────────────────
                    SectionHeader(
                      title: 'Active Motorcycle',
                      actionLabel: 'View All',
                      onAction: () => _showNotification('Opening Garage...'),
                    ),
                    CampCard(
                      child: Row(
                        children: [
                          IconTile(
                            icon: Icons.two_wheeler_rounded,
                            size: 44,
                            iconColor: AppColors.terracotta,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BMW R1250 GS Adventure', style: AppTextStyles.itemTitle),
                                const SizedBox(height: 3),
                                Text('Edition Triple Black • 2023', style: AppTextStyles.bodySecondary),
                              ],
                            ),
                          ),
                          const StatusChip(label: 'ACTIVE', variant: StatusChipVariant.success, showDot: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Telemetry Summary ───────────────────────────────────
                    SectionHeader(title: 'Last Telemetry Snapshot'),
                    Row(
                      children: [
                        Expanded(
                          child: CampCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconTile(icon: Icons.speed_rounded, iconColor: AppColors.terracotta, size: 36),
                                const SizedBox(height: 10),
                                Text('14,820 km', style: AppTextStyles.statMedium),
                                Text('Odometer', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppColors.cardGap),
                        Expanded(
                          child: CampCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconTile(icon: Icons.local_gas_station_rounded, iconColor: AppColors.terracotta, size: 36),
                                const SizedBox(height: 10),
                                Text('78%', style: AppTextStyles.statMedium),
                                Text('Fuel Level', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppColors.cardGap),
                        Expanded(
                          child: CampCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconTile(icon: Icons.thermostat_rounded, iconColor: AppColors.terracotta, size: 36),
                                const SizedBox(height: 10),
                                Text('22 °C', style: AppTextStyles.statMedium),
                                Text('Ambient', style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // ── Recent Rides ────────────────────────────────────────
                    SectionHeader(
                      title: 'Recent Rides',
                      actionLabel: 'See All',
                      onAction: () => _showNotification('Opening Ride History...'),
                    ),
                    ...[
                      _rideCard('Alpine Route 4', '124 km', '2h 18m', '4 days ago'),
                      _rideCard('City Loop Lahore', '38 km', '55m', '1 week ago'),
                    ],

                    const SizedBox(height: AppColors.cardGap),

                    // ── Settings Quick Links ────────────────────────────────
                    SectionHeader(title: 'Account'),
                    CampCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _settingsRow(Icons.notifications_outlined, 'Notifications', () => _showNotification('Opening Notifications...')),
                          const Divider(height: 1, color: Color(0x12000000)),
                          _settingsRow(Icons.privacy_tip_outlined, 'Privacy & Data', () => _showNotification('Opening Privacy settings...')),
                          const Divider(height: 1, color: Color(0x12000000)),
                          _settingsRow(Icons.logout_rounded, 'Sign Out', () => _showNotification('Signing out...'), isDestructive: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Floating Bottom Dock ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: _selectedDockIndex,
                  onIndexChanged: (index) {
                    setState(() => _selectedDockIndex = index);
                    if (index == 0) Navigator.of(context).pushReplacementNamed('/');
                    if (index == 1) Navigator.of(context).pushNamed('/bike-scan');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(String value, String label) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.manrope(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _divider() => Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.1));

  Widget _rideCard(String route, String distance, String duration, String when) => Padding(
        padding: const EdgeInsets.only(bottom: AppColors.cardGap),
        child: CampCard(
          child: Row(
            children: [
              IconTile(icon: Icons.route_outlined, iconColor: AppColors.tacticalOrange),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route, style: AppTextStyles.itemTitle),
                    const SizedBox(height: 3),
                    Text('$distance • $duration', style: AppTextStyles.bodySecondary),
                  ],
                ),
              ),
              Text(when, style: AppTextStyles.caption),
            ],
          ),
        ),
      );

  Widget _settingsRow(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppColors.cardPadding, vertical: 14),
          child: Row(
            children: [
              IconTile(
                icon: icon,
                size: 36,
                iconColor: isDestructive ? AppColors.alertRed : AppColors.charcoalLight,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.itemTitle.copyWith(
                    color: isDestructive ? AppColors.alertRed : AppColors.darkCharcoal,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 20),
            ],
          ),
        ),
      );
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0F172A)),
      child: const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusGreen),
    );
  }
}
