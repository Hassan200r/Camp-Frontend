import 'package:flutter/material.dart';

import 'app/theme/app_colors.dart';
import 'features/bike_scan/presentation/screens/bike_scan_screen.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.tacticalOrange,
          primary: AppColors.tacticalOrange,
          surface: AppColors.background,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/bike-scan': (context) => const BikeScanScreen(),
        '/bike-profile': (context) => const BikeScanScreen(),
        '/garage': (context) => const GarageScreen(),
      },
    );
  }
}
