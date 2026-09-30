import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/emergency_sos_controller.dart';

/// Card 2: Current Location Card with Accuracy Badge & Topographic Radar Preview
class TelemetryStreamCard extends StatelessWidget {
  const TelemetryStreamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmergencySosController.instance,
      builder: (context, _) {
        final telemetry = EmergencySosController.instance.telemetry;

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
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFFF8A00),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Location',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF1E293B),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4F7E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${telemetry.accuracy} accuracy (Cellular/GPS)',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF059669),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Location & Coordinates ─────────────────────────────────────
              Text(
                telemetry.locationName,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF1E293B),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                telemetry.coordinates,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 12),

              // ── Topographic Elevation Radar Box ────────────────────────────
              Container(
                height: 76,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Topographic subtle wave curves
                    CustomPaint(
                      size: const Size(double.infinity, 76),
                      painter: _TopographicCurvesPainter(),
                    ),

                    // Centered Red Radar Pin
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE53935).withValues(alpha: 0.18),
                      ),
                      child: Center(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE53935),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.gps_fixed_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
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

/// Painter for subtle topographical curves in location card
class _TopographicCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wave1Paint = Paint()
      ..color = const Color(0xFFE5EAF0)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.75,
        size.width,
        size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, wave1Paint);

    final wave2Paint = Paint()
      ..color = const Color(0xFFDBE2EA)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.9,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
