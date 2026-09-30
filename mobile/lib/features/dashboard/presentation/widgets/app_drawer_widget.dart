import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/skeuomorphic_container.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/controllers/auth_controller.dart';

/// CAMP's soft-tactile side navigation overlay.
class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({super.key});

  static const _orange = AppColors.tacticalOrange;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * .88,
      backgroundColor: AppColors.clay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppColors.radiusCard),
          bottomRight: Radius.circular(AppColors.radiusCard),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(children: [
            _topBar(context),
            const SizedBox(height: 18),
            _riderSummary(context),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  _menuItem(context, icon: Icons.person_outline_rounded, title: 'User Profile', route: '/profile'),
                  _menuItem(context, icon: Icons.garage_rounded, iconColor: _orange, title: 'My Garage', subtitle: 'Manage Fleet & Active Rig', badge: 'Garage', orangeBadge: true, route: '/garage'),
                  _menuItem(context, icon: Icons.directions_bike_rounded, title: 'Bike Profile', badge: 'Active', route: '/bike-profile'),
                  _menuItem(
                    context,
                    icon: Icons.cloud_download_outlined,
                    title: 'Route Packs',
                    subtitle: 'Offline Topo & Telemetry',
                    badge: '5 Available',
                    orangeBadge: true,
                    route: '/route-packs',
                  ),
                  _menuItem(context, icon: Icons.access_time_rounded, title: 'Ride History', subtitle: 'GPS Tracks & Stats', badge: '24 Logged', route: '/ride-history'),
                  _menuItem(context, icon: Icons.compass_calibration_rounded, title: 'Predictive Maintenance', notification: '1', route: '/predictive-maintenance'),
                  _menuItem(context, icon: Icons.handyman_rounded, iconColor: _orange, title: 'Find a Mechanic', subtitle: 'Community Pitstops & Roadside', badge: 'Active', orangeBadge: true, route: '/mechanics'),
                  _menuItem(context, icon: Icons.build_outlined, iconColor: _orange, title: 'Add a Mechanic', subtitle: 'Community Pitstops', badge: '+ Contributor', orangeBadge: true, route: '/add-mechanic'),
                  _menuItem(context, icon: Icons.settings_suggest_rounded, title: 'Carburetor Tuning', subtitle: 'High Altitude Jetting', badge: 'Tuning Req.', orangeBadge: true, route: '/carburetor-tuning'),
                  _menuItem(context, icon: Icons.settings_outlined, title: 'Settings', route: '/settings'),
                  _menuItem(
                    context,
                    icon: Icons.emergency_rounded,
                    iconColor: AppColors.alertRed,
                    title: 'Emergency SOS & Telematics',
                    route: '/emergency-sos',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _obdStatus(),
            const SizedBox(height: 12),
            _logout(context),
          ]),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) => Row(children: [
        Text(
          'CAMP',
          style: GoogleFonts.manrope(color: AppColors.darkCharcoal, fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: .2),
        ),
        Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 3, top: 8), decoration: const BoxDecoration(color: _orange, shape: BoxShape.circle)),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.clay,
              shape: BoxShape.circle,
              boxShadow: AppColors.skeuRaisedSmall,
            ),
            child: const Center(child: Icon(Icons.close_rounded, size: 21, color: AppColors.charcoalLight)),
          ),
        ),
      ]);

  Widget _riderSummary(BuildContext context) => ListenableBuilder(
        listenable: AuthController.instance,
        builder: (context, _) {
          final riderName = AuthController.instance.riderDisplayName;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/profile');
            },
            child: SkeuomorphicContainer(
              borderRadius: AppColors.radiusTile,
              color: Colors.white.withValues(alpha: .88),
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                Row(children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.clay,
                        border: Border.all(color: _orange, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, color: AppColors.terracotta, size: 29),
                    ),
                    const Positioned(right: -1, bottom: 1, child: _StatusDot(color: AppColors.statusGreen)),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(riderName, style: AppTextStyles.cardTitle),
                    const SizedBox(height: 3),
                    Text('BMW R 1250 GS Adventure', style: AppTextStyles.caption),
                  ])),
                ]),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0x11000000)),
            ),
            Row(children: [
              _pill('PRO Touring', icon: Icons.emoji_events_rounded, orange: true),
              const Spacer(),
              Text('14,820 km logged', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 11)),
            ]),
          ]),
        ),
      );
    },
  );

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
    String? subtitle,
    String? badge,
    String? notification,
    Color? iconColor,
    bool orangeBadge = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            if (onTap != null) {
              onTap();
            } else if (route != null) {
              Navigator.of(context).pushNamed(route);
            }
          },
          child: SkeuomorphicContainer(
            borderRadius: AppColors.radiusTile,
            shadows: AppColors.skeuRaisedSmall,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(children: [
              IconTile(
                icon: icon,
                iconColor: iconColor ?? AppColors.charcoalLight,
                size: 38,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.itemTitle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
                  ],
                ]),
              ),
              if (badge != null) ...[const SizedBox(width: 8), _pill(badge, orange: orangeBadge)],
              if (notification != null) ...[const SizedBox(width: 8), _notification(notification)],
              const SizedBox(width: 7),
              const Icon(Icons.chevron_right_rounded, color: AppColors.mutedLight, size: 21),
            ]),
          ),
        ),
      );

  Widget _pill(String label, {IconData? icon, bool orange = false}) => Container(
        constraints: const BoxConstraints(maxWidth: 76),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: orange ? const Color(0xFFFFF0DB) : AppColors.clayDark,
          borderRadius: BorderRadius.circular(7),
          border: orange ? Border.all(color: const Color(0x33F56500)) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: _orange), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: orange ? _orange : AppColors.charcoalLight,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]),
      );

  Widget _notification(String label) => Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: Color(0xFFFF4C2E), shape: BoxShape.circle),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
      );

  Widget _obdStatus() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          const _StatusDot(color: Color(0xFF65D4AD), size: 8),
          const SizedBox(width: 8),
          Expanded(child: Text('OBD-II Bluetooth 5.3', style: AppTextStyles.caption.copyWith(color: AppColors.charcoalLight, fontWeight: FontWeight.w700))),
          Text('v3.4.1', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _logout(BuildContext context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Logged out successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              backgroundColor: AppColors.darkCharcoal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(milliseconds: 2000),
            ),
          );
          Navigator.of(context).pushNamed('/sign-in');
        },
        child: SkeuomorphicContainer(
          borderRadius: AppColors.radiusTile,
          shadows: AppColors.skeuRaisedSmall,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          child: Row(children: [
            const Icon(Icons.logout_rounded, color: AppColors.alertRed, size: 20),
            const SizedBox(width: 10),
            Text('Log Out', style: AppTextStyles.itemTitle.copyWith(color: AppColors.alertRed)),
            const Spacer(),
            Text('GS #441', style: AppTextStyles.caption.copyWith(color: AppColors.alertRed, fontWeight: FontWeight.w800)),
          ]),
        ),
      );
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, this.size = 12});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.clay, width: 2),
        ),
      );
}
