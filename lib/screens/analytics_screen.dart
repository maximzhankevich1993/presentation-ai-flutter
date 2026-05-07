import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalyticsScreen extends StatelessWidget {
  final String presentationTitle;
  final int slideCount;

  const AnalyticsScreen({super.key, required this.presentationTitle, required this.slideCount});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Аналитика', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(presentationTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 16.h),
          Row(children: [
            _stat('👁', '245', 'Просмотров'),
            SizedBox(width: 8.w),
            _stat('👥', '87', 'Уникальных'),
            SizedBox(width: 8.w),
            _stat('✅', '64%', 'Досмотрели'),
          ]),
          SizedBox(height: 20.h),
          Text('По слайдам', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFB3B3B3))),
          SizedBox(height: 8.h),
          ...List.generate(slideCount, (i) => Container(
            margin: EdgeInsets.only(bottom: 6.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(
                width: 28.w, height: 28.w,
                decoration: BoxDecoration(color: green, shape: BoxShape.circle),
                child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11))),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Внимание: ${55 + i * 5}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                SizedBox(height: 4.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(value: (55 + i * 5) / 100, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)), minHeight: 3),
                ),
              ])),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _stat(String icon, String value, String label) => Expanded(
    child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF1DB954))),
        Text(label, style: TextStyle(fontSize: 10, color: const Color(0xFFB3B3B3))),
      ]),
    ),
  );
}