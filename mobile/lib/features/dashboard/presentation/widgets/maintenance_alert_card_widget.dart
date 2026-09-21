import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Action Alert Banner — skeuomorphic raised card with orange extrusion stripe
class MaintenanceAlertCardWidget extends StatelessWidget {
  final VoidCallback? onScheduleService;
  final VoidCallback? onDismiss;

  const MaintenanceAlertCardWidget({
    super.key,
    this.onScheduleService,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return SkeuomorphicContainer(
      borderRadius: 22,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Vertical orange extrusion stripe ──────────────────────
              Container(
                width: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.tacticalOrangeLight,
                      AppColors.tacticalOrange,
                      AppColors.tacticalOrangeDark,
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33F56500),
                      offset: Offset(3, 0),
                      blurRadius: 6,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Recessed icon badge
                          SkeuomorphicInsetContainer(
                            borderRadius: 12,
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.build_rounded,
                              color: AppColors.terracotta,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Necessary Maintenance',
                              style: TextStyle(
                                color: AppColors.darkCharcoal,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: AppColors.alertRedBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'DUE SOON',
                              style: TextStyle(
                                color: AppColors.alertRed,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 9),

                      const Text(
                        'Brake fluid flush & rear brake pad check due in 350 miles.',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          // Glowing extruded orange primary button
                          SkeuomorphicOrangeButton(
                            label: 'Schedule Service',
                            onTap: onScheduleService,
                          ),

                          const SizedBox(width: 14),

                          GestureDetector(
                            onTap: onDismiss,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 8),
                              child: Text(
                                'Dismiss',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
