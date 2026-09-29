import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/automated_rescue_protocols_card.dart';
import '../widgets/emergency_bottom_actions.dart';
import '../widgets/hardware_telematics_card.dart';
import '../widgets/ice_network_sheet.dart';
import '../widgets/offline_medical_id_card.dart';
import '../widgets/sos_header_bar.dart';
import '../widgets/telemetry_stream_card.dart';

/// CAMP Tactical Emergency SOS & Telematics Screen
/// Matches the high-fidelity skeuomorphic hardware telematics hub design.
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
        backgroundColor: AppColors.clay,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Header Bar (Back button, CAMP •, SOS READY badge)
              const SosHeaderBar(),

              // 2. Scrollable Cards Stream
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card 1: Hardware Telematics Hub with 3D Concentric SOS Button
                      const HardwareTelematicsCard(),

                      const SizedBox(height: 16),

                      // Card 2: Live Telemetry Stream Snapshot (GPS, IMU, Rig, Bio-Link)
                      const TelemetryStreamCard(),

                      const SizedBox(height: 18),

                      // Card 3: Automated Rescue Protocols (eCall v3.4, Crash Toggle, ICE Contacts)
                      AutomatedRescueProtocolsCard(
                        onManageIcePressed: () => IceNetworkSheet.show(context),
                      ),

                      const SizedBox(height: 18),

                      // Card 4: Offline Medical ID Card (First Responder Data, QR, Allergies)
                      const OfflineMedicalIdCard(),

                      const SizedBox(height: 18),

                      // Bottom Actions: Test Sat Link & Siren / Strobe
                      const EmergencyBottomActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
