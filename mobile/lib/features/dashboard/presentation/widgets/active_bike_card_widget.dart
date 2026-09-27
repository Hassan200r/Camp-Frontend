import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Active Motorcycle Overview — skeuomorphic raised card with inset sub-surfaces
class ActiveBikeCardWidget extends StatefulWidget {
  const ActiveBikeCardWidget({super.key, this.onDetailsPressed});

  final VoidCallback? onDetailsPressed;

  @override
  State<ActiveBikeCardWidget> createState() => _ActiveBikeCardWidgetState();
}

class _ActiveBikeCardWidgetState extends State<ActiveBikeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fuelAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fuelAnim = Tween<double>(begin: 0.0, end: 0.78).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CampCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE MOTORCYCLE',
                style: AppTextStyles.overlineTerracotta,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pushNamed('/add-bike'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.clay,
                        borderRadius: BorderRadius.circular(AppColors.radiusPill),
                        boxShadow: AppColors.skeuRaisedSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 14, color: AppColors.tacticalOrange),
                          const SizedBox(width: 4),
                          Text(
                            'ADD BIKE',
                            style: AppTextStyles.overlineTerracotta.copyWith(fontSize: 10, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconTile(
                    icon: Icons.two_wheeler_rounded,
                    size: 40,
                    isInset: false,
                    onTap: widget.onDetailsPressed,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text('BMW R1250 GS Adventure', style: AppTextStyles.title),
          const SizedBox(height: 3),
          Text('Edition Triple Black • 2023', style: AppTextStyles.bodySecondary),

          const SizedBox(height: 14),

          // ── Motorcycle visual showcase — inset recessed surface ───────────
          GestureDetector(
            onTap: widget.onDetailsPressed,
            child: InsetTile(
              borderRadius: AppColors.radiusTile,
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 130,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_motorsports_rounded,
                        size: 52,
                        color: AppColors.darkCharcoal.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'BMW R 1250 GS Adventure',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: AppColors.darkCharcoal.withValues(alpha: 0.4),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Specs tiles row ───────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _specTile('Boxer Twin', 'ShiftCam')),
              const SizedBox(width: 8),
              Expanded(child: _specTile('30 L', 'Aluminium Tank')),
              const SizedBox(width: 8),
              Expanded(child: _specTile('14,820 km', 'logged')),
            ],
          ),

          const SizedBox(height: 18),

          // ── Fuel Level ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_gas_station_rounded, size: 16, color: AppColors.terracotta),
                  const SizedBox(width: 6),
                  Text('Fuel Level', style: AppTextStyles.itemTitle),
                ],
              ),
              Text('78%  (450 km est.)', style: AppTextStyles.body),
            ],
          ),

          const SizedBox(height: 8),

          // Recessed inset fuel bar track
          InsetTile(
            borderRadius: 8,
            padding: EdgeInsets.zero,
            child: AnimatedBuilder(
              animation: _fuelAnim,
              builder: (ctx, _) => ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  height: 10,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _fuelAnim.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange, AppColors.tacticalOrangeDark],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Service Health Score ──────────────────────────────────────────
          CampCard(
            borderRadius: AppColors.radiusTile,
            shadows: AppColors.skeuRaisedSmall,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const IconTile(icon: Icons.tune_rounded, iconColor: AppColors.terracotta),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Service Health Score', style: AppTextStyles.itemTitle),
                      const SizedBox(height: 3),
                      Text('Diagnostics clean • All systems nominal', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('84%', style: AppTextStyles.statMedium.copyWith(color: AppColors.tacticalOrange)),
                    Text('REMAINING', style: AppTextStyles.overline),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specTile(String title, String sub) => InsetTile(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(title, style: AppTextStyles.itemTitle, textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(sub, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      );
}
