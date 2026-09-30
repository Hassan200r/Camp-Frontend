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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
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
                    width: 188,
                    height: 188,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 4,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFE53935),
                          ),
                          backgroundColor: Colors.transparent,
                        );
                      },
                    ),
                  ),

                  // Outermost Concentric Halo / Bezel
                  Container(
                    width: 174,
                    height: 174,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFF1F4F8), Color(0xFFE2E7EE)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 8,
                          offset: Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Center(
                      // Red 3D SOS Dome
                      child: AnimatedScale(
                        scale: _isHolding ? 0.94 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.1, -0.35),
                              radius: 0.85,
                              colors: [
                                Color(0xFFFF3B50),
                                Color(0xFFE51D33),
                                Color(0xFFC71024),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE51D33).withValues(alpha: 0.45),
                                blurRadius: 22,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Asterisk / Star icon
                              const Text(
                                '*',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // "SOS" text
                              Text(
                                'SOS',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // "EMERGENCY" text
                              Text(
                                _isHolding ? 'HOLD ($_secondsLeft s)' : 'EMERGENCY',
                                style: GoogleFonts.manrope(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
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
            'Hold 3 seconds to alert your emergency\ncontact',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: const Color(0xFF1E293B),
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // Recessed GPS & Cellular signal pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(AppColors.radiusPill),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sensors_rounded,
                  color: Color(0xFF64748B),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  "Uses your phone's GPS and cellular signal",
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF64748B),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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
