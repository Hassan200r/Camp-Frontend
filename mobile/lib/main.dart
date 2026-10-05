import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/presentation/screens/sign_up_screen.dart';
import 'features/bike_scan/presentation/screens/add_motorcycle_screen.dart';
import 'features/bike_scan/presentation/screens/bike_details_screen.dart';
import 'features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'features/dashboard/presentation/screens/edit_profile_screen.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'features/dashboard/presentation/screens/profile_screen.dart';
import 'features/emergency_sos/presentation/screens/emergency_sos_screen.dart';
import 'features/garage/presentation/screens/bike_profile_screen.dart';
import 'features/garage/presentation/screens/garage_screen.dart';
import 'features/maintenance/presentation/screens/carburetor_tuning_screen.dart';
import 'features/maintenance/presentation/screens/finance_rig_health_screen.dart';
import 'features/maintenance/presentation/screens/predictive_maintenance_screen.dart';
import 'features/mechanics/presentation/screens/add_mechanic_screen.dart';
import 'features/mechanics/presentation/screens/mechanics_home_screen.dart';
import 'features/navigation/presentation/screens/navigation_map_screen.dart';
import 'features/navigation/presentation/screens/route_packs_screen.dart';
import 'features/ride_history/presentation/screens/ride_history_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/voice_copilot/presentation/screens/voice_assistant_screen.dart';

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
      initialRoute: '/sign-in',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/login': (context) => const SignInScreen(),
        '/auth': (context) => const SignInScreen(),
        '/sign-up': (context) => const SignUpScreen(),
        '/register': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/add-bike': (context) => const AddMotorcycleScreen(),
        '/add-motorcycle': (context) => const AddMotorcycleScreen(),
        '/add_bike': (context) => const AddMotorcycleScreen(),
        '/add_motorcycle': (context) => const AddMotorcycleScreen(),
        '/bike-details': (context) => const BikeDetailsScreen(),
        '/bike-scan': (context) => const BikeScanScreen(),
        '/bike-profile': (context) => const BikeProfileScreen(),
        '/garage': (context) => const GarageScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/mechanics': (context) => const MechanicsHomeScreen(),
        '/mechanics/add': (context) => const AddMechanicScreen(),
        '/add-mechanic': (context) => const AddMechanicScreen(),
        '/navigation/map': (context) => const NavigationMapScreen(),
        // TODO: Legacy route aliases — kept for temporary backward compatibility during team branch merges. Remove once confirmed unused across all teammate branches.
        '/mechanics/map': (context) => const NavigationMapScreen(),
        '/voice-copilot': (context) => const VoiceAssistantScreen(),
        '/voice-assistant': (context) => const VoiceAssistantScreen(),
        '/mechanics/voice-assistant': (context) => const VoiceAssistantScreen(),
        '/route-packs': (context) => const RoutePacksScreen(),
        '/ride-history': (context) => const RideHistoryScreen(),
        '/finance-rig-health': (context) => const FinanceRigHealthScreen(),
        '/finances-rig-health': (context) => const FinanceRigHealthScreen(),
        '/predictive-maintenance': (context) => const PredictiveMaintenanceScreen(),
        '/carburetor-tuning': (context) => const CarburetorTuningScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/emergency-sos': (context) => const EmergencySosScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => const HomeScreen(),
      ),
    );
  }
}
