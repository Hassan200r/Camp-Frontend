import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';

/// CAMP Mountain Mark Logo Painter
class CampMountainLogoPainter extends CustomPainter {
  const CampMountainLogoPainter();

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mode of leading button on [CampAppBar]
enum CampAppBarLeading {
  menu,
  back,
  none,
}

/// CAMP Top App Bar
/// Circular back/menu button left, CAMP logo center, optional action pill right.
class CampAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CampAppBar({
    super.key,
    this.leading = CampAppBarLeading.menu,
    this.onLeadingPressed,
    this.titleText,
    this.actionText,
    this.actionIcon,
    this.actionWidget,
    this.onActionPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
  });

  final CampAppBarLeading leading;
  final VoidCallback? onLeadingPressed;
  final String? titleText;
  final String? actionText;
  final IconData? actionIcon;
  final Widget? actionWidget;
  final VoidCallback? onActionPressed;
  final EdgeInsetsGeometry padding;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Left: Circular Back / Menu Button ─────────────────────────────
          _buildLeading(context),

          // ── Center: Title or CAMP Mountain Logo ───────────────────────────
          if (titleText != null)
            Text(
              titleText!,
              style: GoogleFonts.manrope(
                color: AppColors.darkCharcoal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomPaint(
                  size: Size(22, 18),
                  painter: CampMountainLogoPainter(),
                ),
                const SizedBox(width: 8),
                Text(
                  'CAMP',
                  style: GoogleFonts.manrope(
                    color: AppColors.darkCharcoal,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),

          // ── Right: Optional Action Pill or Widget ─────────────────────────
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading == CampAppBarLeading.none) {
      return const SizedBox(width: 48, height: 48);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLeadingPressed ?? (leading == CampAppBarLeading.back ? () => Navigator.of(context).maybePop() : null),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.clay,
          shape: BoxShape.circle,
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Center(
          child: leading == CampAppBarLeading.back
              ? const Icon(Icons.arrow_back_rounded, color: AppColors.darkCharcoal, size: 20)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bar(),
                    const SizedBox(height: 3.2),
                    _bar(),
                    const SizedBox(height: 3.2),
                    _bar(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _bar() => Container(
        width: 17,
        height: 2.2,
        decoration: BoxDecoration(
          color: AppColors.darkCharcoal,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildAction() {
    if (actionWidget != null) {
      return actionWidget!;
    }

    if (actionText != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onActionPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.clay,
            borderRadius: BorderRadius.circular(AppColors.radiusPill),
            boxShadow: AppColors.skeuRaisedSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actionIcon != null) ...[
                Icon(actionIcon, size: 15, color: AppColors.tacticalOrange),
                const SizedBox(width: 6),
              ],
              Text(
                actionText!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: AppColors.terracotta,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox(width: 48, height: 48);
  }
}
