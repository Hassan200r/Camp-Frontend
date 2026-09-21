import 'package:flutter/material.dart';
import 'app/theme/app_colors.dart';
import 'features/dashboard/presentation/screens/home_screen.dart';

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
      home: const HomeScreen(),
    );
  }
}
