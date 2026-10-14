import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../garage/domain/bike_model.dart';

/// Active Motorcycle Overview — skeuomorphic raised card bound to [ActiveBikeController].
class ActiveBikeCardWidget extends StatefulWidget {
  const ActiveBikeCardWidget({super.key, this.onDetailsPressed});

  final VoidCallback? onDetailsPressed;

  @override
  State<ActiveBikeCardWidget> createState() => _ActiveBikeCardWidgetState();
}

class _ActiveBikeCardWidgetState extends State<ActiveBikeCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    return ListenableBuilder(
      listenable: ActiveBikeController.instance,
      builder: (context, _) {
        final bike = ActiveBikeController.instance.activeBike;

        if (bike == null) {
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 450),
            child: CampCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE MOTORCYCLE',
                        style: AppTextStyles.overlineTerracotta,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            Navigator.of(context).pushNamed(CampRoutes.addBike),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.clay,
                            borderRadius:
                                BorderRadius.circular(AppColors.radiusPill),
                            boxShadow: AppColors.skeuRaisedSmall,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  size: 14, color: AppColors.tacticalOrange),
                              const SizedBox(width: 4),
                              Text(
                                'ADD BIKE',
                                style: AppTextStyles.overlineTerracotta.copyWith(
                                    fontSize: 10, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: CampEmptyState(
                        icon: Icons.two_wheeler_rounded,
                        message: 'No motorcycle active in your garage',
                        ctaLabel: 'Add your bike',
                        onCta: () =>
                            Navigator.of(context).pushNamed(CampRoutes.addBike),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final hasFuelData = bike.currentFuelLiters != null &&
            bike.fuelTankCapacityLiters != null &&
            bike.fuelTankCapacityLiters! > 0;
        final double fuelRatio = hasFuelData
            ? (bike.currentFuelLiters! / bike.fuelTankCapacityLiters!)
                .clamp(0.0, 1.0)
            : 0.0;

        String fuelText = '';
        if (hasFuelData) {
          final pct = (fuelRatio * 100).round();
          if (bike.fuelAverageKmPerLiter != null) {
            final estKm =
                (bike.currentFuelLiters! * bike.fuelAverageKmPerLiter!).round();
            fuelText = '$pct%  ($estKm km est.)';
          } else {
            fuelText = '$pct%';
          }
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 450),
          child: CampCard(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ────────────────────────────────────────────────
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
                        onTap: () =>
                            Navigator.of(context).pushNamed(CampRoutes.addBike),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.clay,
                            borderRadius:
                                BorderRadius.circular(AppColors.radiusPill),
                            boxShadow: AppColors.skeuRaisedSmall,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded,
                                  size: 14, color: AppColors.tacticalOrange),
                              const SizedBox(width: 4),
                              Text(
                                'ADD BIKE',
                                style:
                                    AppTextStyles.overlineTerracotta.copyWith(
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
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

              Text(bike.name, style: AppTextStyles.title),
              const SizedBox(height: 3),
              Text(
                bike.edition != null && bike.edition!.isNotEmpty
                    ? '${bike.edition} • ${bike.modelYear}'
                    : '${bike.make} • ${bike.modelYear}',
                style: AppTextStyles.bodySecondary,
              ),

              const SizedBox(height: 14),

              // ── Motorcycle visual showcase — inset recessed surface ───────
              GestureDetector(
                onTap: widget.onDetailsPressed,
                child: InsetTile(
                  borderRadius: AppColors.radiusTile,
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    height: 130,
                    child: Center(
                      child: _buildBikeShowcaseContent(bike),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Specs tiles row ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _specTile(
                      bike.displacement != null
                          ? '${bike.displacement} cc'
                          : (bike.bikeType ?? 'Engine'),
                      bike.fuelSystem == FuelSystem.efi
                          ? 'Electronic EFI'
                          : 'Carburetor',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _specTile(
                      bike.fuelTankCapacityLiters != null
                          ? '${bike.fuelTankCapacityLiters!.toStringAsFixed(0)} L'
                          : 'Tank',
                      'Capacity',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _specTile(
                      '${bike.odometerKm} km',
                      'logged',
                    ),
                  ),
                ],
              ),

              // ── Fuel Level (only shown if user entered it) ────────────────
              if (hasFuelData) ...[
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_gas_station_rounded,
                          size: 16,
                          color: AppColors.terracotta,
                        ),
                        const SizedBox(width: 6),
                        Text('Fuel Level', style: AppTextStyles.itemTitle),
                      ],
                    ),
                    Text(fuelText, style: AppTextStyles.body),
                  ],
                ),
                const SizedBox(height: 8),
                InsetTile(
                  borderRadius: 8,
                  padding: EdgeInsets.zero,
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (ctx, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: SizedBox(
                        height: 10,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor:
                              (_animController.value * fuelRatio).clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.tacticalOrangeLight,
                                  AppColors.tacticalOrange,
                                  AppColors.tacticalOrangeDark,
                                ],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── Service Status ────────────────────────────────────────────
              CampCard(
                borderRadius: AppColors.radiusTile,
                shadows: AppColors.skeuRaisedSmall,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const IconTile(
                      icon: Icons.tune_rounded,
                      iconColor: AppColors.terracotta,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Service Status',
                              style: AppTextStyles.itemTitle),
                          const SizedBox(height: 3),
                          Text(
                            bike.lastOilChange != null
                                ? 'Last oil change: ${bike.lastOilChange!.km ?? 0} km'
                                : 'All systems verified',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${bike.odometerKm}',
                          style: AppTextStyles.statMedium.copyWith(
                            color: AppColors.tacticalOrange,
                            fontSize: 16,
                          ),
                        ),
                        Text('KM LOGGED', style: AppTextStyles.overline),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  Widget _buildBikeShowcaseContent(Bike bike) {
    if (bike.imagePath != null && bike.imagePath!.isNotEmpty) {
      final file = File(bike.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
          child: Image.file(
            file,
            width: double.infinity,
            height: 130,
            fit: BoxFit.cover,
          ),
        );
      } else if (bike.imagePath!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusTile - 4),
          child: Image.asset(
            bike.imagePath!,
            width: double.infinity,
            height: 130,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sports_motorsports_rounded,
          size: 52,
          color: AppColors.darkCharcoal.withValues(alpha: 0.25),
        ),
        const SizedBox(height: 8),
        Text(
          bike.name,
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.darkCharcoal.withValues(alpha: 0.4),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _specTile(String title, String sub) => InsetTile(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: AppTextStyles.itemTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
