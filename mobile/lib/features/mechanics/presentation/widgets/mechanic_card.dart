import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/mechanic_model.dart';

class MechanicCard extends StatelessWidget {

  const MechanicCard({
    required this.mechanic, super.key,
    this.onCallShop,
    this.onRouteGps,
  });
  final Mechanic mechanic;
  final VoidCallback? onCallShop;
  final VoidCallback? onRouteGps;

  static const LinearGradient _orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Header: Title & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  mechanic.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildBadge(),
            ],
          ),

          const SizedBox(height: 8),

          // Distance, Duration & Beacon Status
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.tacticalOrange,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${mechanic.distance}  •  ${mechanic.durationOrLocation}',
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
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
                  const SizedBox(width: 5),
                  Text(
                    mechanic.beaconStatus,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: mechanic.beaconColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Category 1 (e.g. CERTIFIED PLATFORMS / SUPPORTED RIGS)
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

          // Category 2 (FIELD CAPABILITIES)
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

          const SizedBox(height: 14),

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
    );
  }

  Widget _buildBadge() {
    if (mechanic.badgeType == BadgeType.verified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              size: 14,
              color: AppColors.tacticalOrangeDark,
            ),
            const SizedBox(width: 4),
            Text(
              mechanic.badgeLabel,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.tacticalOrangeDark,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              size: 14,
              color: AppColors.alertRed,
            ),
            const SizedBox(width: 4),
            Text(
              mechanic.badgeLabel,
              style: AppTextStyles.caption.copyWith(
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
