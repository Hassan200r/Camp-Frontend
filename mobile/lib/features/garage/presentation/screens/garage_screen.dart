import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../dashboard/presentation/widgets/app_drawer_widget.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';

/// CAMP Garage Screen — displays the rider's synchronized motorcycles.
class GarageScreen extends StatelessWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerWidget(),
      backgroundColor: AppColors.clay,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppColors.screenPadding, 12, AppColors.screenPadding, 110),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius: BorderRadius.circular(AppColors.radiusPill),
                          boxShadow: AppColors.skeuRaisedSmall,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.tacticalOrange),
                            const SizedBox(width: 6),
                            Text('ADD BIKE', style: AppTextStyles.overlineTerracotta.copyWith(letterSpacing: 0.6)),
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
                        const Icon(Icons.check_circle_rounded, color: AppColors.tacticalOrange, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telemetry Synced to Garage',
                                style: AppTextStyles.itemTitle.copyWith(color: AppColors.tacticalOrangeDark),
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

                  // ── Active Motorcycle Card ────────────────────────────────
                  CampCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppColors.radiusTile),
                          child: const SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: AppColors.clayDark),
                              child: Center(
                                child: Icon(Icons.two_wheeler_rounded, size: 56, color: AppColors.mutedLight),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('2023 BMW R 1250 GS Adventure', style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const StatusChip(label: 'ACTIVE', variant: StatusChipVariant.success, showDot: true),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'VIN: WB10J9309PZE84102 • 14,820 km',
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Telemetry Chips ───────────────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _specChip(Icons.speed_rounded, '14,820 km'),
                            _specChip(Icons.local_gas_station_rounded, '78% fuel'),
                            _specChip(Icons.circle_outlined, '2.4 / 2.2 bar'),
                            _specChip(Icons.build_outlined, '560 km to service'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        PrimaryButton(
                          label: 'Launch Diagnostics',
                          icon: Icons.qr_code_scanner_rounded,
                          onTap: () => Navigator.of(context).pushNamed('/bike-scan'),
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 10),
                        GhostButton(
                          label: 'Add a Motorcycle',
                          icon: Icons.two_wheeler_rounded,
                          onTap: () => Navigator.of(context).pushNamed('/add-bike'),
                        ),
                      ],
                    ),
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
                    CampBottomNav.navigateToTab(context, idx, currentIndex: null);
                  },
                ),
              ),
            ),
          ],
        ),
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
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.darkCharcoal, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
