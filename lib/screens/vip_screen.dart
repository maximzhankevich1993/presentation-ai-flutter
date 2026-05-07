import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  final _email = TextEditingController();
  int _remaining = 47;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('VIP-доступ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD60A), Color(0xFFF5A623)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              const Text('👑', style: TextStyle(fontSize: 48)),
              SizedBox(height: 8.h),
              Text('Первые 50 — навсегда!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.black)),
              SizedBox(height: 4.h),
              Text('Пожизненный Premium бесплатно', style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.7))),
            ]),
          ),
          SizedBox(height: 20.h),

          // Счётчик
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text('Осталось VIP-мест', style: TextStyle(fontSize: 12, color: const Color(0xFFB3B3B3))),
              SizedBox(height: 6.h),
              Text('$_remaining из 50', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: const Color(0xFFFFD60A))),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: (50 - _remaining) / 50, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD60A)), minHeight: 6),
              ),
            ]),
          ),
          SizedBox(height: 16.h),

          // Форма
          TextField(
            controller: _email,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Введите ваш email',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true, fillColor: card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD60A), padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('🔥 Занять место', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          SizedBox(height: 24.h),

          // Что получает VIP
          Text('Что получает VIP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 10.h),
          _perk('♾️', 'Пожизненный Premium'),
          _perk('🎨', 'Все 30+ фишек'),
          _perk('📤', 'Экспорт без знака'),
          _perk('👑', 'Статус VIP'),
        ]),
      ),
    );
  }

  Widget _perk(String icon, String text) => Container(
    margin: EdgeInsets.only(bottom: 6.h),
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      SizedBox(width: 10.w),
      Text(text, style: TextStyle(fontSize: 13, color: Colors.white)),
    ]),
  );
}