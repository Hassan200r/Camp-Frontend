import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

/// Storage allocation card showing device memory usage for topo and route packs.
/// Includes large usage stat, segmented bar, legend, and an InsetTile-boxed
/// Wi-Fi auto-update switch toggle.
class StorageAllocationCardWidget extends StatelessWidget {
  const StorageAllocationCardWidget({
    super.key,
    this.usedGb = '3.4 GB',
    this.totalFreeGb = '32 GB Free',
    this.isWifiAutoUpdate = true,
    this.onWifiAutoUpdateChanged,
  });

  final String usedGb;
  final String totalFreeGb;
  final bool isWifiAutoUpdate;
  final ValueChanged<bool>? onWifiAutoUpdateChanged;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Big value & subtitle ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                usedGb,
                style: GoogleFonts.manrope(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'used of $totalFreeGb',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Segmented progress bar ────────────────────────────────────────
          // Routes 2.2 GB (orange) | Topo Base 1.2 GB (navy) | Free 28.6 GB (grey)
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: 22,
                    child: Container(color: AppColors.tacticalOrange),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 12,
                    child: Container(color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 286,
                    child: Container(color: AppColors.clayDark),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Legend with colored dots ──────────────────────────────────────
          const Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _LegendItem(
                color: AppColors.tacticalOrange,
                label: 'Routes (2.2 GB)',
              ),
              _LegendItem(
                color: Color(0xFF1E293B),
                label: 'Topo Base (1.2 GB)',
              ),
              _LegendItem(
                color: AppColors.mutedLight,
                label: 'Free (28.6 GB)',
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Wi-Fi auto-update switch in InsetTile ─────────────────────────
          InsetTile(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_rounded,
                  size: 20,
                  color: AppColors.darkCharcoal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Auto-update topo via Wi-Fi',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isWifiAutoUpdate,
                  activeTrackColor: AppColors.tacticalOrange,
                  onChanged: onWifiAutoUpdateChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}
