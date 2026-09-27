import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/maintenance_item_model.dart';

/// One row entry for a maintenance telemetry or inspection item
class MaintenanceItemCardWidget extends StatelessWidget {
  const MaintenanceItemCardWidget({
    required this.item,
    super.key,
    this.onActionPressed,
    this.onTap,
  });

  final MaintenanceItem item;
  final VoidCallback? onActionPressed;
  final VoidCallback? onTap;

  Widget _buildStatusValueWidget() {
    final val = item.statusValueDisplay ?? '';
    if (val == 'OK') {
      return const StatusChip(
        label: 'OK',
        variant: StatusChipVariant.success,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
    } else if (val == 'DIY') {
      return const StatusChip(
        label: 'DIY',
        variant: StatusChipVariant.gold,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      );
    } else if (val.startsWith('T-')) {
      return Text(
        val,
        style: GoogleFonts.manrope(
          color: AppColors.tacticalOrangeDark,
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
        ),
      );
    } else {
      return Text(
        val,
        style: GoogleFonts.manrope(
          color: AppColors.darkCharcoal,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = item.status == MaintenanceStatus.ok;

    return CampCard(
      padding: const EdgeInsets.all(14),
      borderRadius: AppColors.radiusTile,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upper Item Info Row ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Icon
              IconTile(
                icon: item.icon ?? Icons.build_circle_rounded,
                size: 38,
                iconSize: 18,
                isInset: true,
              ),
              const SizedBox(width: 12),

              // Title, Mode chip & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.itemTitle.copyWith(
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusChip(
                          label: item.trackingMode == MaintenanceTrackingMode.auto
                              ? 'Auto'
                              : 'Manual',
                          variant: item.trackingMode ==
                                  MaintenanceTrackingMode.manual
                              ? StatusChipVariant.gold
                              : StatusChipVariant.neutral,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                      ],
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right status value (e.g. $85, OK, DIY, T-45%, $65)
              _buildStatusValueWidget(),
            ],
          ),

          // ── Bottom Warning / Condition Row ────────────────────────────────
          if (item.conditionNote != null ||
              item.actionLabel != null ||
              item.trailingNote != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSuccess
                    ? const Color(0xFFDCFCE7).withValues(alpha: 0.5)
                    : const Color(0xFFFFEDD5).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline_rounded
                        : Icons.warning_amber_rounded,
                    size: 14,
                    color: isSuccess
                        ? AppColors.statusGreen
                        : AppColors.tacticalOrangeDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.conditionNote ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isSuccess
                            ? AppColors.statusGreen
                            : AppColors.tacticalOrangeDark,
                      ),
                    ),
                  ),

                  // Trailing "View Guide" action button OR Trailing Note
                  if (item.actionLabel != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onActionPressed ??
                          () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening Guide for ${item.name}...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.darkCharcoal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          item.actionLabel!,
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.tacticalOrangeDark,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.tacticalOrangeDark,
                          ),
                        ),
                      ),
                    )
                  else if (item.trailingNote != null)
                    Text(
                      item.trailingNote!,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
