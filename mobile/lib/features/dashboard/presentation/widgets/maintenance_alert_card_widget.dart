import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../maintenance/controllers/maintenance_controller.dart';
import '../../../maintenance/domain/maintenance_prediction_engine.dart';
import '../../../maintenance/presentation/screens/service_schedule_screen.dart';

/// Action Alert Banner — driven by [MaintenanceController] and the maintenance rule engine.
/// Shows the most urgent item (Overdue > Due soon), or a neutral empty state when nothing
/// is due or no odometer data exists. Tapping the card opens the Maintenance hub (Finances tab).
class MaintenanceAlertCardWidget extends StatelessWidget {
  const MaintenanceAlertCardWidget({
    super.key,
    this.bikeId,
    this.onScheduleService,
    this.onDismiss,
    this.onTap,
  });

  final String? bikeId;
  final VoidCallback? onScheduleService;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  void _openMaintenanceHub(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    CampBottomNav.navigateToTab(context, CampTab.finances);
  }

  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ActiveBikeController.instance,
        MaintenanceController.instance,
      ]),
      builder: (context, _) {
        final bike = (bikeId != null && bikeId!.isNotEmpty)
            ? ActiveBikeController.instance.getBikeById(bikeId!)
            : ActiveBikeController.instance.activeBike;

        final hasData = MaintenanceController.instance.hasMaintenanceData(bike);
        final due = MaintenanceController.instance.dueItems(bike?.id);
        final urgentItem = due.isNotEmpty ? due.first : null;
        final otherDueCount = due.length > 1 ? due.length - 1 : 0;

        // ── 1. Neutral Empty State: No bike or no odometer data ──────────────
        if (bike == null || !hasData) {
          return CampCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: InkWell(
              onTap: () => _openMaintenanceHub(context),
              borderRadius: BorderRadius.circular(AppColors.radiusCard),
              child: Row(
                children: [
                  const IconTile(
                    icon: Icons.speed_rounded,
                    iconColor: AppColors.mutedText,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maintenance Schedule',
                          style: AppTextStyles.itemTitle.copyWith(
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Add your bike's odometer to get reminders",
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedLight,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }

        // ── 2. Neutral Empty State: All maintenance up to date ───────────────
        if (urgentItem == null) {
          return CampCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: InkWell(
              onTap: () => _openMaintenanceHub(context),
              borderRadius: BorderRadius.circular(AppColors.radiusCard),
              child: Row(
                children: [
                  const IconTile(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.statusGreen,
                    size: 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No maintenance due',
                          style: AppTextStyles.itemTitle.copyWith(
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All inspected systems are within schedule',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'UP TO DATE',
                    variant: StatusChipVariant.success,
                  ),
                ],
              ),
            ),
          );
        }

        // ── 3. Active Urgent Alert (Overdue > Due soon) ──────────────────────
        final isOverdue = urgentItem.status == ComponentStatus.overdue;
        final stripeColors = isOverdue
            ? const [Color(0xFFEF4444), AppColors.alertRed, Color(0xFFB91C1C)]
            : const [
                AppColors.tacticalOrangeLight,
                AppColors.tacticalOrange,
                AppColors.tacticalOrangeDark,
              ];

        final String descriptionText;
        if (isOverdue) {
          final kmOverdue =
              urgentItem.remainingKm != null && urgentItem.remainingKm! <= 0;
          final daysOverdue =
              urgentItem.remainingDays != null && urgentItem.remainingDays! <= 0;
          if (kmOverdue && daysOverdue) {
            final overKm = urgentItem.remainingKm!.abs();
            final overDays = urgentItem.remainingDays!.abs();
            final parts = [
              if (overKm > 0) '${_formatNumber(overKm)} km',
              if (overDays > 0) '$overDays ${overDays == 1 ? 'day' : 'days'}',
            ];
            descriptionText =
                parts.isEmpty ? 'Overdue' : 'Overdue by ${parts.join(', ')}';
          } else if (kmOverdue) {
            final overKm = urgentItem.remainingKm!.abs();
            descriptionText =
                overKm == 0 ? 'Overdue' : 'Overdue by ${_formatNumber(overKm)} km';
          } else if (daysOverdue) {
            final overDays = urgentItem.remainingDays!.abs();
            descriptionText = overDays == 0
                ? 'Overdue today'
                : 'Overdue by $overDays ${overDays == 1 ? 'day' : 'days'}';
          } else {
            descriptionText = 'Overdue';
          }
        } else {
          if (urgentItem.remainingKm != null) {
            descriptionText = 'Due in ${_formatNumber(urgentItem.remainingKm!)} km';
          } else if (urgentItem.remainingDays != null) {
            descriptionText = 'Due in ${urgentItem.remainingDays} ${urgentItem.remainingDays == 1 ? 'day' : 'days'}';
          } else {
            descriptionText = 'Due soon';
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CampCard(
              padding: EdgeInsets.zero,
              child: InkWell(
                onTap: () => _openMaintenanceHub(context),
                borderRadius: BorderRadius.circular(AppColors.radiusCard),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppColors.radiusCard),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Vertical extrusion stripe ─────────────────────────────
                        Container(
                          width: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: stripeColors,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isOverdue
                                        ? AppColors.alertRed
                                        : AppColors.tacticalOrange)
                                    .withValues(alpha: 0.25),
                                offset: const Offset(3, 0),
                                blurRadius: 6,
                              ),
                            ],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppColors.radiusCard),
                              bottomLeft: Radius.circular(AppColors.radiusCard),
                            ),
                          ),
                        ),

                        // ── Card body ───────────────────────────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconTile(
                                      icon: isOverdue
                                          ? Icons.warning_amber_rounded
                                          : Icons.build_rounded,
                                      iconColor: isOverdue
                                          ? AppColors.alertRed
                                          : AppColors.terracotta,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        urgentItem.name,
                                        style: AppTextStyles.itemTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    StatusChip(
                                      label: isOverdue ? 'OVERDUE' : 'DUE SOON',
                                      variant: StatusChipVariant.danger,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 9),

                                Text(
                                  descriptionText,
                                  style: AppTextStyles.bodySecondary,
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    PrimaryButton(
                                      label: 'Schedule Service',
                                      onTap: onScheduleService ??
                                          () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) => ServiceScheduleScreen(
                                                  bikeId: bike.id,
                                                  focusItemType: urgentItem.type,
                                                ),
                                              ),
                                            );
                                          },
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    if (onDismiss != null)
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
              ),
            ),
            if (otherDueCount > 0) ...[
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ServiceScheduleScreen(bikeId: bike.id),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '+$otherDueCount more due',
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
