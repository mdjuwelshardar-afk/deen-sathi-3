import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Aladhan API থেকে নামাজের সময় আনে, আর ফোনের লোকেশন পারমিশন/অবস্থান হ্যান্ডেল করে।
class PrayerService {
  /// ফোনের বর্তমান লোকেশন বের করে। লোকেশন সার্ভিস বন্ধ থাকলে বা
  /// পারমিশন না দিলে Exception ছুঁড়ে দেয়, যাতে UI-তে বার্তা দেখানো যায়।
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('LOCATION_SERVICE_DISABLED');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('LOCATION_PERMISSION_DENIED');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('LOCATION_PERMISSION_DENIED_FOREVER');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }

  /// Aladhan API কল করে ৫ ওয়াক্তের সময় নিয়ে আসে।
  /// রিটার্ন করে: {"Fajr": "04:03", "Dhuhr": "12:14", "Asr": "16:45", "Maghrib": "18:32", "Isha": "19:50"}
  static Future<Map<String, String>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.aladhan.com/v1/timings'
      '?latitude=$latitude&longitude=$longitude&method=2',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('API_ERROR_${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final timings = data['data']['timings'];

    // API থেকে "04:03 (+06)" এর মতো ফরম্যাট আসতে পারে, তাই শুধু HH:mm অংশটুকু নেওয়া হচ্ছে
    String clean(String raw) => raw.split(' ').first;

    return {
      'Fajr': clean(timings['Fajr']),
      'Dhuhr': clean(timings['Dhuhr']),
      'Asr': clean(timings['Asr']),
      'Maghrib': clean(timings['Maghrib']),
      'Isha': clean(timings['Isha']),
    };
  }

  /// এখন থেকে পরবর্তী কোন নামাজ, আর তার জন্য কতক্ষণ বাকি সেটা বের করে।
  static ({String name, Duration remaining}) getNextPrayer(
    Map<String, String> times,
  ) {
    final now = DateTime.now();
    final order = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    DateTime? parseTimeToday(String hhmm) {
      final parts = hhmm.split(':');
      if (parts.length != 2) return null;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    for (final name in order) {
      final t = parseTimeToday(times[name] ?? '');
      if (t != null && t.isAfter(now)) {
        return (name: name, remaining: t.difference(now));
      }
    }

    // আজকের সব নামাজ শেষ হয়ে গেলে, পরবর্তী নামাজ কালকের ফজর
    final fajrToday = parseTimeToday(times['Fajr'] ?? '');
    if (fajrToday != null) {
      final fajrTomorrow = fajrToday.add(const Duration(days: 1));
      return (name: 'Fajr', remaining: fajrTomorrow.difference(now));
    }

    return (name: '--', remaining: Duration.zero);
  }
}
