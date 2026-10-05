import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_app_bar.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../../../../core/widgets/camp_card.dart';
import '../../../../core/widgets/inset_tile.dart';
import '../../../garage/controllers/active_bike_controller.dart';
import '../../../garage/domain/bike_model.dart';
import '../../controllers/post_ride_report_controller.dart';
import '../widgets/carburetor_tab.dart';
import '../widgets/diagnostics_tab.dart';
import '../widgets/post_ride_tab.dart';
import '../widgets/pre_ride_tab.dart';

/// Software-driven Maintenance Screen — thin shell.
///
/// Owns only the tab-selector state and the shared scaffold chrome
/// (AppBar, bottom nav, bike-context header). All tab content is
/// delegated to the four dedicated widget files:
///   • DiagnosticsTab    — wear engine output + pattern intelligence
///   • CarburetorTab     — GPS altitude + density-ratio jetting advisor
///   • PreRideTab        — safety checklist
///   • PostRideTab       — debrief form + log history
///
/// No sensor, OBD-II, or ECU claims anywhere in this file.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ActiveBikeController.instance,
        PostRideReportController.instance,
      ]),
      builder: (context, _) {
        final activeBike = ActiveBikeController.instance.activeBike;
        final isCarburetor = activeBike?.fuelSystem == FuelSystem.carburetor;

        final tabs = [
          'Diagnostics',
          if (isCarburetor) 'Carburetor',
          'Pre-Ride',
          'Post-Ride',
        ];

        // Clamp index when bike changes and carburetor tab disappears.
        final activeTabIndex = _selectedTabIndex.clamp(0, tabs.length - 1);

        return Scaffold(
          backgroundColor: AppColors.clay,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ── App Bar ───────────────────────────────────────────
                    CampAppBar(
                      leading: CampAppBarLeading.back,
                      onLeadingPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      },
                      showLogo: true,
                      actionText: '• MAINTENANCE',
                    ),

                    // ── Scrollable Body ───────────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 110,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activeBike != null) ...[
                              _buildBikeContextCard(activeBike),
                              const SizedBox(height: 14),
                            ],
                            _buildTabSelector(tabs, activeTabIndex),
                            const SizedBox(height: 16),
                            _buildTabContent(
                              activeBike,
                              activeTabIndex,
                              isCarburetor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Floating Bottom Nav ───────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: CampBottomNav(
                    selectedIndex: 4,
                    onIndexChanged: (index) {
                      CampBottomNav.navigateToTab(
                        context,
                        index,
                        currentIndex: 4,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Bike Context Header Card ──────────────────────────────────────────────
  Widget _buildBikeContextCard(Bike bike) {
    return CampCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: AppColors.radiusCard,
      color: AppColors.clay,
      shadows: AppColors.skeuRaised,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.clayDark,
              borderRadius: BorderRadius.circular(AppColors.radiusTile),
              boxShadow: AppColors.skeuRecessed,
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              color: AppColors.tacticalOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${bike.make} ${bike.modelName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatNumber(bike.odometerKm)} km • Last updated ${_formatRelativeTime(bike.lastUpdatedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Selector ──────────────────────────────────────────────────────────
  Widget _buildTabSelector(List<String> tabs, int activeIndex) {
    return InsetTile(
      padding: const EdgeInsets.all(4),
      borderRadius: AppColors.radiusTile,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == activeIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.clay : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppColors.radiusTile - 4),
                  boxShadow: isSelected ? AppColors.skeuRaisedSmall : null,
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AppColors.darkCharcoal
                          : AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab Content Router ────────────────────────────────────────────────────
  Widget _buildTabContent(Bike? bike, int activeTabIndex, bool isCarburetor) {
    if (bike == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No active motorcycle selected.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: ValueKey(bike.id),
      child: IndexedStack(
        index: activeTabIndex,
        children: [
          DiagnosticsTab(
            bike: bike,
            onSwitchToPostRide: () {
              setState(() {
                // Post-Ride tab index: 3 when carburetor present, else 2.
                _selectedTabIndex = isCarburetor ? 3 : 2;
              });
            },
          ),
          if (isCarburetor) CarburetorTab(bike: bike),
          const PreRideTab(),
          PostRideTab(bike: bike),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}
