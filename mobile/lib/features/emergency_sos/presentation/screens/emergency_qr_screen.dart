import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../dashboard/controllers/profile_controller.dart';

/// Screen displaying the rider's Emergency Medical & ICE QR Card.
/// Designed to be saved as an image or printed to carry on rides.
class EmergencyQrScreen extends StatelessWidget {
  const EmergencyQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfileController.instance,
      builder: (context, _) {
        final profile = ProfileController.instance;
        final name = profile.fullName;
        final bloodType = profile.bloodGroup.trim();
        final allergies = profile.allergies.trim();
        final medicalNotes = profile.medicalNotes.trim();
        final contactName = profile.emergencyContactName.trim();
        final contactPhone = profile.emergencyContactPhone.trim();
        final contactRelation = profile.emergencyContactRelation.trim();

        return Scaffold(
          backgroundColor: AppColors.clay,
          appBar: AppBar(
            backgroundColor: AppColors.clay,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkCharcoal, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              'Emergency QR',
              style: GoogleFonts.manrope(
                color: AppColors.darkCharcoal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top guidance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Save a screenshot or print this emergency card to keep in your jacket or tank bag.',
                          style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Physical Card Preview
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // Red emergency header band
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        color: const Color(0xFFDC2626),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.medical_services_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'CAMP EMERGENCY MEDICAL ID',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'OFFLINE',
                              style: GoogleFonts.manrope(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // QR Graphic Container
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF0F172A), width: 3),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.qr_code_2_rounded,
                                  size: 150,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Rider Name
                            Text(
                              name.isNotEmpty ? name : 'Motorcycle Rider',
                              style: GoogleFonts.manrope(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 16),

                            // Medical Details Grid
                            _buildInfoRow(
                              label: 'BLOOD TYPE',
                              value: bloodType.isNotEmpty ? bloodType : 'Not set',
                              isHighlight: bloodType.isNotEmpty,
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              label: 'ALLERGIES',
                              value: allergies.isNotEmpty ? allergies : 'Not set',
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              label: 'MEDICAL NOTES',
                              value: medicalNotes.isNotEmpty ? medicalNotes : 'Not set',
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 16),

                            // Emergency Contact
                            _buildInfoRow(
                              label: 'ICE CONTACT',
                              value: contactName.isNotEmpty
                                  ? '$contactName ${contactRelation.isNotEmpty ? "($contactRelation)" : ""}'
                                  : 'Not set',
                            ),
                            const SizedBox(height: 10),
                            _buildInfoRow(
                              label: 'ICE PHONE',
                              value: contactPhone.isNotEmpty ? contactPhone : 'Not set',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Edit Profile link
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(CampRoutes.editProfile),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFFF6B00)),
                  label: Text(
                    'Edit Medical Info in Profile',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFF6B00),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    final isNotSet = value == 'Not set';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isNotSet
                  ? const Color(0xFF94A3B8)
                  : (isHighlight ? const Color(0xFFDC2626) : const Color(0xFF0F172A)),
              fontStyle: isNotSet ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
