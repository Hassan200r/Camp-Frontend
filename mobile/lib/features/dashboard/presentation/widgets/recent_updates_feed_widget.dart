import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../maintenance/controllers/post_ride_report_controller.dart';
import '../../../maintenance/domain/maintenance_prediction_engine.dart';
import '../../../maintenance/domain/post_ride_report.dart';

/// Recent Updates Feed — restores Weather card (tap navigates to [WeatherDetailScreen])
/// and Group Beacon card (tap opens "Coming in a future update" dialog),
/// alongside real activity and vehicle status updates.
class RecentUpdatesFeedWidget extends StatelessWidget {
  const RecentUpdatesFeedWidget({
    super.key,
    this.onMarkAllRead,
    this.onViewRadar,
    this.onLocateBeacon,
  });

  final VoidCallback? onMarkAllRead;
  final VoidCallback? onViewRadar;
  final VoidCallback? onLocateBeacon;

  void _showComingSoonDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.clay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        title: Text('Group Beacon', style: AppTextStyles.cardTitle),
        content: Text(
          'Coming in a future update',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: AppColors.tacticalOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ActiveBikeController.instance,
        PostRideReportController.instance,
      ]),
      builder: (context, _) {
        final bike = ActiveBikeController.instance.activeBike;
        final reports = PostRideReportController.instance.reports;
        final PostRideReport? lastRide = reports.isNotEmpty ? reports.first : null;

        // Compute maintenance prediction if bike exists
        ComponentPrediction? soonestComponent;
        bool hasDueMaintenance = false;
        if (bike != null) {
          final bikeReports =
              PostRideReportController.instance.getReportsForBike(bike.id);
          final assessment = MaintenancePredictionEngine.analyze(
            bike: bike,
            rideReports: bikeReports,
          );
          if (assessment.components.isNotEmpty) {
            final top = assessment.components.first;
            if (top.wearPercent >= 50 || top.remainingKm <= 1500) {
              soonestComponent = top;
              hasDueMaintenance = true;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ─────────────────────────────────────────────
            SectionHeader(
              title: 'Recent Updates & Advisories',
              badge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.tacticalOrangeLight,
                      AppColors.tacticalOrange,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  boxShadow: AppColors.orangeGlow,
                ),
                child: const Text(
                  'Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              actionLabel: 'Mark all read',
              onAction: onMarkAllRead,
            ),

            // ── 1. Weather Advisory Card ───────────────────────────────────
            _activityCard(
              context: context,
              icon: Icons.air_rounded,
              iconColor: const Color(0xFFD97706),
              title: 'Weather',
              timeBadge: '',
              description: 'Weather: tap for forecast',
              actionLabel: 'View Forecast',
              actionIcon: Icons.wb_sunny_rounded,
              onAction: onViewRadar ??
                  () => Navigator.of(context).pushNamed(CampRoutes.weatherDetail),
            ),

            const SizedBox(height: 10),

            // ── 2. Group Beacon Card ───────────────────────────────────────
            _activityCard(
              context: context,
              icon: Icons.track_changes_rounded,
              iconColor: const Color(0xFF0D9488),
              title: 'Group Beacon',
              timeBadge: '',
              description: 'Group Beacon: coming soon',
              actionLabel: 'Locate',
              actionIcon: Icons.near_me_rounded,
              onAction: onLocateBeacon ?? () => _showComingSoonDialog(context),
            ),

            const SizedBox(height: 10),

            // ── 3. Maintenance Due / Vehicle Status ────────────────────────
            if (hasDueMaintenance && soonestComponent != null) ...[
              _activityCard(
                context: context,
                icon: Icons.build_circle_rounded,
                iconColor: AppColors.tacticalOrange,
                title: 'Service Due Soon: ${soonestComponent.name}',
                timeBadge: '${soonestComponent.remainingKm} km left',
                description: soonestComponent.reason,
                actionLabel: 'Schedule Service',
                actionIcon: Icons.calendar_today_rounded,
                onAction: () =>
                    Navigator.of(context).pushNamed(CampRoutes.mechanics),
              ),
            ] else if (lastRide != null) ...[
              _activityCard(
                context: context,
                icon: Icons.route_rounded,
                iconColor: AppColors.statusGreen,
                title:
                    'Last Ride: ${lastRide.date.month}/${lastRide.date.day}/${lastRide.date.year}',
                timeBadge: '${lastRide.distanceKm.round()} km',
                description: lastRide.terrainTags.isNotEmpty
                    ? 'Terrain: ${lastRide.terrainTags.join(', ')}'
                    : lastRide.notes ?? 'Logged expedition ride',
                actionLabel: 'View Log',
                actionIcon: Icons.notes_rounded,
                onAction: () =>
                    Navigator.of(context).pushNamed(CampRoutes.rideHistory),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _activityCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String timeBadge,
    required String description,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) {
    return CampCard(
      borderRadius: AppColors.radiusTile + 2,
      child: InkWell(
        onTap: onAction,
        borderRadius: BorderRadius.circular(AppColors.radiusTile + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recessed icon well
            IconTile(
              icon: icon,
              iconColor: iconColor,
              size: 42,
              borderRadius: 14,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeBadge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(timeBadge, style: AppTextStyles.caption),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    description,
                    style: AppTextStyles.bodySecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Raised pill action button
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAction,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusTile),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(actionIcon,
                              size: 14, color: AppColors.terracotta),
                          const SizedBox(width: 6),
                          Text(
                            actionLabel,
                            style: AppTextStyles.overlineTerracotta.copyWith(
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}