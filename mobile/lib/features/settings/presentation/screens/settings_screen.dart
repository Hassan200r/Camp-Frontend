import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../../core/widgets/camp_card.dart';
import '../../../../core/widgets/icon_tile.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../controllers/settings_controller.dart';
import '../widgets/settings_controls.dart';
import '../widgets/settings_row_widget.dart';

/// CAMP Settings Screen
/// Serves as the application's single source of truth for Units, Notifications,
/// Privacy & Data Sharing, and Offline Maps storage metrics.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _kNavBottomMargin = 24.0;
  static const double _kScrollBottomPadding = 120.0;

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
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        title: Row(
          children: [
            const IconTile(
              icon: Icons.lock_outline_rounded,
              size: 34,
              iconSize: 16,
              isInset: true,
            ),
            const SizedBox(width: 10),
            Text(
              'Change Password',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a new secure password for your rider account.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: AppColors.darkCharcoal),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.clayDark,
                hintText: 'New password (min 6 chars)',
                hintStyle: const TextStyle(color: AppColors.mutedText, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _showNotification('Password updated successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
              ),
              elevation: 0,
            ),
            child: Text(
              'Update',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLinkedAccountsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.clay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusCard)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const IconTile(
                    icon: Icons.link_rounded,
                    size: 36,
                    iconSize: 18,
                    isInset: true,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Linked Accounts',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildLinkedAccountItem(
                title: 'BMW ConnectedRide',
                account: 'alex@bmwmoto.com',
                connected: true,
              ),
              const SizedBox(height: 10),
              _buildLinkedAccountItem(
                title: 'Google Drive Telemetry Backup',
                account: 'alex.henderson@gmail.com',
                connected: true,
              ),
              const SizedBox(height: 10),
              _buildLinkedAccountItem(
                title: 'Apple Health (Rider Vitals)',
                account: 'Not connected',
                connected: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedAccountItem({
    required String title,
    required String account,
    required bool connected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
        boxShadow: AppColors.skeuRecessed,
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: connected ? AppColors.statusGreen : AppColors.mutedText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                Text(
                  account,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            connected ? 'Linked' : 'Connect',
            style: GoogleFonts.manrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: connected ? AppColors.terracotta : AppColors.tacticalOrange,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.clay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppColors.radiusCard)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Display Language',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),
              _buildLanguageOption('English', isSelected: true),
              _buildLanguageOption('Deutsch (German)', isSelected: false),
              _buildLanguageOption('Français (French)', isSelected: false),
              _buildLanguageOption('Español (Spanish)', isSelected: false),
              _buildLanguageOption('Italiano (Italian)', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String lang, {required bool isSelected}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        lang,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? AppColors.tacticalOrangeDark : AppColors.darkCharcoal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.tacticalOrange)
          : null,
      onTap: () {
        Navigator.of(context).pop();
        if (lang.startsWith('English')) {
          SettingsController.instance.setLanguage('English');
          _showNotification('Language set to English');
        } else {
          _showNotification('$lang localization preview coming soon');
        }
      },
    );
  }

  void _showClearCacheDialog() {
    final controller = SettingsController.instance;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        title: Row(
          children: [
            const IconTile(
              icon: Icons.cleaning_services_outlined,
              size: 34,
              iconSize: 16,
              isInset: false,
              backgroundColor: AppColors.alertRedBg,
              iconColor: AppColors.alertRed,
            ),
            const SizedBox(width: 10),
            Text(
              'Clear Local Cache?',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'This will purge temporary offline map tiles and telemetry caches (${controller.localCacheDisplay}). Your saved route packs, garage fleet, and profile records will not be deleted.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final freed = controller.localCacheDisplay;
              controller.clearLocalCache();
              _showNotification('Local cache cleared ($freed freed)');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
              ),
              elevation: 0,
            ),
            child: Text(
              'Clear Cache',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.clay,
      shape: const RoundedRectangleBorder(
        borderRadius: verticalCardRadius,
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const IconTile(
                    icon: Icons.help_outline_rounded,
                    size: 36,
                    iconSize: 18,
                    isInset: true,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Help & Rider Support',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.tacticalOrange),
                title: const Text('CAMP Rider Handbook & Offline Guide'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showNotification('Opening Rider Handbook...');
                },
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline_rounded, color: AppColors.tacticalOrange),
                title: const Text('Contact Support (support@camp.io)'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showNotification('Support inquiry initiated');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined, color: AppColors.tacticalOrange),
                title: const Text('Submit Telemetry Diagnostic Log'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showNotification('Diagnostic logs queued for review');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const BorderRadius verticalCardRadius =
      BorderRadius.vertical(top: Radius.circular(AppColors.radiusCard));

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(AppColors.radiusTile - 6),
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
            const SizedBox(width: 12),
            Text(
              'About CAMP',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CAMP Mobility Suite',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0 (Build 890-GS)',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            Text(
              'CAMP is a tactically engineered rider cockpit and telemetry suite built for adventure riders tackling high-altitude passes, off-grid expeditions, and backcountry trails.',
              style: AppTextStyles.bodySecondary.copyWith(height: 1.45),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tacticalOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
              ),
              elevation: 0,
            ),
            child: Text(
              'Close',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        title: Row(
          children: [
            const IconTile(
              icon: Icons.logout_rounded,
              size: 34,
              iconSize: 17,
              isInset: false,
              backgroundColor: AppColors.alertRedBg,
              iconColor: AppColors.alertRed,
            ),
            const SizedBox(width: 10),
            Text(
              'Confirm Log Out',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end your active rider session? Live telemetry recording will pause.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: AppColors.mutedText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              AuthController.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/sign-in',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.alertRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
              ),
              elevation: 0,
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

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
                child: ListenableBuilder(
                  listenable: settings,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Header Bar: CampAppBar
                        CampAppBar(
                          leading: CampAppBarLeading.back,
                          actionText: 'SETTINGS',
                          onLeadingPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        // 2. Hero Row (Compact rider summary card)
                        _buildHeroRow(),

                        const SizedBox(height: AppColors.cardGap),

                        // 3. Card "ACCOUNT"
                        _buildAccountCard(),

                        const SizedBox(height: AppColors.cardGap),

                        // 4. Card "PREFERENCES"
                        _buildPreferencesCard(settings),

                        const SizedBox(height: AppColors.cardGap),

                        // 5. Card "STORAGE & DATA"
                        _buildStorageCard(settings),

                        const SizedBox(height: AppColors.cardGap),

                        // 6. Card "SUPPORT"
                        _buildSupportCard(),

                        const SizedBox(height: AppColors.cardGap),

                        // 7. Full-width outlined red/danger "Log Out" button
                        _buildLogOutButton(),

                        const SizedBox(height: 16),

                        // 8. Small centered muted footer text
                        Text(
                          'CAMP v1.0.0 • Built for adventure riders',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ── Floating Bottom Dock (No tab active) ─────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: _kNavBottomMargin,
              child: Center(
                child: CampBottomNav(
                  selectedIndex: -1,
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(context, index, currentIndex: -1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Compact Hero Row ───────────────────────────────────────────────────
  Widget _buildHeroRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pushNamed('/profile'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          boxShadow: AppColors.skeuRaised,
        ),
        child: Row(
          children: [
            // Circular Avatar + Green Dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.tacticalOrange,
                      width: 2.0,
                    ),
                    boxShadow: AppColors.skeuRaisedSmall,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/rider_avatar_alex.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.clayDark,
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.terracotta,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: AppColors.statusGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Rider Name + PRO Pill + Active Rig
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Alex Henderson',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.tacticalOrange.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                          border: Border.all(
                            color: AppColors.tacticalOrange.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.tacticalOrangeDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ListenableBuilder(
                    listenable: ActiveBikeController.instance,
                    builder: (context, _) {
                      final activeBike = ActiveBikeController.instance.activeBike;
                      final bikeName = activeBike != null
                          ? '${activeBike.make} ${activeBike.modelName}'
                          : 'BMW R 1250 GS Adventure';
                      return Text(
                        'Active Rig: $bikeName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedText,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.mutedLight,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Card "ACCOUNT" ─────────────────────────────────────────────────────
  Widget _buildAccountCard() {
    return CampCard(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: AppColors.radiusCard,
      shadows: AppColors.skeuRaised,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.person_outline_rounded,
            title: 'ACCOUNT',
          ),
          SettingsRowWidget(
            icon: Icons.badge_outlined,
            title: 'Edit Personal Info',
            onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.link_rounded,
            title: 'Linked Accounts',
            subtitle: 'Connected as alex@bmwmoto.com',
            onTap: _showLinkedAccountsBottomSheet,
          ),
        ],
      ),
    );
  }

  // ── 4. Card "PREFERENCES" ─────────────────────────────────────────────────
  Widget _buildPreferencesCard(SettingsController settings) {
    return CampCard(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: AppColors.radiusCard,
      shadows: AppColors.skeuRaised,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.tune_rounded,
            title: 'PREFERENCES',
          ),
          SettingsRowWidget(
            icon: Icons.straighten_rounded,
            title: 'Units',
            trailing: InlineUnitsToggle(
              selected: settings.units,
              onChanged: settings.setUnits,
            ),
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Maintenance alerts, trip reminders',
            trailing: TacticalSwitch(
              value: settings.notificationsEnabled,
              onChanged: settings.setNotificationsEnabled,
            ),
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.language_rounded,
            title: 'Language',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.language,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedLight,
                  size: 20,
                ),
              ],
            ),
            onTap: _showLanguageSelector,
          ),
        ],
      ),
    );
  }

  // ── 5. Card "STORAGE & DATA" ──────────────────────────────────────────────
  Widget _buildStorageCard(SettingsController settings) {
    return CampCard(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: AppColors.radiusCard,
      shadows: AppColors.skeuRaised,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.folder_open_rounded,
            title: 'STORAGE & DATA',
          ),
          SettingsRowWidget(
            icon: Icons.map_outlined,
            title: 'Offline Maps',
            subtitle: settings.cachedPacksSubtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${settings.cachedPacksSizeGb.toStringAsFixed(1)} GB used',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedLight,
                  size: 20,
                ),
              ],
            ),
            onTap: () => Navigator.of(context).pushNamed('/route-packs'),
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.shield_outlined,
            title: 'Privacy & Data Sharing',
            subtitle: 'Anonymized ride telemetry for predictive maintenance',
            trailing: TacticalSwitch(
              value: settings.privacySharingEnabled,
              onChanged: settings.setPrivacySharingEnabled,
            ),
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            customLeading: const IconTile(
              icon: Icons.cleaning_services_outlined,
              size: 38,
              iconSize: 18,
              isInset: false,
              backgroundColor: AppColors.alertRedBg,
              iconColor: AppColors.alertRed,
            ),
            title: 'Clear Local Cache',
            subtitle: 'Free up temporary storage (${settings.localCacheDisplay})',
            onTap: _showClearCacheDialog,
          ),
        ],
      ),
    );
  }

  // ── 6. Card "SUPPORT" ─────────────────────────────────────────────────────
  Widget _buildSupportCard() {
    return CampCard(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: AppColors.radiusCard,
      shadows: AppColors.skeuRaised,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SettingsCardHeader(
            icon: Icons.help_outline_rounded,
            title: 'SUPPORT',
          ),
          SettingsRowWidget(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: _showHelpSupportBottomSheet,
          ),
          const Divider(height: 1, color: Color(0x10000000)),
          SettingsRowWidget(
            icon: Icons.info_outline_rounded,
            title: 'About CAMP',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'v1.0.0',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.mutedLight,
                  size: 20,
                ),
              ],
            ),
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  // ── 7. Full-width Log Out Button ──────────────────────────────────────────
  Widget _buildLogOutButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showLogoutConfirmationDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(AppColors.radiusTile),
          border: Border.all(
            color: AppColors.alertRed.withValues(alpha: 0.4),
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
