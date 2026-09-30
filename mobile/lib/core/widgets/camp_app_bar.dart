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
    this.titleWidget,
    this.actionText,
    this.actionIcon,
    this.actionWidget,
    this.onActionPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
  });

  final CampAppBarLeading leading;
  final VoidCallback? onLeadingPressed;
  final String? titleText;
  final Widget? titleWidget;
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

          // ── Center: Custom Widget, Title or CAMP Dot Logo ────────────────
          if (titleWidget != null)
            titleWidget!
          else if (titleText != null && titleText != 'CAMP')
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
            const CampLogo(),

          // ── Right: Optional Action Pill or Widget ─────────────────────────
          Flexible(
            child: _buildAction(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading == CampAppBarLeading.none) {
      return const SizedBox(width: 48, height: 48);
    }

    if (leading == CampAppBarLeading.back) {
      return CampBackButton(onTap: onLeadingPressed);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onLeadingPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.clay,
          shape: BoxShape.circle,
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Center(
          child: Column(
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
              Flexible(
                child: Text(
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
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox(width: 48, height: 48);
  }
}

/// Circular back button styled with CAMP 48px circle and skeuRaisedSmall shadow.
class CampBackButton extends StatelessWidget {
  const CampBackButton({
    super.key,
    this.onTap,
    this.icon = Icons.arrow_back_rounded,
  });

  final VoidCallback? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.clay,
          shape: BoxShape.circle,
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Center(
          child: Icon(icon, color: AppColors.darkCharcoal, size: 20),
        ),
      ),
    );
  }
}

/// Standard CAMP Logo: bold "CAMP" text with tactical orange dot mark.
class CampLogo extends StatelessWidget {
  const CampLogo({
    super.key,
    this.fontSize = 20,
    this.dotSize = 7,
  });

  final double fontSize;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'CAMP',
          style: GoogleFonts.manrope(
            color: AppColors.darkCharcoal,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 5),
        Container(
          width: dotSize,
          height: dotSize,
          decoration: const BoxDecoration(
            color: AppColors.tacticalOrange,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

