import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// পুরো অ্যাপের সেটিংস (থিম, সময়ের ফরম্যাট) — একজায়গা থেকে সব স্ক্রিনে পৌঁছানোর জন্য
class AppSettings extends ChangeNotifier {
  AppSettings._internal();
  static final AppSettings instance = AppSettings._internal();

  static const _themeKey = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const _use24HourKey = 'use_24_hour';

  ThemeMode _themeMode = ThemeMode.system;
  bool _use24Hour = false;

  ThemeMode get themeMode => _themeMode;
  bool get use24Hour => _use24Hour;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey) ?? 'system';
    _themeMode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _use24Hour = prefs.getBool(_use24HourKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeKey, value);
  }

  Future<void> setUse24Hour(bool value) async {
    _use24Hour = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_use24HourKey, value);
  }

  /// "18:44" কে সেটিংস অনুযায়ী "18:44" বা "৬:৪৪ অপরাহ্ণ" স্টাইলে ফরম্যাট করে
  String formatTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return hhmm;
    final hour24 = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour24 == null || minute == null) return hhmm;

    if (_use24Hour) {
      return '${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    final period = hour24 >= 12 ? 'অপরাহ্ণ' : 'পূর্বাহ্ণ';
    var hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }
}
