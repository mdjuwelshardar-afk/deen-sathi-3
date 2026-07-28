import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'services/app_settings.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const DeenSathiApp());
}

class DeenSathiApp extends StatefulWidget {
  const DeenSathiApp({super.key});

  @override
  State<DeenSathiApp> createState() => _DeenSathiAppState();
}

class _DeenSathiAppState extends State<DeenSathiApp> {
  @override
  void initState() {
    super.initState();
    AppSettings.instance.load();
    AppSettings.instance.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deen Sathi',
      debugShowCheckedModeBanner: false,
      themeMode: AppSettings.instance.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldDeep,
          primary: AppColors.emeraldDeep,
          secondary: AppColors.gold,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldMid,
          primary: AppColors.emeraldMid,
          secondary: AppColors.gold,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
