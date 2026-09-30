import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bike_scan/presentation/screens/bike_details_screen.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../../controllers/active_bike_controller.dart';
import '../../domain/bike_model.dart';
import 'bike_profile_screen.dart';

/// CAMP Garage Screen — displays the rider's synchronized motorcycles.
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bikeController = ActiveBikeController.instance;

    return Scaffold(
      drawer: const AppDrawerWidget(),
      backgroundColor: AppColors.clay,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppColors.screenPadding,
                12,
                AppColors.screenPadding,
                110,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top Bar ───────────────────────────────────────────────
                  CampAppBar(
                    leading: CampAppBarLeading.back,
                    titleText: 'MY GARAGE',
                    actionWidget: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pushNamed('/add-bike'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusPill),
                          boxShadow: AppColors.skeuRaisedSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 16,
                              color: AppColors.tacticalOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ADD BIKE',
                              style: AppTextStyles.overlineTerracotta
                                  .copyWith(letterSpacing: 0.6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppColors.cardGap),

                  // ── Synced Success Banner ─────────────────────────────────
                  CampCard(
                    color: const Color(0xFFFDE8D4),
                    borderRadius: AppColors.radiusTile,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.tacticalOrange,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telemetry Synced to Garage',
                                style: AppTextStyles.itemTitle
                                    .copyWith(color: AppColors.tacticalOrangeDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Vehicle specifications, OBD status, and tyre pressures recorded.',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppColors.cardGap),

                  // ── Motorcycle Fleet List ─────────────────────────────────
                  ListenableBuilder(
                    listenable: bikeController,
                    builder: (context, _) {
                      final bikes = bikeController.bikes;
                      if (bikes.isEmpty) {
                        return CampCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.two_wheeler_rounded,
                                size: 54,
                                color: AppColors.mutedLight,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No Motorcycles in Garage',
                                style: AppTextStyles.title,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add a motorcycle to monitor specifications and maintenance health.',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              PrimaryButton(
                                label: 'Add a Motorcycle',
                                icon: Icons.add_rounded,
                                onTap: () =>
                                    Navigator.of(context).pushNamed('/add-bike'),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: bikes.map((bike) {
                          final isActive = bikeController.isActive(bike.id);
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppColors.cardGap),
                            child: _buildBikeCard(
                              context,
                              bike,
                              isActive,
                              bikeController,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // ── Add Motorcycle Ghost Button ───────────────────────────
                  GhostButton(
                    label: 'Add Another Motorcycle',
                    icon: Icons.two_wheeler_rounded,
                    onTap: () => Navigator.of(context).pushNamed('/add-bike'),
                  ),
                ],
              ),
            ),

            // ── Bottom Dock ───────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 0,
                  onIndexChanged: (idx) {
                    CampBottomNav.navigateToTab(context, idx,
                        currentIndex: null);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeCard(
    BuildContext context,
    Bike bike,
    bool isActive,
    ActiveBikeController controller,
  ) {
    return CampCard(
      // Tapping anywhere on the card (except action buttons) navigates to BikeProfileScreen
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => BikeProfileScreen(bike: bike),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Overline and dedicated "Edit Specs" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isActive ? 'ACTIVE TELEMETRY RIG' : 'STANDBY TELEMETRY',
                style: AppTextStyles.overlineTerracotta.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Tapping "Edit Specs" specifically still goes straight to the edit form
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => BikeDetailsScreen(initialBike: bike),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: AppColors.tacticalOrangeDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Edit Specs',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tacticalOrangeDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bike Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppColors.radiusTile),
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(color: AppColors.clayDark),
                child: bike.imagePath != null
                    ? Image.asset(
                        bike.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Icon(
                            Icons.two_wheeler_rounded,
                            size: 56,
                            color: AppColors.mutedLight,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.two_wheeler_rounded,
                          size: 56,
                          color: AppColors.mutedLight,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Bike Title
          Text(
            '${bike.modelYear} ${bike.make} ${bike.modelName}',
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 4),

          // Status Chip + VIN / Odometer line
          Row(
            children: [
              StatusChip(
                label: isActive ? 'ACTIVE' : 'STANDBY',
                variant: isActive
                    ? StatusChipVariant.success
                    : StatusChipVariant.neutral,
                showDot: true,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${bike.vin != null && bike.vin!.isNotEmpty ? 'VIN: ${bike.vin} • ' : ''}${_formatKm(bike.odometerKm)} km',
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Telemetry Chips ───────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _specChip(
                Icons.speed_rounded,
                '${_formatKm(bike.odometerKm)} km',
              ),
              _specChip(
                Icons.local_gas_station_rounded,
                '${((bike.currentFuelLiters ?? 23.4) / (bike.fuelTankCapacityLiters ?? 30.0) * 100).toInt()}% fuel',
              ),
              _specChip(Icons.circle_outlined, '2.4 / 2.2 bar'),
              _specChip(Icons.build_outlined, '1,180 km to service'),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons: Launch Diagnostics or Set as Active Rig
          if (isActive) ...[
            PrimaryButton(
              label: 'Launch Diagnostics',
              icon: Icons.qr_code_scanner_rounded,
              onTap: () => Navigator.of(context).pushNamed('/bike-scan'),
              isFullWidth: true,
            ),
          ] else ...[
            PrimaryButton(
              label: 'Set as Active Rig',
              icon: Icons.check_circle_outline_rounded,
              onTap: () => controller.setActiveBike(bike.id),
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _specChip(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.clayDark,
          borderRadius: BorderRadius.circular(AppColors.radiusPill),
          boxShadow: AppColors.skeuRecessed,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.terracotta),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.darkCharcoal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  String _formatKm(int km) {
    final str = km.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
