import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    final features = [
      {'icon': '🎨', 'title': 'Анти-шаблоны', 'desc': 'Каждый слайд в уникальном стиле'},
      {'icon': '📱', 'title': 'Story Mode', 'desc': 'Скроллящаяся история вместо слайдов'},
      {'icon': '🏷', 'title': 'Бренд-кит', 'desc': 'Цвета и шрифты из логотипа'},
      {'icon': '🤖', 'title': 'AI-улучшение', 'desc': 'Рерайт текста нейросетью'},
      {'icon': '🎬', 'title': 'Анимации', 'desc': '4 перехода между слайдами'},
      {'icon': '📤', 'title': 'Экспорт', 'desc': 'PPTX, PDF, PNG'},
      {'icon': '🌍', 'title': 'Авто-страна', 'desc': 'Стандарты и валюта по IP'},
      {'icon': '👑', 'title': 'VIP', 'desc': 'Первые 50 — Premium навсегда'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('Возможности', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h),
        itemCount: features.length,
        itemBuilder: (_, i) {
          final f = features[i];
          return Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(f['icon']!, style: const TextStyle(fontSize: 28)),
              SizedBox(height: 8.h),
              Text(f['title']!, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 4.h),
              Text(f['desc']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: const Color(0xFFB3B3B3))),
            ]),
          );
        },
      ),
    );
  }
}