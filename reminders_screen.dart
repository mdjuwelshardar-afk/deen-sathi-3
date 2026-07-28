import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.emeraldDeep,
        foregroundColor: Colors.white,
        title: const Text('নামাজের রিমাইন্ডার'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active_outlined, size: 48, color: isDark ? AppColors.darkMuted : AppColors.muted),
              const SizedBox(height: 14),
              Text(
                'এই ফিচারটা পরের আপডেটে আসছে',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.darkInk : AppColors.ink),
              ),
              const SizedBox(height: 8),
              Text(
                'প্রতিটা নামাজের সময় হলে ফোনে নোটিফিকেশন পাঠাতে অ্যান্ড্রয়েডের বাড়তি পারমিশন সেটআপ লাগবে — এটা পরের ধাপে যোগ করা হবে।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkMuted : AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
