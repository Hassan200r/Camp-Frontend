import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/mechanic_model.dart';

class MechanicCard extends StatelessWidget {
  const MechanicCard({
    required this.mechanic,
    super.key,
    this.onTap,
    this.onCallShop,
    this.onRouteGps,
    this.onEdit,
    this.onDelete,
  });

  final Mechanic mechanic;
  final VoidCallback? onTap;
  final VoidCallback? onCallShop;
  final VoidCallback? onRouteGps;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  static const LinearGradient _orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.clayDark, width: 1.2),
          boxShadow: AppColors.skeuRaised,
        ),
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Rounded Photo Thumbnail + Title & Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rounded Photo Thumbnail slot (or fallback icon)
                _buildPhotoThumbnail(mechanic.photoPath, size: 54),
                const SizedBox(width: 14),

                // Name & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              mechanic.name,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildBadge(),
                              if (onEdit != null) ...[
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppColors.mutedText,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 26,
                                    minHeight: 26,
                                  ),
                                  onPressed: onEdit,
                                ),
                              ],
                              if (onDelete != null) ...[
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: AppColors.mutedText,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 26,
                                    minHeight: 26,
                                  ),
                                  onPressed: onDelete,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Distance, Duration & Beacon Status
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: AppColors.tacticalOrange,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${mechanic.distance}  •  ${mechanic.durationOrLocation}',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: mechanic.beaconColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                mechanic.beaconStatus,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: mechanic.beaconColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Category 1 (e.g. SPECIALTIES / CERTIFIED PLATFORMS)
            if (mechanic.tags1.isNotEmpty) ...[
              Text(
                mechanic.categoryTitle1,
                style: AppTextStyles.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mechanic.tags1
                    .map((tag) => _buildTag(tag))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Category 2 (FIELD CAPABILITIES / LOCATION)
            if (mechanic.tags2.isNotEmpty &&
                !(mechanic.tags2.length == 1 &&
                    mechanic.tags2.first == mechanic.durationOrLocation)) ...[
              Text(
                mechanic.categoryTitle2,
                style: AppTextStyles.overline.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: mechanic.tags2
                    .map((tag) => _buildTag(tag))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Rating & Open Status
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.statusYellow,
                ),
                const SizedBox(width: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${mechanic.rating} ',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: '(${mechanic.reviewCount} reviews)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mutedLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.statusGreen,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      mechanic.openStatus,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons: Call Shop & Route GPS
            Row(
              children: [
                // Call Shop Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: onCallShop,
                      icon: const Icon(
                        Icons.call_outlined,
                        size: 16,
                        color: AppColors.darkCharcoal,
                      ),
                      label: Text(
                        'Call Shop',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        side: const BorderSide(
                          color: AppColors.clayDark,
                          width: 1.2,
                        ),
                        backgroundColor: AppColors.clay,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Route GPS Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: _orangeGradient,
                      boxShadow: AppColors.orangeGlow,
                    ),
                    child: ElevatedButton(
                      onPressed: onRouteGps,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Route GPS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(String? photoPath, {double size = 48}) {
    final file = photoPath != null && photoPath.isNotEmpty ? File(photoPath) : null;
    final exists = file != null && file.existsSync();

    if (exists) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.clayDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.clayDark, width: 1.2),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackThumbnail(size),
          ),
        ),
      );
    }

    return _buildFallbackThumbnail(size);
  }

  Widget _buildFallbackThumbnail(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.clayDark, width: 1.2),
        boxShadow: AppColors.skeuRecessed,
      ),
      child: Center(
        child: Icon(
          Icons.storefront_rounded,
          size: size * 0.48,
          color: AppColors.tacticalOrange,
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (mechanic.badgeType == BadgeType.verified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0DB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33F56500), width: 1.2),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 13,
              color: AppColors.tacticalOrangeDark,
            ),
            const SizedBox(width: 4),
            Text(
              mechanic.badgeLabel,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.tacticalOrangeDark,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.alertRedBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.alertRed.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: AppColors.skeuRaisedSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bolt_rounded,
              size: 13,
              color: AppColors.alertRed,
            ),
            const SizedBox(width: 4),
            Text(
              mechanic.badgeLabel,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.alertRed,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.clayDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.clayDark, width: 0.8),
        boxShadow: AppColors.skeuRaisedSmall,
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.charcoalLight,
        ),
      ),
    );
  }
}

/// Modal detail sheet showing complete mechanic info with photo thumbnail and actions.
void showMechanicDetailSheet(
  BuildContext context,
  Mechanic mechanic, {
  VoidCallback? onCallShop,
  VoidCallback? onRouteGps,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final photo = mechanic.photoPath;
      final file = photo != null && photo.isNotEmpty ? File(photo) : null;
      final hasPhoto = file != null && file.existsSync();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: AppColors.dockShadow,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Photo Thumbnail + Name + Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo slot (with fallback icon, never an empty gap)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.clayDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.clayDark, width: 1.2),
                      boxShadow: AppColors.skeuRaisedSmall,
                    ),
                    child: hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              file,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(
                                  Icons.storefront_rounded,
                                  size: 32,
                                  color: AppColors.tacticalOrange,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              size: 32,
                              color: AppColors.tacticalOrange,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mechanic.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: AppColors.tacticalOrange,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                mechanic.address ??
                                    mechanic.durationOrLocation,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.mutedText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.mutedText,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details & Attributes
              if (mechanic.phone.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: AppColors.tacticalOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mechanic.phone,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              if (mechanic.notes != null && mechanic.notes!.isNotEmpty) ...[
                Text(
                  'RIDER NOTES',
                  style: AppTextStyles.overline.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mechanic.notes!,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Actions Row: Call + Route
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onCallShop?.call();
                      },
                      icon: const Icon(Icons.call_rounded, size: 18),
                      label: const Text('Call Workshop'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tacticalOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onRouteGps?.call();
                      },
                      icon: const Icon(
                        Icons.directions_bike_rounded,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      label: Text(
                        'Route GPS',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: AppColors.clayDark,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: AppColors.clay,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Edit & Delete row
              Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onEdit();
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.charcoalLight,
                        ),
                        label: Text(
                          'Edit Mechanic',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoalLight,
                          ),
                        ),
                      ),
                    ),
                  if (onDelete != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: AppColors.alertRed,
                        ),
                        label: Text(
                          'Delete',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.alertRed,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
