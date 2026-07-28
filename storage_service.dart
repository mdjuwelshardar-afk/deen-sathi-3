import 'package:shared_preferences/shared_preferences.dart';

/// ফোনের লোকাল স্টোরেজে ম্যানুয়াল মোড আর ম্যানুয়াল সময় সেভ রাখার জন্য।
class StorageService {
  static const _manualModeKey = 'manual_mode';
  static const _prayerKeys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  static Future<bool> isManualMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_manualModeKey) ?? false;
  }

  static Future<void> setManualMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualModeKey, value);
  }

  static Future<void> saveManualTime(String prayerName, String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manual_$prayerName', time);
  }

  static Future<Map<String, String>> loadManualTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> result = {};
    for (final name in _prayerKeys) {
      result[name] = prefs.getString('manual_$name') ?? '--:--';
    }
    return result;
  }
}
