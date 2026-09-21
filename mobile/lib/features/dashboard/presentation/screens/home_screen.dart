import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
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
  // 1. Define the GlobalKey for Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedDockIndex = 0;
  bool _maintenanceAlertDismissed = false;

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        key: _scaffoldKey, // 2. Attach the key here
        drawer: const AppDrawerWidget(), // 3. Attach your side menu drawer
        backgroundColor: AppColors.clay,
        body: Stack(
          children: [
            // Scrollable Content
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 110.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. App Header (Top Navigation Bar)
                    AppHeaderWidget(
                      onMenuPressed: () {
                        // Opens the Scaffold drawer menu safely via key
                        _scaffoldKey.currentState?.openDrawer();
                      },
                      onBadgePressed: () => _showNotification('Explore mode active'),
                    ),

                    const SizedBox(height: 14),

                    // 2. Cockpit Status Card (Dark Rider Banner)
                    CockpitStatusCardWidget(
                      onProfilePressed: () => _showNotification('Opening Rider Profile: Elena Vance'),
                      onCtaPressed: () => _showNotification('Navigating to Alpine Route 4'),
                    ),

                    const SizedBox(height: 16),

                    // 3. Voice Copilot Input Bar
                    VoiceCopilotBarWidget(
                      onVoicePressed: () => _showNotification('Listening for voice command...'),
                      onAiPressed: () => _showNotification('AI Assistant activated'),
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          _showNotification('CAMP Copilot: Analyzing "$query"');
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4. Maintenance Alert Card (Conditionally visible if not dismissed)
                    if (!_maintenanceAlertDismissed) ...[
                      MaintenanceAlertCardWidget(
                        onScheduleService: () => _showNotification('Scheduling certified service...'),
                        onDismiss: () {
                          setState(() {
                            _maintenanceAlertDismissed = true;
                          });
                          _showNotification('Maintenance alert dismissed');
                        },
                      ),
                      const SizedBox(height: 18),
                    ],

                    // 5. Active Motorcycle Overview Card
                    ActiveBikeCardWidget(
                      onDetailsPressed: () => _showNotification('Opening BMW R1250 GS Telemetry'),
                    ),

                    const SizedBox(height: 20),

                    // 6. Recent Updates Feed
                    RecentUpdatesFeedWidget(
                      onMarkAllRead: () => _showNotification('All updates marked as read'),
                      onViewRadar: () => _showNotification('Loading High Pass live weather radar...'),
                      onLocateBeacon: () => _showNotification('Locating Rider Marcus on GPS map...'),
                      onDismissTpms: () => _showNotification('TPMS notification cleared'),
                    ),
                  ],
                ),
              ),
            ),

            // 7. Tactical Bottom Dock (Floating Navigation Bar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: _selectedDockIndex,
                  onIndexChanged: (index) {
                    setState(() {
                      _selectedDockIndex = index;
                    });
                    final tabNames = [
                      'Explore Home',
                      'Bike Scan',
                      'Navigation',
                      'Maintenance Tools',
                      'Settings & Filters'
                    ];
                    _showNotification('Switched to ${tabNames[index]}');
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
