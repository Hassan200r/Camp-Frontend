import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/emergency_sos_controller.dart';

/// Card 3: Auto Crash Detection Card with motion sensor toggle & confirmation window
class AutoCrashDetectionCard extends StatelessWidget {
  const AutoCrashDetectionCard({super.key});

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
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set the duration before automated emergency dispatch triggers after fall/impact detection.',
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
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    trailing: EmergencySosController.instance.confirmationWindowSeconds == seconds
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFFFF8A00))
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

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ─────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.sensors_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Auto Crash Detection',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Toggle Switch
                  GestureDetector(
                    onTap: () => controller.toggleCrashDetection(!controller.autoCrashDetection),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 28,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: controller.autoCrashDetection
                            ? const Color(0xFF10B981)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Align(
                        alignment: controller.autoCrashDetection
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x20000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Description ────────────────────────────────────────────────
              Text(
                'Uses your phone\'s motion sensors to detect a possible crash and alerts your contact automatically.',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 14),

              // ── Confirmation Window Inset Box ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Confirmation window:',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showTimerPicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF2F7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                            ),
                            child: Text(
                              '${controller.confirmationWindowSeconds}s cancel',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFF1E293B),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'If you don\'t cancel, CAMP sends your location and an alert automatically.',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
