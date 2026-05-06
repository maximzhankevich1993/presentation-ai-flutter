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
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _step = 0;
  Timer? _messageTimer;
  double _progress = 0.0;
  bool _isGenerating = true;
  String? _error;

  final List<String> _messages = ['🤔 Анализирую...', '📚 Собираю...', '💡 Придумываю...', '✍️ Пишу...', '✨ Завершаю...'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat(reverse: true);
    _startGeneration();
  }

  void _startGeneration() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_step < _messages.length - 1 && _isGenerating) setState(() => _step++);
    });
    _generatePresentation();
  }

  Future<void> _generatePresentation() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (!userProvider.canGenerate) throw Exception('Нет генераций');
      await userProvider.useGeneration();
      final response = await ApiService.generatePresentation(widget.topic, maxSlides: userProvider.maxSlidesPerPresentation);
      final presentation = Presentation.fromJson(response);
      setState(() { _isGenerating = false; _progress = 1.0; _step = _messages.length - 1; });
      _messageTimer?.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EditorScreen(presentation: presentation)));
    } catch (e) {
      setState(() { _isGenerating = false; _error = e.toString().replaceAll('Exception: ', ''); });
      _messageTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xAA0F0F1A), // полупрозрачный фон
      body: Center(
        child: Container(
          width: 220.w,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Иконка
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
              child: Container(
                width: 48.w, height: 48.w,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]), shape: BoxShape.circle),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 20))),
              ),
            ),
            SizedBox(height: 14.h),
            // Тема
            Text(widget.topic, style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 10.h),
            // Статус
            Text(
              _error ?? _messages[_step],
              style: TextStyle(fontSize: 11, color: _error != null ? Colors.red[300] : Colors.white54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            // Прогресс
            if (_error == null)
              Container(
                width: 100.w, height: 3.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.white.withOpacity(0.1)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress,
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]))),
                ),
              ),
            if (_error != null) ...[
              SizedBox(height: 10.h),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () { setState(() { _step = 0; _progress = 0.0; _isGenerating = true; _error = null; }); _startGeneration(); },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(color: const Color(0xFF6366F1), borderRadius: BorderRadius.circular(14)),
                    child: Text('Повторить', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}