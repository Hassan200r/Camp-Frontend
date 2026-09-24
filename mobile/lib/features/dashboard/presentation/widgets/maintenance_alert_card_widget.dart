import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Action Alert Banner — skeuomorphic raised card with orange extrusion stripe
class MaintenanceAlertCardWidget extends StatelessWidget {
  const MaintenanceAlertCardWidget({
    super.key,
    this.onScheduleService,
    this.onDismiss,
  });

  final VoidCallback? onScheduleService;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Vertical orange extrusion stripe ───────────────────────
              Container(
                width: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange, AppColors.tacticalOrangeDark],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33F56500), offset: Offset(3, 0), blurRadius: 6),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppColors.radiusCard),
                    bottomLeft: Radius.circular(AppColors.radiusCard),
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
                          IconTile(icon: Icons.build_rounded, iconColor: AppColors.terracotta),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Necessary Maintenance', style: AppTextStyles.itemTitle),
                          ),
                          const StatusChip(label: 'DUE SOON', variant: StatusChipVariant.danger),
                        ],
                      ),

                      const SizedBox(height: 9),

                      Text(
                        'Brake fluid flush & rear brake pad check due in 560 km.',
                        style: AppTextStyles.bodySecondary,
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          PrimaryButton(
                            label: 'Schedule Service',
                            onTap: onScheduleService,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          GhostButton(
                            label: 'Dismiss',
                            onTap: onDismiss,
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
