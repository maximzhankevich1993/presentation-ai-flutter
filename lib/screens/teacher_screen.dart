import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:presentation_ai/services/teacher_service.dart';

class TeacherScreen extends StatefulWidget {
  final String countryCode;

  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen>
    with SingleTickerProviderStateMixin {
  final _topicController = TextEditingController();
  final _subjectController = TextEditingController();

  String _grade = '6-8';
  Map<String, dynamic>? _plan;

  late AnimationController _controller;

  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    _controller.dispose();
    super.dispose();
  }

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

    _controller.forward(from: 0); // 🔥 запуск анимации
  }

  @override
  Widget build(BuildContext context) {
    final system = TeacherService.getSystem(widget.countryCode);
    final country = system?['country'] ?? widget.countryCode;
    final standard = system?['standard'] ?? 'Международный';

    return Scaffold(
      appBar: AppBar(
        title: Text('Учитель: $country'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(country, standard),

            SizedBox(height: 24.h),

            Text(
              'Создать план урока',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Тема урока',
                prefixIcon: const Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Предмет',
                prefixIcon: const Icon(Icons.school),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Создать план урока',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),

            if (_plan != null) ...[
              SizedBox(height: 32.h),

              /// 🔥 MAIN CARD WITH FADE + SLIDE
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: _buildPlanCard(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _buildHeader(String country, String standard) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: 1,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10b981), Color(0xFF34d399)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏫 $country',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Стандарт: $standard',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PLAN CARD (DRIBBBLE STYLE)
  Widget _buildPlanCard() {
    final stages = _plan!['stages'] as List;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.15),
            const Color(0xFF8B5CF6).withOpacity(0.15),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Text(
            _plan!['topic'],
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          /// INFO ROW
          Wrap(
            spacing: 8,
            children: [
              _chip(_plan!['subject']),
              _chip('Класс ${_plan!['grade']}'),
              _chip(_plan!['duration']),
            ],
          ),

          SizedBox(height: 20.h),

          Text(
            'Этапы урока',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          /// 🔥 STAGGER ANIMATION LIST
          ...List.generate(stages.length, (i) {
            final stage = stages[i];

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 300 + (i * 120)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                );
              },
              child: _stageTile(stage),
            );
          }),

          SizedBox(height: 16.h),

          _section('Домашнее задание', _plan!['homework']),
          SizedBox(height: 10.h),
          _section('Оценивание', _plan!['assessment']),
        ],
      ),
    );
  }

  /// STAGE ITEM
  Widget _stageTile(Map stage) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${stage['minutes']} мин',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  stage['description'],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SECTION
  Widget _section(String title, String text) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8),
          SizedBox(width: 10.w),
          Expanded(
            child: Text('$title: $text'),
          ),
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text),
    );
  }
}