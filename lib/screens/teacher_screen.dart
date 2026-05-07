import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeacherScreen extends StatefulWidget {
  final String countryCode;
  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final _topic = TextEditingController();
  final _subject = TextEditingController();

  @override
  void dispose() {
    _topic.dispose();
    _subject.dispose();
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
        title: const Text('Учителям', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Text('🏫', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Стандарт: ФГОС', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('Россия', style: TextStyle(fontSize: 11, color: const Color(0xFFB3B3B3))),
              ])),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(8)),
                child: const Text('АКТИВЕН', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          SizedBox(height: 20.h),
          Text('Создать план урока', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 10.h),
          TextField(
            controller: _topic,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Тема урока',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true, fillColor: card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _subject,
            style: const TextStyle(fontSize: 14, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Предмет',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true, fillColor: card,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: green, padding: EdgeInsets.symmetric(vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Создать план урока', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ]),
      ),
    );
  }
}