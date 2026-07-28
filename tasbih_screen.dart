import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  static const _countKey = 'tasbih_count';
  static const _targetKey = 'tasbih_target';

  int _count = 0;
  int _target = 33;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt(_countKey) ?? 0;
      _target = prefs.getInt(_targetKey) ?? 33;
    });
  }

  Future<void> _increment() async {
    setState(() => _count++);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, _count);
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
  }

  Future<void> _setTarget(int value) async {
    setState(() => _target = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reachedTarget = _count > 0 && _count % _target == 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDeep,
        foregroundColor: Colors.white,
        title: const Text('তাসবিহ কাউন্টার'),
        actions: [
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            tooltip: 'রিসেট',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [33, 99, 100, 1000].map((t) {
              final selected = t == _target;
              return ChoiceChip(
                label: Text('$t'),
                selected: selected,
                selectedColor: AppColors.emeraldMid,
                labelStyle: TextStyle(color: selected ? Colors.white : (isDark ? AppColors.darkInk : AppColors.ink)),
                onSelected: (_) => _setTarget(t),
              );
            }).toList(),
          ),
          const Spacer(),
          if (reachedTarget)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('মাশাআল্লাহ! লক্ষ্য পূর্ণ হয়েছে 🎉',
                  style: TextStyle(color: AppColors.emeraldMid, fontWeight: FontWeight.bold)),
            ),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 220,
              height: 220,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emeraldDeep,
                border: Border.all(color: AppColors.gold, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_count',
                      style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w800)),
                  Text('/ $_target',
                      style: const TextStyle(color: Color(0xFFCFE0DA), fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('গণনা করতে বৃত্তটায় ট্যাপ করুন',
              style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkMuted : AppColors.muted)),
          const Spacer(),
        ],
      ),
    );
  }
}
