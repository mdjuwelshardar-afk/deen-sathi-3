import 'dart:convert';
import 'package:http/http.dart' as http;

/// একটা সূরার সংক্ষিপ্ত তথ্য (তালিকায় দেখানোর জন্য)
class Surah {
  final int number;
  final String arabicName;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // "Meccan" বা "Medinan"

  Surah({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      arabicName: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      numberOfAyahs: json['numberOfAyahs'],
      revelationType: json['revelationType'],
    );
  }
}

/// একটা আয়াত: আরবি টেক্সট + বাংলা অনুবাদ
class Ayah {
  final int numberInSurah;
  final String arabicText;
  final String banglaText;

  Ayah({
    required this.numberInSurah,
    required this.arabicText,
    required this.banglaText,
  });
}

/// alquran.cloud API থেকে সূরা লিস্ট আর আয়াত (আরবি + বাংলা অনুবাদ) আনে
class QuranService {
  static const _base = 'https://api.alquran.cloud/v1';

  /// ১১৪টা সূরার লিস্ট আনে
  static Future<List<Surah>> fetchSurahList() async {
    final uri = Uri.parse('$_base/surah');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('SURAH_LIST_ERROR');
    }

    final data = jsonDecode(response.body);
    final List list = data['data'];
    return list.map((e) => Surah.fromJson(e)).toList();
  }

  /// একটা নির্দিষ্ট সূরার সব আয়াত (আরবি + বাংলা অনুবাদ) আনে
  static Future<List<Ayah>> fetchSurahAyahs(int surahNumber) async {
    // একসাথে দুইটা এডিশন (আরবি আসল টেক্সট + বাংলা অনুবাদ) আনা হচ্ছে
    final uri = Uri.parse(
      '$_base/surah/$surahNumber/editions/quran-simple,bn.bengali',
    );
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('SURAH_AYAHS_ERROR');
    }

    final data = jsonDecode(response.body);
    final List editions = data['data'];

    final arabicAyahs = editions[0]['ayahs'] as List;
    final banglaAyahs = editions[1]['ayahs'] as List;

    final List<Ayah> result = [];
    for (int i = 0; i < arabicAyahs.length; i++) {
      result.add(
        Ayah(
          numberInSurah: arabicAyahs[i]['numberInSurah'],
          arabicText: arabicAyahs[i]['text'],
          banglaText: i < banglaAyahs.length ? banglaAyahs[i]['text'] : '',
        ),
      );
    }
    return result;
  }
}
