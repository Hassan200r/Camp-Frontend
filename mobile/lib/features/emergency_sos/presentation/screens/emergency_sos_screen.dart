import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../../core/widgets/primary_button.dart';

/// Screen for Emergency SOS & Telematics distress beacon broadcast.
class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    titleText: 'Emergency SOS',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181513),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.alertRed.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.alertRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.alertRed.withValues(alpha: 0.6),
                                ),
                              ),
                              child: const Icon(
                                Icons.emergency_rounded,
                                color: AppColors.alertRed,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMERGENCY SOS & TELEMATICS',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.alertRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Distress Beacon & Satellite ICE',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _sosRow(
                                'Satellite Beacon',
                                'Active • Iridium #IR-88210-GS',
                                Icons.satellite_alt_rounded,
                              ),
                              const Divider(color: Colors.white12, height: 20),
                              _sosRow(
                                'VHF Emergency Radio',
                                '151.625 MHz (Channel 4)',
                                Icons.radio_rounded,
                              ),
                              const Divider(color: Colors.white12, height: 20),
                              _sosRow(
                                'ICE Contact',
                                'Elena Vance (+1 555-0199)',
                                Icons.contact_phone_rounded,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'BROADCAST DISTRESS SIGNAL',
                          icon: Icons.cell_tower_rounded,
                          isFullWidth: true,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '🚨 SOS Distress Ping Broadcast! Emergency frequency 151.625 MHz notified.',
                                ),
                                backgroundColor: AppColors.alertRed,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
                selectedIndex: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sosRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.tacticalOrange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
