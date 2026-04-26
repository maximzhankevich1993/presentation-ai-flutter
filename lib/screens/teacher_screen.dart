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
      _plan = TeacherService.generateLessonPlan(
        topic: topic,
        subject: subject,
        countryCode: widget.countryCode,
        grade: _grade,
      );
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
      appBar: AppBar(
        title: Text('Учитель: $country'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о стране
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF10b981), Color(0xFF34d399)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('🏫 $country', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text('Стандарт: $standard', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp)),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Генератор плана урока
            Text('Создать план урока', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(hintText: 'Тема урока', prefixIcon: const Icon(Icons.book), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(hintText: 'Предмет', prefixIcon: const Icon(Icons.school), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              value: _grade,
              items: ['1-4', '5-8', '9-12'].map((g) => DropdownMenuItem(value: g, child: Text('Классы: $g'))).toList(),
              onChanged: (v) => setState(() => _grade = v!),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePlan,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10b981), padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Создать план урока', style: TextStyle(fontSize: 16.sp)),
              ),
            ),

            // Результат
            if (_plan != null) ...[
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('📋 План урока', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),
                  Text('Тема: ${_plan!['topic']}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  Text('Стандарт: ${_plan!['standard']}', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  Text('Язык: ${_plan!['language']}', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                  SizedBox(height: 16.h),
                  ...(_plan!['stages'] as List).map((stage) => Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(color: const Color(0xFF10b981).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Container(width: 40.w, height: 40.w, decoration: BoxDecoration(color: const Color(0xFF10b981), shape: BoxShape.circle), child: Center(child: Text('${stage['minutes']}м', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)))),
                      SizedBox(width: 12.w),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(stage['name'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        Text(stage['description'], style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      ])),
                    ]),
                  )),
                  SizedBox(height: 12.h),
                  Text('📝 Домашнее задание: ${_plan!['homework']}', style: TextStyle(fontSize: 14.sp)),
                  Text('📊 Оценивание: ${_plan!['assessment']}', style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}