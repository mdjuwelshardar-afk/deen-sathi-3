import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_settings.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    _loadManualMode();
  }

  Future<void> _loadManualMode() async {
    final value = await StorageService.isManualMode();
    if (mounted) setState(() => _manualMode = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE7E0CD);
    final textColor = isDark ? AppColors.darkInk : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDeep,
        foregroundColor: Colors.white,
        title: const Text('সেটিংস'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _sectionTitle('সময়ের ফরম্যাট', mutedColor),
          _cardWrap(
            cardColor,
            borderColor,
            child: AnimatedBuilder(
              animation: AppSettings.instance,
              builder: (context, _) => SwitchListTile(
                title: Text('24-ঘণ্টার ফরম্যাট', style: TextStyle(color: textColor, fontSize: 14)),
                subtitle: Text(
                  AppSettings.instance.use24Hour ? 'যেমন: 18:44' : 'যেমন: ৬:৪৪ অপরাহ্ণ',
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                value: AppSettings.instance.use24Hour,
                activeColor: AppColors.emeraldMid,
                onChanged: (v) => AppSettings.instance.setUse24Hour(v),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('নামাজের সময়', mutedColor),
          _cardWrap(
            cardColor,
            borderColor,
            child: SwitchListTile(
              title: Text('ম্যানুয়াল সময় সেট করুন', style: TextStyle(color: textColor, fontSize: 14)),
              subtitle: Text(
                'অন করলে GPS/ইন্টারনেট ছাড়াই হাতে সময় বসাতে পারবেন',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
              value: _manualMode,
              activeColor: AppColors.emeraldMid,
              onChanged: (v) async {
                await StorageService.setManualMode(v);
                setState(() => _manualMode = v);
              },
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('থিম', mutedColor),
          _cardWrap(
            cardColor,
            borderColor,
            child: AnimatedBuilder(
              animation: AppSettings.instance,
              builder: (context, _) => Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('লাইট মোড', style: TextStyle(color: textColor, fontSize: 14)),
                    value: ThemeMode.light,
                    groupValue: AppSettings.instance.themeMode,
                    activeColor: AppColors.emeraldMid,
                    onChanged: (v) => AppSettings.instance.setThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('ডার্ক মোড', style: TextStyle(color: textColor, fontSize: 14)),
                    value: ThemeMode.dark,
                    groupValue: AppSettings.instance.themeMode,
                    activeColor: AppColors.emeraldMid,
                    onChanged: (v) => AppSettings.instance.setThemeMode(v!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('ফোনের সেটিং অনুযায়ী', style: TextStyle(color: textColor, fontSize: 14)),
                    value: ThemeMode.system,
                    groupValue: AppSettings.instance.themeMode,
                    activeColor: AppColors.emeraldMid,
                    onChanged: (v) => AppSettings.instance.setThemeMode(v!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _cardWrap(Color cardColor, Color borderColor, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}
