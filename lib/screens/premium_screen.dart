import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(children: [
            Container(
              width: 64.w, height: 64.w,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD60A), Color(0xFFF5A623)]), shape: BoxShape.circle),
              child: const Center(child: Text('👑', style: TextStyle(fontSize: 28))),
            ),
            SizedBox(height: 14.h),
            Text('Разблокируй всё', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
            SizedBox(height: 4.h),
            Text('Безлимитные презентации и все функции', style: TextStyle(fontSize: 12, color: const Color(0xFFB3B3B3))),
            SizedBox(height: 24.h),

            // Сравнение
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _row('Презентаций', '5', '∞'),
                _divider(),
                _row('Слайдов', '10', '50'),
                _divider(),
                _row('Фоны', '2', '6'),
                _divider(),
                _row('Шрифты', '2', '3+'),
                _divider(),
                _row('Анимации', '1', '4'),
                _divider(),
                _row('PDF без знака', '❌', '✅'),
                _divider(),
                _row('AI-улучшение', '❌', '✅'),
              ]),
            ),
            SizedBox(height: 24.h),

            // Планы
            _plan('Месяц', '\$4.99', '/мес', false, () {}),
            SizedBox(height: 10.h),
            _plan('Полгода', '\$3.99', '/мес', true, () {}),
            SizedBox(height: 10.h),
            _plan('Год', '\$2.99', '/мес', false, () {}),

            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.card_giftcard, color: Color(0xFFFFD60A), size: 18),
              label: const Text('Попробовать 3 дня бесплатно', style: TextStyle(color: Color(0xFFFFD60A), fontSize: 12)),
            ),
            SizedBox(height: 12.h),
            Text('🔒 Безопасная оплата', style: TextStyle(fontSize: 10, color: Colors.white38)),
          ]),
        ),
      ),
    );
  }

  Widget _row(String f, String free, String prem) => Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: Row(children: [
      Expanded(flex: 2, child: Text(f, style: TextStyle(fontSize: 13, color: Colors.white70))),
      Expanded(child: Text(free, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: const Color(0xFFB3B3B3)))),
      Expanded(child: Text(prem, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.green))),
    ]),
  );

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.06), height: 1);

  Widget _plan(String name, String price, String period, bool popular, VoidCallback onTap) {
    const green = Color(0xFF1DB954);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: popular ? green.withOpacity(0.1) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: popular ? green.withOpacity(0.4) : Colors.white.withOpacity(0.08), width: popular ? 1.5 : 1),
        ),
        child: Row(children: [
          if (popular) Container(
            margin: EdgeInsets.only(right: 10.w),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(10)),
            child: const Text('ЛУЧШИЙ', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Полный доступ', style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
          ])),
          Text(price, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: green)),
          SizedBox(width: 2.w),
          Text(period, style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
        ]),
      ),
    );
  }
}