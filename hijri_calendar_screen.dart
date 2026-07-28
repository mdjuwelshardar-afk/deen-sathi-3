import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import '../theme/app_colors.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  static const _banglaHijriMonths = [
    'মহররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি', 'জমাদিউল আউয়াল', 'জমাদিউস সানি',
    'রজব', 'শাবান', 'রমজান', 'শাওয়াল', 'জিলকদ', 'জিলহজ্জ',
  ];

  late HijriCalendar _today;
  late DateTime _viewedMonth;

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('en');
    _today = HijriCalendar.now();
    _viewedMonth = DateTime.now();
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE7E0CD);
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    final viewedHijri = HijriCalendar.fromDate(_viewedMonth);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDeep,
        foregroundColor: Colors.white,
        title: const Text('হিজরি ক্যালেন্ডার'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.emeraldDeep, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('আজকের হিজরি তারিখ',
                    style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(
                  '${_today.hDay} ${_banglaHijriMonths[_today.hMonth - 1]}, ${_today.hYear} হিজরি',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'ইংরেজি: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(color: Color(0xFFCFE0DA), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () => _changeMonth(-1), icon: Icon(Icons.chevron_left, color: textColor)),
                Text(
                  '${_banglaHijriMonths[viewedHijri.hMonth - 1]} ${viewedHijri.hYear}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
                ),
                IconButton(onPressed: () => _changeMonth(1), icon: Icon(Icons.chevron_right, color: textColor)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ইংরেজি মাস: ${_monthNameEn(_viewedMonth.month)} ${_viewedMonth.year}',
            style: TextStyle(fontSize: 12, color: mutedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _monthNameEn(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}
