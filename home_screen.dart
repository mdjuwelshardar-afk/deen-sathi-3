import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/prayer_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // প্রতি মিনিটে কাউন্টডাউন রিফ্রেশ হবে
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
      return 'লোকেশন পারমিশন ছাড়া নামাজের সময় অটো লোড করা যাবে না। পারমিশন দিন অথবা ম্যানুয়াল মোড ব্যবহার করুন।';
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

  Future<void> _onManualModeChanged(bool value) async {
    await StorageService.setManualMode(value);
    setState(() => _isManualMode = value);
    if (value) {
      await _loadManualTimes();
    } else {
      await _loadAutoTimes();
    }
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

  /// "18:44" এর মতো 24-ঘণ্টার সময়কে "৬:৪৪ PM" স্টাইলে (বাংলা পূর্বাহ্ণ/অপরাহ্ণ সহ) রূপান্তর করে
  String _to12Hour(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final hour24 = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour24 == null || minute == null) return hhmm;

    final period = hour24 >= 12 ? 'অপরাহ্ণ' : 'পূর্বাহ্ণ';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatRemaining(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return 'বাকি আছে $hours ঘণ্টা $minutes মিনিট';
    }
    return 'বাকি আছে $minutes মিনিট';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _isManualMode ? _loadManualTimes : _loadAutoTimes,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              if (_errorMessage != null) _buildErrorBanner(),
              if (_isLoading) const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.emeraldMid)),
              ) else
                ..._order.map(_buildPrayerRow),
              const SizedBox(height: 12),
              _buildManualModeToggle(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      color: AppColors.emeraldDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'দ্বীন সাথী',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'পরবর্তী নামাজ',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _banglaNames[_nextPrayerName] ?? '--',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isLoading ? 'লোড হচ্ছে...' : _formatRemaining(_remaining),
                  style: const TextStyle(color: Color(0xFFCFE0DA), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(String key) {
    final isActive = key == _nextPrayerName;
    return GestureDetector(
      onTap: _isManualMode ? () => _editManualTime(key) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? AppColors.emeraldMid : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isActive ? AppColors.emeraldMid : const Color(0xFFE7E0CD)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _banglaNames[key] ?? key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isActive ? Colors.white : AppColors.ink,
              ),
            ),
            Row(
              children: [
                Text(
                  _times[key] != null ? _to12Hour(_times[key]!) : '--:--',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isActive ? AppColors.gold : AppColors.muted,
                  ),
                ),
                if (_isManualMode) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.edit, size: 15, color: isActive ? AppColors.gold : AppColors.muted),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold, style: BorderStyle.solid),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'ম্যানুয়াল সময় সেট করুন',
              style: TextStyle(fontSize: 12, color: AppColors.ink),
            ),
          ),
          Switch(
            value: _isManualMode,
            activeColor: AppColors.emeraldMid,
            onChanged: _onManualModeChanged,
          ),
        ],
      ),
    );
  }
}
