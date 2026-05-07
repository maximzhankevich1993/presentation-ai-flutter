import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final String _code = 'FRIEND-A7K9';
  final int _count = 3;

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Приведи друга', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF17A34A)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('🎁', style: TextStyle(fontSize: 48)),
              SizedBox(height: 8.h),
              Text('Приведи друга — получи 2 месяца Premium!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              SizedBox(height: 4.h),
              Text('Друг тоже получит 1 месяц', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.7))),
            ]),
          ),
          SizedBox(height: 20.h),

          // Статус
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('🥉', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Уровень: Бронза', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Приглашено: $_count друга', style: TextStyle(fontSize: 12, color: const Color(0xFFB3B3B3))),
                Text('Бесплатных месяцев: 2', style: TextStyle(fontSize: 12, color: green, fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
          SizedBox(height: 16.h),

          // Код
          Text('Ваш код', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14), border: Border.all(color: green.withOpacity(0.3))),
            child: Row(children: [
              Expanded(child: Text(_code, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: green, letterSpacing: 3))),
              IconButton(onPressed: () {}, icon: const Icon(Icons.copy, color: Color(0xFF1DB954))),
            ]),
          ),
          SizedBox(height: 20.h),

          // Кнопка Поделиться
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Поделиться кодом'),
              style: ElevatedButton.styleFrom(backgroundColor: green, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ]),
      ),
    );
  }
}