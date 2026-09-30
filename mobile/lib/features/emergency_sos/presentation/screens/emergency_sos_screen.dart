import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../dashboard/presentation/widgets/tactical_bottom_dock_widget.dart';
import '../widgets/auto_crash_detection_card.dart';
import '../widgets/emergency_bottom_actions.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/hardware_telematics_card.dart';
import '../widgets/ice_network_sheet.dart';
import '../widgets/offline_medical_id_card.dart';
import '../widgets/sos_header_bar.dart';
import '../widgets/telemetry_stream_card.dart';

/// CAMP Emergency SOS Screen
/// Matches high-fidelity design with 6 cards and floating bottom dock.
class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.clay,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F9),
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 1. Top Header Bar (Back button, CAMP •, SOS READY badge)
                  const SosHeaderBar(),

                  // 2. Scrollable Cards Stream
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card 1: Concentric SOS Trigger Button & Signal Pill
                          const HardwareTelematicsCard(),

                          const SizedBox(height: 14),

                          // Card 2: Current Location & Topographic Radar Preview
                          const TelemetryStreamCard(),

                          const SizedBox(height: 14),

                          // Card 3: Auto Crash Detection & Confirmation Window
                          const AutoCrashDetectionCard(),

                          const SizedBox(height: 14),

                          // Card 4: Emergency Contact (Sarah Henderson, Call, Message, 911)
                          EmergencyContactCard(
                            onEditPressed: () => IceNetworkSheet.show(context),
                          ),

                          const SizedBox(height: 14),

                          // Card 5: Offline Medical ID (Red Accent, Blood Type, Allergies, Notes)
                          const OfflineMedicalIdCard(),

                          const SizedBox(height: 14),

                          // Card 6: Test Alert Button
                          const EmergencyBottomActions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Floating Bottom Navigation Dock (Unselected state as in mockup)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: TacticalBottomDockWidget(
                  selectedIndex: -1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
