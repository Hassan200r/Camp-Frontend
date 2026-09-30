import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/route_pack_model.dart';

/// Card representing a single offline topographic route pack.
/// Renders title, size & category, status badge, description, InsetTile note/progress,
/// and contextual action button (Sync Update, Pause, or Download Pack).
class RoutePackCardWidget extends StatelessWidget {
  const RoutePackCardWidget({
    required this.pack,
    super.key,
    this.onActionTap,
  });

  final RoutePack pack;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return CampCard(
      padding: const EdgeInsets.all(AppColors.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Title, Specs & Status Badge ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: GoogleFonts.manrope(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${pack.sizeMb} MB • ${pack.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 10),

          // ── Description ───────────────────────────────────────────────────
          Text(
            pack.description,
            style: GoogleFonts.manrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkCharcoal.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),

          // ── Note row in InsetTile ─────────────────────────────────────────
          if (pack.note != null) ...[
            const SizedBox(height: 10),
            InsetTile(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    pack.noteIcon ?? Icons.info_outline_rounded,
                    size: 15,
                    color: pack.status == RoutePackStatus.saved
                        ? AppColors.tacticalOrange
                        : AppColors.mutedText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pack.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: pack.status == RoutePackStatus.saved
                            ? AppColors.tacticalOrangeDark
                            : AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Downloading progress in InsetTile ─────────────────────────────
          if (pack.status == RoutePackStatus.downloading) ...[
            const SizedBox(height: 10),
            InsetTile(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${pack.downloadedMb ?? 312} MB of ${pack.sizeMb} MB',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        pack.downloadSpeed ?? '4.2 MB/s',
                        style: GoogleFonts.manrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.tacticalOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pack.downloadProgress ?? 0.68,
                      minHeight: 6,
                      backgroundColor: AppColors.clay,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.tacticalOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Action Buttons ────────────────────────────────────────────────
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (pack.status == RoutePackStatus.saved) {
      return const StatusChip(
        label: 'Saved',
        variant: StatusChipVariant.success,
        icon: Icons.check_circle_rounded,
      );
    }

    if (pack.status == RoutePackStatus.downloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.tacticalOrange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              pack.statusLabel ?? '68% DOWNLOADING',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.tacticalOrangeDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton() {
    switch (pack.actionType) {
      case RoutePackActionType.syncUpdate:
        return Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.darkCharcoal,
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sync_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pack.actionLabel ?? 'Sync Update',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case RoutePackActionType.pause:
        return Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.clayDark,
                borderRadius: BorderRadius.circular(AppColors.radiusPill),
                boxShadow: AppColors.skeuRaisedSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pause_rounded,
                    size: 14,
                    color: AppColors.darkCharcoal,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pack.actionLabel ?? 'Pause',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case RoutePackActionType.download:
        return PrimaryButton(
          label: pack.actionLabel ?? 'Download Pack (${pack.sizeMb} MB)',
          icon: Icons.download_rounded,
          isFullWidth: true,
          onTap: onActionTap,
        );
    }
  }
}
