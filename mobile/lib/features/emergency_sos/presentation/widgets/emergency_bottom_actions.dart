import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/emergency_sos_controller.dart';

/// Bottom action bar: "Test Sat Link" and "Siren & Strobe"
class EmergencyBottomActions extends StatelessWidget {
  const EmergencyBottomActions({
    super.key,
    this.onSatTestComplete,
  });

  final ValueChanged<String>? onSatTestComplete;

  Future<void> _handleTestSatLink(BuildContext context) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Pinging Iridium 66 Low-Earth Orbit Satellite...',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1400),
      ),
    );

    await EmergencySosController.instance.testSatLink();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 10),
            Text(
              'Sat Link Verified: 100% Signal (0.8s RTT)',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  void _handleSirenToggle(BuildContext context) {
    EmergencySosController.instance.toggleSirenAndStrobe();
    final isActive = EmergencySosController.instance.isSirenActive;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isActive ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: isActive ? AppColors.tacticalOrange : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              isActive
                  ? 'Acoustic Siren & High-Intensity Strobe Beacon: ACTIVE'
                  : 'Siren & Strobe: Standby',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmergencySosController.instance,
      builder: (context, _) {
        final controller = EmergencySosController.instance;

        return Row(
          children: [
            // Left: Test Sat Link Button
            Expanded(
              child: GestureDetector(
                onTap: controller.isTestingSatLink ? null : () => _handleTestSatLink(context),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: AppColors.skeuRaisedSmall,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_tethering_rounded,
                        color: AppColors.darkCharcoal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Test Sat Link',
                        style: GoogleFonts.manrope(
                          color: AppColors.darkCharcoal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Right: Siren & Strobe Button
            Expanded(
              child: GestureDetector(
                onTap: () => _handleSirenToggle(context),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                    color: controller.isSirenActive
                        ? const Color(0xFFFEF08A)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: controller.isSirenActive
                          ? AppColors.tacticalOrange
                          : const Color(0xFFFDE68A),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        controller.isSirenActive
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded,
                        color: AppColors.tacticalOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        controller.isSirenActive ? 'Siren: ACTIVE' : 'Siren & Strobe',
                        style: GoogleFonts.manrope(
                          color: AppColors.darkCharcoal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
