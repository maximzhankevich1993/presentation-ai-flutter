import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
import 'editor_screen.dart';
import 'premium_screen.dart';

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
  int _slideCount = 5;
  bool _isGenerating = false;
  
  final List<Map<String, String>> _standards = [
    {'code': 'common_core', 'name': 'Common Core (USA)', 'region': 'USA'},
    {'code': 'cambridge', 'name': 'Cambridge International', 'region': 'International'},
    {'code': 'ib', 'name': 'International Baccalaureate (IB)', 'region': 'International'},
    {'code': 'fgos', 'name': 'ФГОС (Russia)', 'region': 'Russia'},
    {'code': 'national_uk', 'name': 'National Curriculum (UK)', 'region': 'United Kingdom'},
    {'code': 'australian', 'name': 'Australian Curriculum', 'region': 'Australia'},
    {'code': 'cbse', 'name': 'CBSE (India)', 'region': 'India'},
    {'code': 'common_eu', 'name': 'European Framework', 'region': 'European Union'},
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _subjectController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(AppStrings.current.limitReachedTitle, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          AppStrings.current.limitReachedMessage,
          style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.current.later, style: const TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: Text(AppStrings.current.subscribe, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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

  Future<void> _generateLesson() async {
    final topic = _topicController.text.trim();
    final subject = _subjectController.text.trim();
    final grade = _gradeController.text.trim();
    
    if (topic.isEmpty || subject.isEmpty || grade.isEmpty) {
      _showError(AppStrings.current.fillAllFields);
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.freeGenerationsLeft <= 0) {
      _showLimitDialog();
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      final lessonData = await ApiService.generateLessonPlan(
        topic: topic,
        subject: subject,
        standard: _selectedStandard,
        grade: grade,
        durationMinutes: _durationMinutes,
        slideCount: _slideCount,
      );
      
      await userProvider.loadUser();
      
      if (!mounted) return;
      
      final presentation = _convertToPresentation(lessonData);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } on LimitReachedException catch (_) {
      if (mounted) {
        _showLimitDialog();
        await userProvider.loadUser();
      }
    } catch (e) {
      if (mounted) {
        _showError('${AppStrings.current.lessonGenerationError} $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
  
  Presentation _convertToPresentation(Map<String, dynamic> lessonData) {
    final List<Slide> slides = [];
    
    slides.add(Slide(
      title: lessonData['topic'] ?? AppStrings.current.lesson,
      content: [
        '📚 ${AppStrings.current.subjectLabel}: ${lessonData['subject'] ?? ''}',
        '🎓 ${AppStrings.current.gradeLabel}: ${lessonData['grade'] ?? ''}',
        '⏱️ ${AppStrings.current.durationLabel}: $_durationMinutes ${AppStrings.current.minutes}',
      ],
    ));
    
    final slidesData = lessonData['slides'] as List? ?? [];
    for (final slideData in slidesData) {
      final content = slideData['content'] as List? ?? [];
      slides.add(Slide(
        title: slideData['title'] ?? AppStrings.current.slide,
        content: content.map((c) => c.toString()).toList(),
      ));
    }
    
    if (lessonData['homework'] != null && lessonData['homework'].toString().isNotEmpty) {
      slides.add(Slide(
        title: AppStrings.current.homework,
        content: [lessonData['homework']],
      ));
    }
    
    if (lessonData['materials'] != null) {
      final materials = lessonData['materials'] as List? ?? [];
      if (materials.isNotEmpty) {
        slides.add(Slide(
          title: AppStrings.current.materials,
          content: materials.map((m) => '📖 $m').toList(),
        ));
      }
    }
    
    return Presentation(
      id: DateTime.now().toString(),
      title: '${AppStrings.current.lessonTitle} ${lessonData['topic'] ?? ''}',
      slides: slides,
      createdAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final remaining = userProvider.freeGenerationsLeft;
    final isPremium = userProvider.isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.current.lessonBuilder,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text(AppStrings.current.lessonBuilder, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text(AppStrings.current.createFullLesson, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildTextField(controller: _topicController, hint: AppStrings.current.topicHintLesson, icon: Icons.topic_rounded),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _subjectController, hint: AppStrings.current.subjectHint, icon: Icons.subject_rounded),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _gradeController, hint: AppStrings.current.gradeHint, icon: Icons.numbers_rounded),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(child: _buildStandardDropdown()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDurationSlider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppStrings.current.slidesCount, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1DB954).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('$_slideCount', style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.w700, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Slider(
                              value: _slideCount.toDouble(),
                              min: 3,
                              max: 10,
                              divisions: 7,
                              activeColor: const Color(0xFF1DB954),
                              inactiveColor: const Color(0xFF2A2A2A),
                              onChanged: (v) => setState(() => _slideCount = v.round()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      if (!isPremium && remaining <= 3)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: remaining <= 0 
                                ? const Color(0xFFFF3B30).withOpacity(0.1)
                                : const Color(0xFF1DB954).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: remaining <= 0 
                                  ? const Color(0xFFFF3B30).withOpacity(0.3)
                                  : const Color(0xFF1DB954).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  remaining <= 0 
                                      ? AppStrings.current.generationsFinishedLesson
                                      : '${AppStrings.current.generationsLeftLesson} $remaining ${AppStrings.current.ofFive}',
                                  style: TextStyle(
                                    color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (remaining <= 0)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      AppStrings.current.subscribe,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: remaining <= 0 ? null : _generateLesson,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: remaining <= 0 ? const Color(0xFF4A4A4A) : const Color(0xFF1DB954),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            remaining <= 0 ? AppStrings.current.limitReached : AppStrings.current.generateLesson,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
          prefixIcon: Icon(icon, color: const Color(0xFF1DB954), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
  
  Widget _buildStandardDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
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
                Text(standard['name']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(standard['region']!, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 11)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedStandard = v!),
        decoration: InputDecoration(
          labelText: AppStrings.current.standardLabel,
          labelStyle: const TextStyle(color: Color(0xFF4A4A4A)),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
  
  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${AppStrings.current.durationLabel}: $_durationMinutes ${AppStrings.current.minutes}', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
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
}