import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Top Navigation Bar — skeuomorphic raised buttons and badge
class AppHeaderWidget extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBadgePressed;

  const AppHeaderWidget({
    super.key,
    this.onMenuPressed,
    this.onBadgePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: Skeuomorphic Raised Circular Hamburger Button ────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onMenuPressed,
            child: SkeuomorphicContainer(
              borderRadius: 100,
              shadows: AppColors.skeuRaisedSmall,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bar(AppColors.darkCharcoal),
                      const SizedBox(height: 3.2),
                      _bar(AppColors.darkCharcoal),
                      const SizedBox(height: 3.2),
                      _bar(AppColors.darkCharcoal),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Center: CAMP mountain logo + wordmark ─────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: const Size(22, 18),
                painter: _CampMountainLogoPainter(),
              ),
              const SizedBox(width: 8),
              const Text(
                'CAMP',
                style: TextStyle(
                  color: AppColors.darkCharcoal,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
            ],
          ),

          // ── Right: Skeuomorphic Raised "EXPLORE HOME" Badge ───────────────
          GestureDetector(
            onTap: onBadgePressed,
            child: SkeuomorphicContainer(
              borderRadius: 24,
              shadows: AppColors.skeuRaisedSmall,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: const Text(
                'EXPLORE HOME',
                style: TextStyle(
                  color: AppColors.terracotta,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(Color color) => Container(
        width: 17,
        height: 2.2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

// ─── Mountain logo painter ──────────────────────────────────────────────────
class _CampMountainLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final greenPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    final orangePaint = Paint()
      ..color = AppColors.tacticalOrange
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width * 0.45, size.height * 0.1)
        ..lineTo(size.width * 0.7, size.height)
        ..close(),
      greenPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.4, size.height)
        ..lineTo(size.width * 0.75, 0)
        ..lineTo(size.width, size.height)
        ..close(),
      orangePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Dashed circle border painter ──────────────────────────────────────────
// class DashedCircleBorderPainter extends CustomPainter {
//   final Color color;
//   final double dashLength;
//   final double dashGap;
//   final double strokeWidth;

//   DashedCircleBorderPainter({
//     required this.color,
//     required this.dashLength,
//     required this.dashGap,
//     required this.strokeWidth,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke;

//     final double radius = (size.width - strokeWidth) / 2;
//     final center = Offset(size.width / 2, size.height / 2);
//     final double circumference = 2 * math.pi * radius;
//     final int dashCount =
//         (circumference / (dashLength + dashGap)).floor();
//     final double sweepAngle =
//         (dashLength / circumference) * 2 * math.pi;
//     final double gapAngle =
//         (dashGap / circumference) * 2 * math.pi;

//     double angle = 0;
//     for (int i = 0; i < dashCount; i++) {
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         angle,
//         sweepAngle,
//         false,
//         paint,
//       );
//       angle += sweepAngle + gapAngle;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant DashedCircleBorderPainter old) =>
//       old.color != color ||
//       old.dashLength != dashLength ||
//       old.dashGap != dashGap ||
//       old.strokeWidth != strokeWidth;
// }
