import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/bike_scan/presentation/screens/add_motorcycle_screen.dart';
import 'features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'features/dashboard/presentation/screens/edit_profile_screen.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'features/dashboard/presentation/screens/profile_screen.dart';
import 'features/garage/presentation/screens/garage_screen.dart';
import 'features/maintenance/presentation/screens/finance_rig_health_screen.dart';
import 'features/mechanics/presentation/screens/add_mechanic_screen.dart';
import 'features/mechanics/presentation/screens/mechanics_home_screen.dart';
import 'features/mechanics/presentation/screens/mechanics_map_screen.dart';
import 'features/mechanics/presentation/screens/voice_assistant_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CampApp());
}

class CampApp extends StatelessWidget {
  const CampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAMP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/add-bike': (context) => const AddMotorcycleScreen(),
        '/add-motorcycle': (context) => const AddMotorcycleScreen(),
        '/add_bike': (context) => const AddMotorcycleScreen(),
        '/add_motorcycle': (context) => const AddMotorcycleScreen(),
        '/bike-scan': (context) => const BikeScanScreen(),
        '/bike-profile': (context) => const GarageScreen(),
        '/garage': (context) => const GarageScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/mechanics': (context) => const MechanicsHomeScreen(),
        '/mechanics/add': (context) => const AddMechanicScreen(),
        '/add-mechanic': (context) => const AddMechanicScreen(),
        '/mechanics/map': (context) => const MechanicsMapScreen(),
        '/mechanics/voice-assistant': (context) => const VoiceAssistantScreen(),
        '/voice-assistant': (context) => const VoiceAssistantScreen(),
        '/route-packs': (context) => const HomeScreen(),
        '/ride-history': (context) => const ProfileScreen(),
        '/finance-rig-health': (context) => const FinanceRigHealthScreen(),
        '/predictive-maintenance': (context) => const FinanceRigHealthScreen(),
        '/carburetor-tuning': (context) => const MechanicsHomeScreen(),
        '/settings': (context) => const ProfileScreen(),
        '/emergency-sos': (context) => const HomeScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}
