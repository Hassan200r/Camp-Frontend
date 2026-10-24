import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../maintenance/controllers/trip_budget_controller.dart';
import '../../../maintenance/domain/expense_model.dart';
import '../../../maintenance/domain/post_ride_report.dart';
import '../../../maintenance/domain/trip_budget_model.dart';
import '../../domain/stat_model.dart';
import 'dark_info_tile_widget.dart';
import 'dark_stat_tile_widget.dart';
import 'elevation_chart_widget.dart';
import 'route_progress_widget.dart';

enum LatestExpeditionOptionAction {
  exportGpx,
  shareTelemetry,
  hideFromArchive,
}

/// Widget #8 — Dark cockpit-gradient hero card for the latest expedition.
/// Shows real ride report data and fuel entries, or an empty state ("No trips yet")
/// when no rides exist. In debug sample mode, demo data is explicitly labelled "Demo data".
class LatestExpeditionCardWidget extends StatelessWidget {
  const LatestExpeditionCardWidget({
    super.key,
    this.report,
    this.isDemo = false,
    this.onMenuActionSelected,
  });

  final PostRideReport? report;
  final bool isDemo;
  final ValueChanged<LatestExpeditionOptionAction>? onMenuActionSelected;

  @override
  Widget build(BuildContext context) {
    if (report == null) {
      return CockpitHeroCard(
        innerPadding: const EdgeInsets.all(AppColors.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.tacticalOrange,
                    borderRadius: BorderRadius.circular(AppColors.radiusPill),
                  ),
                  child: Text(
                    'LATEST EXPEDITION',
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.two_wheeler_rounded,
                    size: 38,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No trips yet',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record a ride to view route stats, fuel spent, and elevation profile.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    final effectiveReport = report!;
    final dateDisplay = formatTripDate(effectiveReport.date);
    final activeBike = ActiveBikeController.instance.activeBike;
    final bikeName = activeBike != null
        ? '${activeBike.make} ${activeBike.modelName}'
        : 'BMW R1250 GS Adventure';

    final title = effectiveReport.notes != null &&
            effectiveReport.notes!.trim().isNotEmpty
        ? effectiveReport.notes!.trim()
        : (effectiveReport.terrainTags.isNotEmpty
            ? '${effectiveReport.terrainTags.join(' • ')} Expedition'
            : 'Expedition Ride Debrief');

    final stats = [
      Stat(
        label: 'DISTANCE',
        value: effectiveReport.distanceKm > 0
            ? effectiveReport.distanceKm.toStringAsFixed(1)
            : '0.0',
        unit: 'KM',
      ),
      Stat(
        label: 'DATE',
        value: '${kTripMonths[effectiveReport.date.month - 1]} ${effectiveReport.date.day}',
      ),
      Stat(
        label: 'TERRAIN',
        value: effectiveReport.terrainTags.isNotEmpty
            ? effectiveReport.terrainTags.first
            : 'Trail',
      ),
    ];

    return CockpitHeroCard(
      innerPadding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: badge + date + compact popup menu button ──────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tacticalOrange,
                        borderRadius:
                            BorderRadius.circular(AppColors.radiusPill),
                      ),
                      child: Text(
                        'LATEST EXPEDITION',
                        style: GoogleFonts.manrope(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    if (isDemo) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusPill),
                        ),
                        child: Text(
                          'Demo data',
                          style: GoogleFonts.manrope(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        dateDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _ExpeditionOptionsMenuButton(
                onSelected: onMenuActionSelected,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Title ──────────────────────────────────────────────────────────
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 6),

          // ── Bike line ─────────────────────────────────────────────────────
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '🏍 $bikeName • ',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                TextSpan(
                  text: 'Active Fleet',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tacticalOrange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── 3 dark stats — translucent dark tiles (no glow/shadow) ────────
          Row(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: DarkStatTile(stat: stats[i]),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // ── Route progress ────────────────────────────────────────────────
          const RouteProgressWidget(
            startLabel: 'Basecamp',
            peakLabel: 'Summit',
            peakElevation: 'Elevation',
            endLabel: 'Waypoint',
          ),

          const SizedBox(height: 14),

          // ── Elevation chart ───────────────────────────────────────────────
          Text(
            'ELEVATION & INCLINE PROFILE',
            style: GoogleFonts.manrope(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const ElevationChartWidget(
            points: ElevationChartWidget.defaultPoints,
          ),

          const SizedBox(height: 14),

          // ── Two info tiles ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: DarkInfoTileWidget(
                  category: 'TERRAIN CONDITIONS',
                  primaryLine: effectiveReport.terrainTags.isNotEmpty
                      ? effectiveReport.terrainTags.join('\n')
                      : 'Mountain Pass\nNominal trail conditions',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final activeBike = ActiveBikeController.instance.activeBike;
                    final fuelExpenses = TripBudgetController.instance.expenses
                        .where((e) {
                          if (e.category != ExpenseCategory.fuel) return false;
                          if (activeBike != null && activeBike.id.isNotEmpty) {
                            return e.bikeId == null ||
                                e.bikeId!.isEmpty ||
                                e.bikeId == activeBike.id;
                          }
                          return true;
                        })
                        .toList();
                    final totalFuel = fuelExpenses.fold<double>(
                        0.0, (sum, e) => sum + e.amount);

                    final hasFuel = totalFuel > 0;
                    final primary = hasFuel
                        ? formatPkr(totalFuel)
                        : (isDemo ? '13.8L Refill' : 'No fuel logged');
                    final note = hasFuel
                        ? '${fuelExpenses.length} refill ${fuelExpenses.length == 1 ? 'entry' : 'entries'}'
                        : (isDemo
                            ? 'Demo fuel calculation'
                            : 'Log refill in garage');

                    return DarkInfoTileWidget(
                      category: 'FUEL SPENT',
                      primaryLine: primary,
                      noteLine: note,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Action buttons ─────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _HeroButton(
                  label: 'Replay Track',
                  icon: Icons.play_circle_rounded,
                  isPrimary: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Waypoint Log',
                  icon: Icons.bookmark_border_rounded,
                  isPrimary: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary
        ? AppColors.tacticalOrange
        : Colors.white.withValues(alpha: 0.08);
    final border = isPrimary
        ? Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1)
        : Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1);
    const textColor = Colors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppColors.radiusTile),
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpeditionOptionsMenuButton extends StatelessWidget {
  const _ExpeditionOptionsMenuButton({
    this.onSelected,
  });

  final ValueChanged<LatestExpeditionOptionAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LatestExpeditionOptionAction>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: Colors.white.withValues(alpha: 0.55),
      ),
      color: AppColors.dockBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: LatestExpeditionOptionAction.exportGpx,
          child: Row(
            children: [
              const Icon(
                Icons.file_download_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Text(
                'Export GPX',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: LatestExpeditionOptionAction.shareTelemetry,
          child: Row(
            children: [
              const Icon(
                Icons.share_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Text(
                'Share Ride',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: LatestExpeditionOptionAction.hideFromArchive,
          child: Row(
            children: [
              const Icon(
                Icons.visibility_off_outlined,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 10),
              Text(
                'Hide from Archive',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
