import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/emergency_sos_controller.dart';

/// Card 5: Offline Medical ID Card with First Responder telemetry & Lock Screen QR
class OfflineMedicalIdCard extends StatelessWidget {
  const OfflineMedicalIdCard({
    super.key,
    this.onLockscreenQrPressed,
  });

  final VoidCallback? onLockscreenQrPressed;

  @override
  Widget build(BuildContext context) {
    final medical = EmergencySosController.instance.medicalProfile;

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
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Red Stripe Accent (with top-left & bottom-left rounded edge)
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
              ),
            ),

            // Card Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top First Responder Data Tag
                    Text(
                      'FIRST RESPONDER DATA',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFDC2626),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Header: Medical ID + Lock Screen QR Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Medical ID',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFF1E293B),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: onLockscreenQrPressed ?? () => _showMedicalQrDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Lock Screen QR',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Row with 2 tiles: Blood Type & Known Allergies
                    Row(
                      children: [
                        // Left: Blood Type
                        Container(
                          width: 105,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BLOOD TYPE',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF64748B),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                medical.bloodType,
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFDC2626),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Right: Known Allergies
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'KNOWN ALLERGIES',
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF64748B),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  medical.allergies,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 13,
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

                    // Bottom Tile: MEDICAL NOTES / RIDER INFO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEDICAL NOTES / RIDER INFO',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF64748B),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            medical.touringNotes,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Footer note (italic)
                    Text(
                      'Accessible to first responders via Lock Screen QR without unlocking device.',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicalQrDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lockscreen Medical QR',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 130,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'First Responders can scan this high-contrast QR code without unlocking your phone to view Blood Type (O+ POS), Allergies, and ICE Contacts.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Close',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
