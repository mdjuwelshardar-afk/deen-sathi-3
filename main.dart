import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/main_nav_screen.dart';

void main() {
  runApp(const DeenSathiApp());
}

class DeenSathiApp extends StatelessWidget {
  const DeenSathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deen Sathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldDeep,
          primary: AppColors.emeraldDeep,
          secondary: AppColors.gold,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavScreen(),
    );
  }
}
