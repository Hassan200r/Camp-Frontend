import 'package:flutter/material.dart';

import 'app/theme/app_theme.dart';
import 'features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
import 'features/dashboard/presentation/screens/profile_screen.dart';
import 'features/garage/presentation/screens/garage_screen.dart';

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
        '/bike-scan': (context) => const BikeScanScreen(),
        '/bike-profile': (context) => const BikeScanScreen(),
        '/garage': (context) => const GarageScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
