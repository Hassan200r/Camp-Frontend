import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';

/// Active Motorcycle Overview — skeuomorphic raised card with inset sub-surfaces
class ActiveBikeCardWidget extends StatefulWidget {
  final VoidCallback? onDetailsPressed;

  const ActiveBikeCardWidget({super.key, this.onDetailsPressed});

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
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
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
    return SkeuomorphicContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVE MOTORCYCLE',
                style: TextStyle(
                  color: AppColors.terracotta,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              // Raised circular icon button
              SkeuomorphicContainer(
                borderRadius: 100,
                shadows: AppColors.skeuRaisedSmall,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.darkCharcoal,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            'BMW R1250 GS Adventure',
            style: TextStyle(
              color: AppColors.darkCharcoal,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Edition Triple Black • 2023',
            style: TextStyle(
              color: AppColors.mutedText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          // ── Motorcycle visual showcase — inset recessed surface ──────────
          SkeuomorphicInsetContainer(
            borderRadius: 20,
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
                      style: TextStyle(
                        color: AppColors.darkCharcoal.withValues(alpha: 0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Specs tiles row ────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _specTile('Boxer Twin', 'ShiftCam'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _specTile('7.9 gal cap', 'Aluminum Tank'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _specTile('14,820 mi', 'logged'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Fuel Level ─────────────────────────────────────────────────
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_gas_station_rounded,
                    size: 16,
                    color: AppColors.terracotta,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Fuel Level',
                    style: TextStyle(
                      color: AppColors.darkCharcoal,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                '78% (280 mi est.)',
                style: TextStyle(
                  color: AppColors.darkCharcoal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Recessed inset fuel bar track
          SkeuomorphicInsetContainer(
            borderRadius: 8,
            child: AnimatedBuilder(
              animation: _fuelAnim,
              builder: (ctx, _) => ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  height: 10,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _fuelAnim.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.tacticalOrangeLight,
                            AppColors.tacticalOrange,
                            AppColors.tacticalOrangeDark,
                          ],
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

          // ── Service Health Score — raised panel ─────────────────────────
          SkeuomorphicContainer(
            borderRadius: 16,
            shadows: AppColors.skeuRaisedSmall,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Recessed icon well
                SkeuomorphicInsetContainer(
                  borderRadius: 12,
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.terracotta,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Health Score',
                        style: TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Diagnostics clean • All systems nominal',
                        style: TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Score readout with orange tint
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '84%',
                      style: TextStyle(
                        color: AppColors.tacticalOrange,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'REMAINING',
                      style: TextStyle(
                        color: AppColors.mutedLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specTile(String title, String sub) => SkeuomorphicInsetContainer(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.darkCharcoal,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
