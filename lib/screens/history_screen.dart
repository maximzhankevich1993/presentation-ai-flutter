import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1DB954);
    const card = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: const Text('История', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white.withOpacity(0.15)),
          SizedBox(height: 16.h),
          Text('У вас пока нет презентаций', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
          SizedBox(height: 8.h),
          Text('Создайте свою первую презентацию!', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3))),
        ]),
      ),
    );
  }
}