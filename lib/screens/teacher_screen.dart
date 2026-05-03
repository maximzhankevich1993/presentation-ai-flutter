import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/teacher_service.dart';

class TeacherScreen extends StatefulWidget {
  final String countryCode;
  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final _topicController = TextEditingController();
  final _subjectController = TextEditingController();
  String _grade = '6-8';
  Map<String, dynamic>? _plan;

  void _generatePlan() {
    final topic = _topicController.text.trim();
    final subject = _subjectController.text.trim();
    if (topic.isEmpty || subject.isEmpty) return;
    setState(() {
      _plan = TeacherService.generateLessonPlan(topic: topic, subject: subject, countryCode: widget.countryCode, grade: _grade);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final system = TeacherService.getSystem(widget.countryCode);
    final country = system?['country'] ?? widget.countryCode;
    final standard = system?['standard'] ?? 'Международный';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(title: Text('Учитель: $country'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF10b981), Color(0xFF34d399)]), borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text('🏫 $country', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Text('Стандарт: $standard', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
            ]),
          ),
          SizedBox(height: 24.h),
          Text('Создать план урока', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 16.h),
          TextField(controller: _topicController, decoration: InputDecoration(hintText: 'Тема урока', prefixIcon: const Icon(Icons.book), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
          SizedBox(height: 12.h),
          TextField(controller: _subjectController, decoration: InputDecoration(hintText: 'Предмет', prefixIcon: const Icon(Icons.school), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _generatePlan,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10b981), padding: EdgeInsets.symmetric(vertical: 16.h)),
              child: const Text('Создать план урока', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
          if (_plan != null) ...[
            SizedBox(height: 32.h),
            Text('📋 План урока: ${_plan!['topic']}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ],
        ]),
      ),
    );
  }
}