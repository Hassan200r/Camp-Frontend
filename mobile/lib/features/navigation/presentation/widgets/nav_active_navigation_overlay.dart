import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/navigation_controller.dart';

/// Floating telemetry and navigation shortcuts during active State 3 guidance:
/// - Wide "Google Maps" external launcher
/// - Wide "Offline Maps" route pack shortcut
/// - Speedometer card (current speed only, no speed-limits or lanes)
/// - "Recenter" pill (visible when user has panned away)
class NavActiveNavigationOverlay extends StatelessWidget {
  const NavActiveNavigationOverlay({
    required this.controller,
    required this.mapController,
    super.key,
  });

  final NavigationController controller;
  final MapController mapController;

  Future<void> _launchGoogleMaps(BuildContext context) async {
    final url = controller.googleMapsUrl;
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  void _openOfflineMaps(BuildContext context) {
    Navigator.of(context).pushNamed('/route-packs');
  }

  void _recenter() {
    controller.recenterMap();
    mapController.move(controller.userLatLng, 17.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left Column: Google Maps, Offline Maps & Speedometer ────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Google Maps Button (Wide enough that labels never truncate)
              _buildActionPill(
                icon: Icons.navigation_outlined,
                iconColor: const Color(0xFFEA580C),
                label: 'Google Maps',
                trailing: Icons.open_in_new_rounded,
                onTap: () => _launchGoogleMaps(context),
              ),
              const SizedBox(height: 8),

              // 2. Offline Maps Button
              _buildActionPill(
                icon: Icons.offline_pin_outlined,
                iconColor: AppColors.tacticalOrange,
                label: 'Offline Route Packs',
                trailing: Icons.chevron_right_rounded,
                onTap: () => _openOfflineMaps(context),
              ),
              const SizedBox(height: 12),

              // 3. Speedometer Badge (No speed-limit sign, no lane guidance)
              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.currentSpeed}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkCharcoal,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.speedUnitLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.mutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Right Side: Recenter Button (when panned away) ─────────────────
          if (!controller.isScreenCentered)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: _recenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        color: AppColors.tacticalOrange,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recenter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required IconData trailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 175),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(width: 8),
            Icon(trailing, size: 16, color: AppColors.mutedLight),
          ],
        ),
      ),
    );
  }
}
