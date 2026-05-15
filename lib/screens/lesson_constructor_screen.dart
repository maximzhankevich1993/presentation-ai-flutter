import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/lesson_plan_service.dart';
import 'editor_screen.dart';

class LessonConstructorScreen extends StatefulWidget {
  const LessonConstructorScreen({super.key});

  @override
  State<LessonConstructorScreen> createState() => _LessonConstructorScreenState();
}

class _LessonConstructorScreenState extends State<LessonConstructorScreen> {
  final _topicController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  
  String _selectedStandard = 'common_core';
  int _durationMinutes = 45;
  bool _isGenerating = false;
  
  bool _includeAssessments = true;
  bool _includeDifferentiation = true;
  bool _includeHomework = true;
  
  final List<Map<String, String>> _standards = LessonPlanService.standards;

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _generateLesson() async {
    final topic = _topicController.text.trim();
    final subject = _subjectController.text.trim();
    final grade = _gradeController.text.trim();
    
    if (topic.isEmpty || subject.isEmpty || grade.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      final lessonPlan = LessonPlanService.generate(
        topic: topic,
        subject: subject,
        standard: _selectedStandard,
        grade: grade,
        durationMinutes: _durationMinutes,
      );
      
      final presentation = _convertToPresentation(lessonPlan);
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } catch (e) {
      _showError('Ошибка создания плана урока: $e');
      setState(() => _isGenerating = false);
    }
  }
  
  Presentation _convertToPresentation(LessonPlan lessonPlan) {
    final List<Slide> slides = [];
    
    slides.add(Slide(
      title: 'План урока',
      content: [
        '📚 ${lessonPlan.subject}',
        '📖 Тема: ${lessonPlan.topic}',
        '🎓 Класс: ${lessonPlan.grade}',
        '🌍 Стандарт: ${_getStandardName(lessonPlan.standard)}',
        '⏱️ Длительность: ${lessonPlan.duration}',
      ],
    ));
    
    slides.add(Slide(
      title: 'Цели урока',
      content: lessonPlan.objectives.map((obj) => '• $obj').toList(),
    ));
    
    for (final stage in lessonPlan.stages) {
      slides.add(Slide(
        title: stage.name,
        content: [
          '⏰ Время: ${stage.minutes} мин',
          '👩‍🏫 Учитель: ${stage.teacherActions}',
          '👨‍🎓 Ученики: ${stage.studentActions}',
          '📁 Ресурсы: ${stage.resources}',
        ],
      ));
    }
    
    if (_includeHomework) {
      slides.add(Slide(
        title: 'Домашнее задание',
        content: [lessonPlan.homework],
      ));
    }
    
    if (_includeAssessments) {
      slides.add(Slide(
        title: 'Оценивание',
        content: [lessonPlan.assessment],
      ));
    }
    
    if (_includeDifferentiation) {
      slides.add(Slide(
        title: 'Дифференциация',
        content: lessonPlan.differentiation,
      ));
    }
    
    return Presentation(
      id: DateTime.now().toString(),
      title: 'План урока: ${lessonPlan.topic}',
      slides: slides,
      createdAt: DateTime.now(),
    );
  }
  
  String _getStandardName(String code) {
    final standard = _standards.firstWhere(
      (s) => s['code'] == code,
      orElse: () => {'name': code},
    );
    return standard['name'] ?? code;
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Text(
          'Конструктор уроков',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Color(0xFF1DB954),
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Создаём план урока...',
                    style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                  ),
                ],
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Конструктор уроков',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Создайте план урока по международным стандартам',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'ОСНОВНАЯ ИНФОРМАЦИЯ',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _topicController,
                              hint: 'Тема урока',
                              icon: Icons.topic_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _subjectController,
                              hint: 'Предмет',
                              icon: Icons.subject_rounded,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _gradeController,
                              hint: 'Класс',
                              icon: Icons.numbers_rounded,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildStandardDropdown()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildDurationSlider()),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          children: [
                            _buildSwitch(
                              value: _includeAssessments,
                              onChanged: (v) => setState(() => _includeAssessments = v),
                              title: 'Включить систему оценивания',
                              icon: Icons.assessment_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildSwitch(
                              value: _includeDifferentiation,
                              onChanged: (v) => setState(() => _includeDifferentiation = v),
                              title: 'Включить дифференциацию',
                              icon: Icons.graphic_eq_rounded,
                            ),
                            const SizedBox(height: 8),
                            _buildSwitch(
                              value: _includeHomework,
                              onChanged: (v) => setState(() => _includeHomework = v),
                              title: 'Включить домашнее задание',
                              icon: Icons.home_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _generateLesson,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Создать план урока',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF1DB954), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
  
  Widget _buildStandardDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedStandard,
        items: _standards.map((standard) {
          return DropdownMenuItem(
            value: standard['code'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standard['name']!,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                Text(
                  standard['region']!,
                  style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedStandard = v!),
        decoration: const InputDecoration(
          labelText: 'Образовательный стандарт',
          labelStyle: TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
          prefixIcon: Icon(Icons.school_rounded, color: Color(0xFF1DB954), size: 18),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
  
  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Длительность: $_durationMinutes мин',
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
        ),
        Slider(
          value: _durationMinutes.toDouble(),
          min: 20,
          max: 90,
          divisions: 7,
          onChanged: (v) => setState(() => _durationMinutes = v.round()),
          activeColor: const Color(0xFF1DB954),
          inactiveColor: const Color(0xFF2A2A2A),
        ),
      ],
    );
  }
  
  Widget _buildSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1DB954), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1DB954),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }
}