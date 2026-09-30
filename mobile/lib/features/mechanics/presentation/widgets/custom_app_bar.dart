import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

class CustomAppBar extends StatefulWidget {

  const CustomAppBar({
    super.key,
    this.onBackTap,
    this.onGpsTap,
  });
  final VoidCallback? onBackTap;
  final VoidCallback? onGpsTap;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          GestureDetector(
            onTap: widget.onBackTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.clay,
                border: Border.all(color: AppColors.clayDark, width: 1.2),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ),

          // CAMP Brand Title with Orange Dot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CAMP',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tacticalOrangeLight,
                ),
              ),
            ],
          ),

          // Status Badge with Pulsing Dot
          GestureDetector(
            onTap: widget.onGpsTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.clayDark, width: 1.2),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 10 * _pulseAnimation.value,
                            height: 10 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.statusGreen.withValues(
                                alpha: (0.35 * (1.4 - (_pulseAnimation.value - 0.8))).clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.statusGreen,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GPS LOCKED',
                    style: AppTextStyles.overline.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
