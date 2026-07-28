import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';
import '../services/app_settings.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static const List<String> _order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const Map<String, String> _banglaNames = {
    'Fajr': 'ফজর',
    'Dhuhr': 'যোহর',
    'Asr': 'আসর',
    'Maghrib': 'মাগরিব',
    'Isha': 'ইশা',
  };

  Map<String, String> _times = {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  bool _isManualMode = false;
  bool _isLoading = true;
  String? _errorMessage;
  String _nextPrayerName = '--';
  Duration _remaining = Duration.zero;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    _init();
    _tickTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _recomputeNextPrayer();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _isManualMode = await StorageService.isManualMode();
    if (_isManualMode) {
      await _loadManualTimes();
    } else {
      await _loadAutoTimes();
    }
  }

  Future<void> _loadManualTimes() async {
    setState(() => _isLoading = true);
    final saved = await StorageService.loadManualTimes();
    setState(() {
      _times = saved;
      _isLoading = false;
      _errorMessage = null;
    });
    _recomputeNextPrayer();
  }

  Future<void> _loadAutoTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await PrayerService.getCurrentLocation();
      final times = await PrayerService.fetchPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      setState(() {
        _times = times;
        _isLoading = false;
      });
      _recomputeNextPrayer();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(e.toString());
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('LOCATION_SERVICE_DISABLED')) {
      return 'ফোনের লোকেশন সার্ভিস বন্ধ আছে। সেটিংস থেকে লোকেশন চালু করুন।';
    }
    if (raw.contains('LOCATION_PERMISSION')) {
      return 'লোকেশন পারমিশন ছাড়া নামাজের সময় অটো লোড করা যাবে না। সেটিংস থেকে ম্যানুয়াল মোড চালু করুন।';
    }
    return 'নামাজের সময় লোড করা যায়নি। ইন্টারনেট সংযোগ চেক করুন।';
  }

  void _recomputeNextPrayer() {
    if (_times.values.any((v) => v == '--:--')) return;
    final result = PrayerService.getNextPrayer(_times);
    setState(() {
      _nextPrayerName = result.name;
      _remaining = result.remaining;
    });
  }

  Future<void> _editManualTime(String prayerKey) async {
    final current = _times[prayerKey] ?? '00:00';
    final parts = current.split(':');
    final initialHour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final initialMinute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await StorageService.saveManualTime(prayerKey, formatted);
      setState(() => _times[prayerKey] = formatted);
      _recomputeNextPrayer();
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
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDeep,
        foregroundColor: Colors.white,
        title: const Text('নামাজের সময়'),
      ),
      body: RefreshIndicator(
        onRefresh: _isManualMode ? _loadManualTimes : _loadAutoTimes,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildNextCard(isDark),
            const SizedBox(height: 16),
            if (_errorMessage != null) _buildErrorBanner(isDark),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.emeraldMid)),
              )
            else
              ..._order.map((k) => _buildPrayerRow(k, isDark)),
            if (_isManualMode) ...[
              const SizedBox(height: 10),
              Text(
                'ম্যানুয়াল মোড চালু আছে — প্রতিটা ঘরে ট্যাপ করে সময় বসান। বন্ধ করতে সেটিংসে যান।',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkMuted : AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNextCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.emeraldDeep,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('পরবর্তী নামাজ',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(_banglaNames[_nextPrayerName] ?? '--',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(_isLoading ? 'লোড হচ্ছে...' : _formatRemaining(_remaining),
              style: const TextStyle(color: Color(0xFFCFE0DA), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(String key, bool isDark) {
    final isActive = key == _nextPrayerName;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE7E0CD);
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return GestureDetector(
      onTap: _isManualMode ? () => _editManualTime(key) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? AppColors.emeraldMid : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? AppColors.emeraldMid : borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_banglaNames[key] ?? key,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14, color: isActive ? Colors.white : textColor)),
            Row(
              children: [
                AnimatedBuilder(
                  animation: AppSettings.instance,
                  builder: (context, _) => Text(
                    AppSettings.instance.formatTime(_times[key] ?? '--:--'),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14, color: isActive ? AppColors.gold : mutedColor),
                  ),
                ),
                if (_isManualMode) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.edit, size: 15, color: isActive ? AppColors.gold : mutedColor),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
