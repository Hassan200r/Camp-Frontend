import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/emergency_sos_controller.dart';
import '../../domain/sos_telemetry_model.dart';

/// Card 3: Automated Rescue Protocols, eCall switch, ICE contacts list
class AutomatedRescueProtocolsCard extends StatelessWidget {
  const AutomatedRescueProtocolsCard({
    super.key,
    this.onManageIcePressed,
  });

  final VoidCallback? onManageIcePressed;

  void _showTimerPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crash Confirmation Window',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set the duration before automated satellite emergency dispatch triggers after fall/impact detection.',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                for (final seconds in [30, 45, 60, 90])
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      '$seconds Seconds (Cancelable)',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    trailing: EmergencySosController.instance.confirmationWindowSeconds == seconds
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.tacticalOrange)
                        : null,
                    onTap: () {
                      EmergencySosController.instance.setConfirmationWindow(seconds);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmergencySosController.instance,
      builder: (context, _) {
        final controller = EmergencySosController.instance;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Title Row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Automated Rescue Protocols',
                    style: GoogleFonts.manrope(
                      color: AppColors.darkCharcoal,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'eCall v3.4',
                    style: GoogleFonts.manrope(
                      color: AppColors.tacticalOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Card Container ──────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.skeuRaised,
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Auto Crash Detection Row + Switch
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Crash Detection Dispatch',
                              style: GoogleFonts.manrope(
                                color: AppColors.darkCharcoal,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Transmits GPS payload if fall detected',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF64748B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Custom Styled Switch
                      GestureDetector(
                        onTap: () => controller.toggleCrashDetection(!controller.autoCrashDetection),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 52,
                          height: 30,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: controller.autoCrashDetection
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Align(
                            alignment: controller.autoCrashDetection
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.autoCrashDetection
                                    ? const Color(0xFF10B981)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),

                  // 2. Crash Confirmation Window Row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Crash Confirmation Window:',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showTimerPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          ),
                          child: Text(
                            '${controller.confirmationWindowSeconds}s Timer Cancelable',
                            style: GoogleFonts.manrope(
                              color: AppColors.darkCharcoal,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 3. Section Label: ASSIGNED RESCUE CONTACTS (ICE)
                  Text(
                    'ASSIGNED RESCUE CONTACTS (ICE)',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF64748B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Contact Tiles
                  for (final contact in controller.contacts) ...[
                    _buildContactTile(contact),
                    const SizedBox(height: 10),
                  ],

                  const SizedBox(height: 4),

                  // 5. Add / Manage ICE Network Button
                  GestureDetector(
                    onTap: onManageIcePressed,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '+ Add / Manage ICE Network',
                          style: GoogleFonts.manrope(
                            color: AppColors.darkCharcoal,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactTile(IceContact contact) {
    final isVhf = contact.isVhf;
    final badgeBg = isVhf ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    final badgeText = isVhf ? const Color(0xFFDC2626) : const Color(0xFFD97706);
    final avatarBg = isVhf ? const Color(0xFFFFEBEE) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        children: [
          // Initials Avatar Circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: avatarBg,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Center(
              child: Text(
                contact.initials,
                style: GoogleFonts.manrope(
                  color: AppColors.darkCharcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: contact.name,
                    style: GoogleFonts.manrope(
                      color: AppColors.darkCharcoal,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      if (contact.relationship.isNotEmpty)
                        TextSpan(
                          text: ' (${contact.relationship})',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Dispatch Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              contact.dispatchBadge,
              style: GoogleFonts.manrope(
                color: badgeText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
