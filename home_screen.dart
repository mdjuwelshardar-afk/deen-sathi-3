import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import 'prayer_times_screen.dart';
import 'quran_screen.dart';
import 'qibla_screen.dart';
import 'tasbih_screen.dart';
import 'dua_hadith_screen.dart';
import 'reminders_screen.dart';
import 'hijri_calendar_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _banglaNames = {
    'Fajr': 'ফজর', 'Dhuhr': 'যোহর', 'Asr': 'আসর', 'Maghrib': 'মাগরিব', 'Isha': 'ইশা',
  };

  bool _isLoading = true;
  String _nextPrayerName = '--';
  Duration _remaining = Duration.zero;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _load(silent: true);
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final isManual = await StorageService.isManualMode();
      Map<String, String> times;
      if (isManual) {
        times = await StorageService.loadManualTimes();
      } else {
        final position = await PrayerService.getCurrentLocation();
        times = await PrayerService.fetchPrayerTimes(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
      if (times.values.any((v) => v == '--:--')) {
        setState(() => _isLoading = false);
        return;
      }
      final result = PrayerService.getNextPrayer(times);
      setState(() {
        _nextPrayerName = result.name;
        _remaining = result.remaining;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _formatRemaining(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) return 'বাকি আছে $hours ঘণ্টা $minutes মিনিট';
    return 'বাকি আছে $minutes মিনিট';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _buildTopBar(context),
              const SizedBox(height: 14),
              _buildNextPrayerCard(context),
              const SizedBox(height: 20),
              _buildCardGrid(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('দ্বীন সাথী',
            style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800)),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildNextPrayerCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerTimesScreen())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.emeraldDeep,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('পরবর্তী নামাজ',
                style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: 6),
            Text(_banglaNames[_nextPrayerName] ?? '--',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_isLoading ? 'লোড হচ্ছে...' : _formatRemaining(_remaining),
                style: const TextStyle(color: Color(0xFFCFE0DA), fontSize: 13)),
            const SizedBox(height: 10),
            const Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 14, color: Color(0xFFCFE0DA)),
                SizedBox(width: 6),
                Text('সব ওয়াক্তের সময় দেখতে ট্যাপ করুন', style: TextStyle(color: Color(0xFFCFE0DA), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGrid(BuildContext context, bool isDark) {
    final items = [
      _FeatureItem('কুরআন শরীফ', Icons.menu_book, const QuranScreen()),
      _FeatureItem('কিবলার দিক', Icons.explore, const QiblaScreen()),
      _FeatureItem('তাসবিহ কাউন্টার', Icons.fingerprint, const TasbihScreen()),
      _FeatureItem('দোয়া সংকলন', Icons.auto_stories, const DuaHadithScreen()),
      _FeatureItem('নামাজের রিমাইন্ডার', Icons.notifications_active, const RemindersScreen()),
      _FeatureItem('হিজরি ক্যালেন্ডার', Icons.calendar_month, const HijriCalendarScreen()),
    ];

    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE7E0CD);
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.screen)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.emeraldDeep.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.emeraldMid, size: 22),
                ),
                const Spacer(),
                Text(item.label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeatureItem {
  final String label;
  final IconData icon;
  final Widget screen;
  _FeatureItem(this.label, this.icon, this.screen);
}
