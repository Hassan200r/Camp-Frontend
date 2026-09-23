import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/skeuomorphic_container.dart';
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SkeuomorphicContainer(
                          borderRadius: 100,
                          shadows: AppColors.skeuRaisedSmall,
                          child: const SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(Icons.arrow_back_rounded, color: AppColors.darkCharcoal),
                          ),
                        ),
                      ),
                      const Text(
                        'MY GARAGE',
                        style: TextStyle(
                          color: AppColors.darkCharcoal,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SkeuomorphicContainer(
                        borderRadius: 20,
                        shadows: AppColors.skeuRaisedSmall,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: const Row(
                          children: [
                            Icon(Icons.directions_bike_rounded, size: 16, color: Color(0xFFF56500)),
                            SizedBox(width: 6),
                            Text(
                              '1 ACTIVE',
                              style: TextStyle(
                                color: AppColors.darkCharcoal,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Synced Success Banner
                  const SkeuomorphicContainer(
                    borderRadius: 20,
                    color: Color(0xFFFDE8D4),
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFFF56500), size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telemetry Synced to Garage',
                                style: TextStyle(
                                  color: Color(0xFFF56500),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Vehicle specifications, OBD status, and tire pressures recorded.',
                                style: TextStyle(
                                  color: AppColors.mutedText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Active Motorcycle Card in Garage
                  SkeuomorphicContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Image.asset(
                              'assets/images/bmw_r1250_scan_placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '2023 BMW R 1250 GS Adventure',
                          style: TextStyle(
                            color: AppColors.darkCharcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'VIN: WB10J9309PZE84102 • 14,820 Verified Miles',
                          style: TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SkeuomorphicOrangeButton(
                          label: 'Launch Diagnostics',
                          icon: Icons.qr_code_scanner_rounded,
                          onTap: () => Navigator.of(context).pushNamed('/bike-scan'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 0,
                  onIndexChanged: (idx) {
                    if (idx == 0) {
                      Navigator.of(context).pushReplacementNamed('/');
                    } else if (idx == 1) {
                      Navigator.of(context).pushReplacementNamed('/bike-scan');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
