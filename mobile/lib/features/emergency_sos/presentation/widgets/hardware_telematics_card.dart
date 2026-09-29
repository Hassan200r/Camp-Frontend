import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../controllers/emergency_sos_controller.dart';

/// Top card containing the 3D Tactile SOS Button & Satellite Telematics Hub
class HardwareTelematicsCard extends StatefulWidget {
  const HardwareTelematicsCard({super.key});

  @override
  State<HardwareTelematicsCard> createState() => _HardwareTelematicsCardState();
}

class _HardwareTelematicsCardState extends State<HardwareTelematicsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _countdownTimer;
  int _secondsLeft = 3;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerSos();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startHolding() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isHolding = true;
      _secondsLeft = 3;
    });
    _progressController.forward(from: 0.0);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
        HapticFeedback.mediumImpact();
      } else {
        timer.cancel();
      }
    });
  }

  void _cancelHolding() {
    if (_progressController.isCompleted) return;
    _countdownTimer?.cancel();
    _progressController.reset();
    setState(() {
      _isHolding = false;
      _secondsLeft = 3;
    });
  }

  void _triggerSos() {
    _countdownTimer?.cancel();
    HapticFeedback.vibrate();
    setState(() => _isHolding = false);
    EmergencySosController.instance.triggerBeacon();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildBeaconActiveDialog(context),
    );
  }

  Widget _buildBeaconActiveDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.alertRed, width: 2),
              ),
              child: const Icon(
                Icons.cell_tower_rounded,
                color: AppColors.alertRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SATELLITE BEACON BROADCASTING',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.alertRed,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Distress beacon & GPS payload transmitting to Iridium Constellation & assigned rescue network.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.darkCharcoal,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                EmergencySosController.instance.cancelBeacon();
                Navigator.of(context).pop();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.darkCharcoal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'CANCEL DISTRESS TRANSMISSION',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.skeuRaised,
      ),
      child: Stack(
        children: [
          // Background Radar Watermark Arcs
          Positioned(
            top: -20,
            right: -20,
            child: CustomPaint(
              size: const Size(140, 140),
              painter: _RadarArcsPainter(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HARDWARE TELEMATICS HUB',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(AppColors.radiusPill),
                        border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'SAT-LINK 100%',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Concentric 3D Red SOS Button with Hold Detection
                GestureDetector(
                  onTapDown: (_) => _startHolding(),
                  onTapUp: (_) => _cancelHolding(),
                  onTapCancel: () => _cancelHolding(),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated holding progress indicator ring
                        SizedBox(
                          width: 176,
                          height: 176,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _progressController.value,
                                strokeWidth: 4,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE53935),
                                ),
                                backgroundColor: const Color(0xFFE2E8F0),
                              );
                            },
                          ),
                        ),

                        // Outermost Concentric Halo / Bezel
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF1F5F9), Color(0xFFCBD5E1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 10,
                                offset: Offset(-4, -4),
                              ),
                            ],
                          ),
                          child: Center(
                            // Red 3D SOS Dome
                            child: AnimatedScale(
                              scale: _isHolding ? 0.94 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              child: Container(
                                width: 136,
                                height: 136,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    center: Alignment(-0.2, -0.3),
                                    radius: 0.85,
                                    colors: [
                                      Color(0xFFFF4D4D),
                                      Color(0xFFE02424),
                                      Color(0xFF991B1B),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.5),
                                      blurRadius: 22,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Exclamation circle badge
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '!',
                                          style: TextStyle(
                                            color: Color(0xFFDC2626),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // "S O S" text
                                    Text(
                                      'S O S',
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 4.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    // "EMERGENCY PUSH" text
                                    Text(
                                      _isHolding ? 'HOLD ($_secondsLeft s)' : 'EMERGENCY PUSH',
                                      style: GoogleFonts.manrope(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Subtitle Instruction
                Text(
                  'HOLD 3 SECONDS FOR SATELLITE BEACON',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.darkCharcoal,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 12),

                // Recessed Iridium Constellation Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Iridium 66 Constellation • 0 Latency',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF475569),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Concentric Radar Arcs Watermark Painter
class _RadarArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width, 0);

    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 70, paint);
    canvas.drawCircle(center, 100, paint);
    canvas.drawCircle(center, 130, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
