import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/camp_bottom_nav.dart';
import '../widgets/active_bike_card_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/app_header_widget.dart';
import '../widgets/cockpit_status_card_widget.dart';
import '../widgets/maintenance_alert_card_widget.dart';
import '../widgets/recent_updates_feed_widget.dart';
import '../widgets/tactical_bottom_dock_widget.dart';
import '../widgets/voice_copilot_bar_widget.dart';

/// CAMP Explore Home / Dashboard Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _maintenanceAlertDismissed = false;

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.darkCharcoal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawerWidget(),
        backgroundColor: AppColors.clay,
        body: Stack(
          children: [
            // Scrollable Content
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppColors.screenPadding,
                  8.0,
                  AppColors.screenPadding,
                  110.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. App Header
                    AppHeaderWidget(
                      onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      onBadgePressed: () => _showNotification('Explore mode active'),
                    ),

                    const SizedBox(height: 14),

                    // 2. Cockpit Status Card (Hero)
                    CockpitStatusCardWidget(
                      onProfilePressed: () => Navigator.of(context).pushNamed('/profile'),
                      onCtaPressed: () => Navigator.of(context).pushNamed('/mechanics/map'),
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 3. Voice Copilot Input Bar
                    VoiceCopilotBarWidget(
                      onVoicePressed: () => Navigator.of(context).pushNamed('/mechanics/voice-assistant'),
                      onAiPressed: () => Navigator.of(context).pushNamed('/mechanics/voice-assistant'),
                      onSubmitted: (query) {
                        Navigator.of(context).pushNamed('/mechanics/voice-assistant');
                      },
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 4. Maintenance Alert Card (dismissible)
                    if (!_maintenanceAlertDismissed) ...[
                      MaintenanceAlertCardWidget(
                        onScheduleService: () => Navigator.of(context).pushNamed('/mechanics'),
                        onDismiss: () {
                          setState(() => _maintenanceAlertDismissed = true);
                          _showNotification('Maintenance alert dismissed');
                        },
                      ),
                      const SizedBox(height: AppColors.cardGap),
                    ],

                    // 5. Active Motorcycle Overview Card
                    ActiveBikeCardWidget(
                      onDetailsPressed: () => Navigator.of(context).pushNamed('/garage'),
                    ),

                    const SizedBox(height: AppColors.cardGap),

                    // 6. Recent Updates Feed
                    RecentUpdatesFeedWidget(
                      onMarkAllRead: () => _showNotification('All updates marked as read'),
                      onViewRadar: () => Navigator.of(context).pushNamed('/mechanics/map'),
                      onLocateBeacon: () => Navigator.of(context).pushNamed('/mechanics/map'),
                      onDismissTpms: () => _showNotification('TPMS notification cleared'),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Tactical Bottom Dock (Floating)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: 0,
                  onIndexChanged: (index) {
                    CampBottomNav.navigateToTab(context, index, currentIndex: 0);
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
