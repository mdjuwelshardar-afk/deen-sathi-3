import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class _Dua {
  final String title;
  final String arabic;
  final String bangla;
  const _Dua({required this.title, required this.arabic, required this.bangla});
}

/// শুরুর জন্য কিছু গুরুত্বপূর্ণ দোয়া — সম্পূর্ণ অফলাইনে কাজ করে (ইন্টারনেট লাগে না)
const List<_Dua> _duas = [
  _Dua(
    title: 'বিসমিল্লাহ',
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    bangla: 'পরম করুণাময়, অসীম দয়ালু আল্লাহর নামে শুরু করছি।',
  ),
  _Dua(
    title: 'খাওয়া শুরুর দোয়া',
    arabic: 'بِسْمِ اللَّهِ وَعَلَى بَرَكَةِ اللَّهِ',
    bangla: 'আল্লাহর নামে এবং আল্লাহর বরকতে (খাওয়া শুরু করছি)।',
  ),
  _Dua(
    title: 'খাওয়া শেষের দোয়া',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    bangla: 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমাকে এই খাবার খাইয়েছেন এবং আমার কোনো শক্তি-সামর্থ্য ছাড়াই এই রিজিক দিয়েছেন।',
  ),
  _Dua(
    title: 'ঘুমানোর আগের দোয়া',
    arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    bangla: 'হে আল্লাহ, তোমার নামেই আমি মৃত্যুবরণ করি (ঘুমাই) এবং জীবিত হই (জাগি)।',
  ),
  _Dua(
    title: 'ঘুম থেকে ওঠার দোয়া',
    arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    bangla: 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি আমাদের মৃত্যুর (ঘুমের) পর জীবিত করেছেন এবং তাঁরই দিকে আমাদের ফিরে যেতে হবে।',
  ),
  _Dua(
    title: 'ঘর থেকে বের হওয়ার দোয়া',
    arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    bangla: 'আল্লাহর নামে (বের হচ্ছি), আমি আল্লাহর উপর ভরসা করলাম, আল্লাহর সাহায্য ছাড়া কোনো শক্তি বা ক্ষমতা নেই।',
  ),
  _Dua(
    title: 'বিপদের সময়ের দোয়া',
    arabic: 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
    bangla: 'নিশ্চয়ই আমরা আল্লাহর জন্য এবং নিশ্চয়ই আমরা তাঁরই দিকে প্রত্যাবর্তনকারী।',
  ),
  _Dua(
    title: 'সফরের দোয়া',
    arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
    bangla: 'পবিত্র সেই সত্তা, যিনি এই বাহনকে আমাদের অধীন করে দিয়েছেন, অথচ আমরা নিজেরা একে বশ করতে সক্ষম ছিলাম না। আমরা অবশ্যই আমাদের রবের দিকে প্রত্যাবর্তনকারী।',
  ),
];

class DuaHadithScreen extends StatelessWidget {
  const DuaHadithScreen({super.key});

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
        title: const Text('দোয়া সংকলন'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: _duas.length,
        itemBuilder: (context, index) {
          final dua = _duas[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dua.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.emeraldMid)),
                const SizedBox(height: 10),
                Text(dua.arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 20, height: 1.8, color: textColor)),
                const SizedBox(height: 8),
                Divider(color: isDark ? AppColors.darkBorder : Colors.grey.shade200),
                const SizedBox(height: 6),
                Text(dua.bangla, style: TextStyle(fontSize: 13, height: 1.6, color: mutedColor)),
              ],
            ),
          );
        },
      ),
    );
  }
}
