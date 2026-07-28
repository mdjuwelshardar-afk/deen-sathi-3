import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'qibla_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    QiblaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.emeraldMid.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.access_time, color: AppColors.emeraldDeep),
            label: 'নামাজ',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.emeraldDeep),
            label: 'কুরআন',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined, color: AppColors.muted),
            selectedIcon: Icon(Icons.explore, color: AppColors.emeraldDeep),
            label: 'কিবলা',
          ),
        ],
      ),
    );
  }
}
