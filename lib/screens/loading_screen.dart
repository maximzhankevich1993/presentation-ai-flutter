import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/presentation.dart';
import 'editor_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String topic;
  const LoadingScreen({super.key, required this.topic});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int _step = 0;
  Timer? _messageTimer;
  double _progress = 0.0;
  bool _isGenerating = true;
  String? _error;
  int _slidesGenerated = 0;
  
  final List<String> _messages = [
    '🤔 Анализирую тему...',
    '📚 Собираю информацию...',
    '💡 Придумываю структуру...',
    '✍️ Пишу текст слайдов...',
    '🖼 Подбираю иллюстрации...',
    '✨ Финальные штрихи...',
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
    _bounceController.repeat(reverse: true);
    _startGeneration();
  }

  void _startGeneration() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_step < _messages.length - 1 && _isGenerating) setState(() => _step++);
    });
    _simulateProgress();
    _generatePresentation();
  }

  void _simulateProgress() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isGenerating && _progress < 0.9) setState(() => _progress += 0.015);
      else if (!_isGenerating) timer.cancel();
    });
  }

  Future<void> _generatePresentation() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.canGenerate) throw Exception('Нет доступных генераций');
      await userProvider.useGeneration();

      final response = await ApiService.generatePresentation(widget.topic, maxSlides: userProvider.maxSlidesPerPresentation);
      
      // Преобразуем JSON в Presentation
      final presentation = Presentation.fromJson(response);
      _slidesGenerated = presentation.slides.length;

      setState(() { _isGenerating = false; _progress = 1.0; _step = _messages.length - 1; });
      _messageTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EditorScreen(presentation: presentation)));
      }
    } catch (e) {
      setState(() { _isGenerating = false; _error = e.toString().replaceAll('Exception: ', ''); });
      _messageTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) => Transform.translate(offset: Offset(0, _bounceAnimation.value), child: child),
              child: Container(
                width: 160.w, height: 160.w,
                decoration: BoxDecoration(
                  color: _error != null ? Colors.red.withOpacity(0.1) : const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _error != null ? Colors.red : const Color(0xFF6366F1), width: 2),
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Text(_error != null ? '😔' : '🧑‍🏫', style: TextStyle(fontSize: 64.sp)),
                  if (_error == null) Positioned(top: 16, right: 24, child: Text('💡', style: TextStyle(fontSize: 32.sp))),
                ]),
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(color: const Color(0xFF6366F1).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(widget.topic, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6366F1), fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: 20.h),
            Text(
              _error ?? _messages[_step],
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: _error != null ? Colors.red : (isDark ? Colors.white : Colors.black87)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            if (_error == null)
              Container(
                width: double.infinity, height: 6.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.white.withOpacity(0.1)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress,
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]))),
                ),
              ),
            if (_error != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () { setState(() { _step = 0; _progress = 0.0; _isGenerating = true; _error = null; }); _startGeneration(); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text('Попробовать снова'),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}