import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';

/// Card housing the Route Packs Wi-Fi auto-update preference toggle.
/// Conforms to CAMP honesty rules: no unbacked storage allocation claims or GB sizes.
class StorageAllocationCardWidget extends StatelessWidget {
  const StorageAllocationCardWidget({
    super.key,
    this.isWifiAutoUpdate = true,
    this.onWifiAutoUpdateChanged,
  });

  final bool isWifiAutoUpdate;
  final ValueChanged<bool>? onWifiAutoUpdateChanged;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    'Auto-update route packs via Wi-Fi',
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
