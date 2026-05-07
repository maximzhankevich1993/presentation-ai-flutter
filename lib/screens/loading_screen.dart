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

  final List<String> _messages = ['Анализирую тему...', 'Собираю информацию...', 'Придумываю структуру...', 'Пишу текст...', 'Завершаю...'];

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
      final response = await ApiService.generatePresentation(widget.topic);
      final presentation = Presentation.fromJson(response);
      setState(() { _isGenerating = false; _progress = 1.0; });
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
      backgroundColor: const Color(0xCC121212),
      body: Center(
        child: Container(
          width: 240.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) => Transform.scale(scale: _pulseAnimation.value, child: child),
              child: Container(
                width: 48.w, height: 48.w,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF17A34A)]), shape: BoxShape.circle),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 20))),
              ),
            ),
            SizedBox(height: 16.h),
            Text(widget.topic, style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            Text(_error ?? _messages[_step], style: TextStyle(fontSize: 12, color: _error != null ? const Color(0xFFFF3B30) : const Color(0xFFB3B3B3)), textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            if (_error == null)
              Container(
                width: 120.w, height: 3.h,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.white.withOpacity(0.1)),
                child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: _progress, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF17A34A)])))),
              ),
            if (_error != null) ...[
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () { setState(() { _step = 0; _progress = 0.0; _isGenerating = true; _error = null; }); _startGeneration(); },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(14)),
                  child: const Text('Повторить', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}