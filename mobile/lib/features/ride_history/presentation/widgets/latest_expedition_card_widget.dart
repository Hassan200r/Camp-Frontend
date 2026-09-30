import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
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
/// Uses the existing [CockpitHeroCard] shared widget for the container.
class LatestExpeditionCardWidget extends StatelessWidget {
  const LatestExpeditionCardWidget({
    super.key,
    this.onMenuActionSelected,
  });

  final ValueChanged<LatestExpeditionOptionAction>? onMenuActionSelected;

  static const List<Stat> _stats = [
    Stat(label: 'DISTANCE', value: '286.4', unit: 'KM'),
    Stat(label: 'DURATION', value: '5h 42m'),
    Stat(label: 'MAX ALT', value: '4,173', unit: 'M'),
  ];

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Yesterday • Oct 14',
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
            'Babusar Pass Summit & Alpine Ridge',
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
                  text: '🏍 BMW R1250 GS Adventure • ',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                TextSpan(
                  text: 'Tuned Dual CV',
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
              for (int i = 0; i < _stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: DarkStatTile(stat: _stats[i]),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // ── Route progress ────────────────────────────────────────────────
          const RouteProgressWidget(
            startLabel: 'Kaghan Valley',
            peakLabel: 'Summit',
            peakElevation: '4,173m',
            endLabel: 'Chilas Jct',
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
          const Row(
            children: [
              Expanded(
                child: DarkInfoTileWidget(
                  category: 'CARB TUNING',
                  primaryLine: 'Leaned 0.5 Turns\n61kPa at Summit • Nominal',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: DarkInfoTileWidget(
                  category: 'FUEL SPENT',
                  primaryLine: '\$38.40 • 13.8L',
                  noteLine: '\$3.60 under budget',
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
                  label: 'Replay Telemetry',
                  icon: Icons.play_circle_rounded,
                  isPrimary: true,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroButton(
                  label: 'Details',
                  icon: Icons.remove_red_eye_rounded,
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

// ── Private helpers ─────────────────────────────────────────────────────────

class _ExpeditionOptionsMenuButton extends StatelessWidget {
  const _ExpeditionOptionsMenuButton({this.onSelected});

  final ValueChanged<LatestExpeditionOptionAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.clay,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusTile),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
      ),
      child: PopupMenuButton<LatestExpeditionOptionAction>(
        tooltip: 'Expedition options',
        offset: const Offset(0, 36),
        padding: EdgeInsets.zero,
        onSelected: onSelected,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.more_horiz_rounded,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<LatestExpeditionOptionAction>(
            value: LatestExpeditionOptionAction.exportGpx,
            height: 38,
            child: Row(
              children: [
                const Icon(
                  Icons.file_download_outlined,
                  size: 16,
                  color: AppColors.darkCharcoal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Export GPX',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<LatestExpeditionOptionAction>(
            value: LatestExpeditionOptionAction.shareTelemetry,
            height: 38,
            child: Row(
              children: [
                const Icon(
                  Icons.share_outlined,
                  size: 16,
                  color: AppColors.darkCharcoal,
                ),
                const SizedBox(width: 8),
                Text(
                  'Share Ride',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<LatestExpeditionOptionAction>(
            value: LatestExpeditionOptionAction.hideFromArchive,
            height: 38,
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_off_outlined,
                  size: 16,
                  color: AppColors.alertRed,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hide from Archive',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.alertRed,
                  ),
                ),
              ],
            ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.tacticalOrange
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          boxShadow: isPrimary ? AppColors.orangeGlow : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
