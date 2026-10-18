import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../bike_scan/presentation/screens/bike_details_screen.dart';
import '../../../dashboard/controllers/profile_controller.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../garage/domain/bike_model.dart';
import '../../../settings/controllers/settings_controller.dart';
import '../../domain/emergency_qr_payload.dart';

/// Screen displaying the rider's Emergency Medical & ICE QR Card.
/// Includes active motorcycle details from BikeRepository, customizable via settings toggle.
/// Designed to be saved as a high-resolution PNG image or printed to carry on rides.
class EmergencyQrScreen extends StatefulWidget {
  const EmergencyQrScreen({super.key});

  @override
  State<EmergencyQrScreen> createState() => _EmergencyQrScreenState();
}

class _EmergencyQrScreenState extends State<EmergencyQrScreen> {
  final GlobalKey _cardRepaintKey = GlobalKey();
  bool _isDownloading = false;

  Future<void> _downloadCardPng(EmergencyQrPayloadResult payloadResult) async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      // Allow render pass to settle
      await Future<void>.delayed(const Duration(milliseconds: 60));

      final boundary = _cardRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Card boundary not ready');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode PNG bytes');
      }

      final bytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/camp_emergency_id.png');
      await file.writeAsBytes(bytes);

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency card PNG saved (camp_emergency_id.png)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.darkCharcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Share',
              textColor: AppColors.tacticalOrange,
              onPressed: () {
                // ignore: deprecated_member_use
                Share.share(
                  payloadResult.payload,
                  subject: 'CAMP Emergency Medical & Bike ID',
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save card: $e'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ProfileController.instance,
        ActiveBikeController.instance,
        SettingsController.instance,
      ]),
      builder: (context, _) {
        final profile = ProfileController.instance;
        final bikeController = ActiveBikeController.instance;
        final settings = SettingsController.instance;

        final name = profile.fullName;
        final bloodType = profile.bloodGroup.trim();
        final allergies = profile.allergies.trim();
        final medicalNotes = profile.medicalNotes.trim();
        final contactName = profile.emergencyContactName.trim();
        final contactPhone = profile.emergencyContactPhone.trim();
        final contactRelation = profile.emergencyContactRelation.trim();

        final Bike? activeBike = bikeController.activeBike;
        final bool bikeDetailsToggle = settings.showBikeOnEmergencyQr;

        final payloadResult = EmergencyQrPayloadBuilder.build(
          fullName: name,
          bloodGroup: bloodType,
          allergies: allergies,
          medicalNotes: medicalNotes,
          emergencyContactName: contactName,
          emergencyContactPhone: contactPhone,
          emergencyContactRelation: contactRelation,
          bike: activeBike,
          includeBike: bikeDetailsToggle,
        );

        return Scaffold(
          backgroundColor: AppColors.clay,
          appBar: AppBar(
            backgroundColor: AppColors.clay,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.darkCharcoal,
                size: 20,
              ),
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
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF475569),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Save a screenshot or download this emergency card to keep in your jacket or tank bag.',
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

                const SizedBox(height: 14),

                // Truncation Notice Banner (Tells rider if medical notes were shortened)
                if (payloadResult.isNotesTruncated) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical notes shortened for QR',
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Your medical notes were trimmed to keep the emergency QR scannable offline by first responders.',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB45309),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Settings Toggle Card: "Bike details"
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.clay,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.two_wheeler_rounded,
                                color: AppColors.darkCharcoal,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bike details in QR',
                                style: GoogleFonts.manrope(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                activeBike != null
                                    ? '${activeBike.make} ${activeBike.modelName}'
                                    : 'No active bike',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: bikeDetailsToggle,
                        activeThumbColor: AppColors.tacticalOrange,
                        activeTrackColor: AppColors.tacticalOrange.withValues(alpha: 0.5),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          settings.setShowBikeOnEmergencyQr(val);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Physical Card Preview (Rendered & exported to PNG)
                RepaintBoundary(
                  key: _cardRepaintKey,
                  child: Container(
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
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Red emergency header band
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          color: const Color(0xFFDC2626),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.medical_services_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // QR Graphic Container
                              Center(
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 3,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 150,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Rider Name
                              Center(
                                child: Text(
                                  name.isNotEmpty ? name : 'Motorcycle Rider',
                                  style: GoogleFonts.manrope(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Divider(height: 1, color: Color(0xFFE2E8F0)),
                              const SizedBox(height: 16),

                              // Medical Details Grid
                              _buildInfoRow(
                                label: 'BLOOD TYPE',
                                value: bloodType.isNotEmpty
                                    ? bloodType
                                    : 'Not set',
                                isHighlight: bloodType.isNotEmpty,
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                label: 'ALLERGIES',
                                value: allergies.isNotEmpty
                                    ? allergies
                                    : 'Not set',
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                label: 'MEDICAL NOTES',
                                value: medicalNotes.isNotEmpty
                                    ? medicalNotes
                                    : 'Not set',
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
                                value: contactPhone.isNotEmpty
                                    ? contactPhone
                                    : 'Not set',
                              ),

                              // Motorcycle Section (when toggle is ON)
                              if (bikeDetailsToggle) ...[
                                const SizedBox(height: 16),
                                const Divider(
                                    height: 1, color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 16),
                                _buildBikeDetailsSection(
                                  context: context,
                                  activeBike: activeBike,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Download PNG Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isDownloading
                        ? null
                        : () => _downloadCardPng(payloadResult),
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      _isDownloading
                          ? 'Generating PNG...'
                          : 'Download Emergency Card (PNG)',
                      style: GoogleFonts.manrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkCharcoal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Edit Profile link
                TextButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(CampRoutes.editProfile),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Color(0xFFFF6B00),
                  ),
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

  Widget _buildBikeDetailsSection({
    required BuildContext context,
    required Bike? activeBike,
  }) {
    if (activeBike == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.two_wheeler_outlined,
                  color: Color(0xFF94A3B8),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'No bike added',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(CampRoutes.addMotorcycle),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tacticalOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Add bike',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasPlate =
        activeBike.plateNumber != null && activeBike.plateNumber!.isNotEmpty;
    final bikeMakeModel = '${activeBike.make} ${activeBike.modelName}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prominent Bike Line (as formatted in requirement)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            hasPlate
                ? 'Bike: $bikeMakeModel, ${activeBike.plateNumber}'
                : 'Bike: $bikeMakeModel',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),

        _buildInfoRow(
          label: 'BIKE',
          value: activeBike.modelYear > 1900
              ? '$bikeMakeModel (${activeBike.modelYear})'
              : bikeMakeModel,
        ),
        const SizedBox(height: 10),

        _buildInfoRow(
          label: 'PLATE',
          value: hasPlate ? activeBike.plateNumber! : 'Not set',
          isHighlight: hasPlate,
        ),

        if (activeBike.colour != null && activeBike.colour!.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'COLOUR',
            value: activeBike.colour!,
          ),
        ],

        // Missing Plate Hint
        if (!hasPlate) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BikeDetailsScreen(initialBike: activeBike),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 15,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Add your plate number to help identify the bike',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
                  : (isHighlight
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF0F172A)),
              fontStyle: isNotSet ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
