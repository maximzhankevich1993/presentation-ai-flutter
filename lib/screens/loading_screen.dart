import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/presentation.dart';
import 'editor_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String topic;

  const LoadingScreen({
    super.key,
    required this.topic,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  Timer? _messageTimer;
  Timer? _progressTimer;

  int _step = 0;
  double _progress = 0.0;

  bool _isGenerating = true;
  String? _error;
  int _slidesGenerated = 0;

  final List<String> _messages = const [
    '🤔 Анализирую тему...',
    '📚 Собираю информацию...',
    '💡 Придумываю структуру...',
    '✍️ Пишу текст слайдов...',
    '🖼 Подбираю иллюстрации...',
    '🎨 Оформляю дизайн...',
    '✨ Финальные штрихи...',
  ];

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _bounceController.repeat(reverse: true);

    _startGeneration();
  }

  void _startGeneration() {
    _messageTimer?.cancel();
    _progressTimer?.cancel();

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isGenerating || !mounted) {
        timer.cancel();
        return;
      }

      if (_step < _messages.length - 1) {
        setState(() => _step++);
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isGenerating || !mounted) {
        timer.cancel();
        return;
      }

      if (_progress < 0.9) {
        setState(() => _progress += 0.015);
      }
    });

    _generatePresentation();
  }

  Future<void> _generatePresentation() async {
    try {
      final userProvider =
          Provider.of<UserProvider>(context, listen: false);

      final success = await userProvider.useGeneration();
      if (!success) {
        throw Exception('Нет доступных генераций');
      }

      final presentation = await ApiService.generatePresentation(
        widget.topic,
        maxSlides: userProvider.maxSlidesPerPresentation,
      );

      if (!mounted) return;

      _slidesGenerated = presentation.slides.length;

      setState(() {
        _isGenerating = false;
        _progress = 1.0;
        _step = _messages.length - 1;
      });

      _cancelTimers();

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGenerating = false;
        _error = _formatError(e);
      });

      _cancelTimers();
    }
  }

  String _formatError(Object e) {
    final text = e.toString();
    return text.replaceAll('Exception: ', '');
  }

  void _retry() {
    setState(() {
      _step = 0;
      _progress = 0.0;
      _isGenerating = true;
      _error = null;
      _slidesGenerated = 0;
    });

    _startGeneration();
  }

  void _cancelTimers() {
    _messageTimer?.cancel();
    _progressTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// ✅ используем встроенный AnimatedBuilder (НЕ свой)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: _buildAvatar(),
            ),

            SizedBox(height: 40.h),

            _buildTopic(),

            SizedBox(height: 24.h),

            _buildMessage(isDark),

            SizedBox(height: 40.h),

            _error != null ? _buildRetryButton() : _buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 200.w,
      height: 200.w,
      decoration: BoxDecoration(
        color: _error != null
            ? Colors.red.withOpacity(0.1)
            : const Color(0xFF4F46E5).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: _error != null
              ? Colors.red
              : const Color(0xFF4F46E5),
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            _error != null ? '😔' : '🧑‍🏫',
            style: TextStyle(fontSize: 80.sp),
          ),
          if (_error == null) ...[
            Positioned(
                top: 20,
                right: 30,
                child: Text('💡', style: TextStyle(fontSize: 40.sp))),
            Positioned(
                top: 10,
                left: 20,
                child: Text('✨', style: TextStyle(fontSize: 20.sp))),
            Positioned(
                bottom: 20,
                right: 20,
                child: Text('📝', style: TextStyle(fontSize: 30.sp))),
          ],
        ],
      ),
    );
  }

  Widget _buildTopic() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        widget.topic,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.sp,
          color: const Color(0xFF4F46E5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessage(bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _error != null ? '❌ $_error' : _messages[_step],
        key: ValueKey(_error ?? _step),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: _error != null
              ? Colors.red
              : (isDark ? Colors.white : const Color(0xFF1E1E2A)),
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton(
      onPressed: _retry,
      child: const Text('Попробовать снова'),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w),
      child: Column(
        children: [
          CustomPaint(
            size: Size(double.infinity, 8.h),
            painter: DoodleProgressPainter(progress: _progress),
          ),
          SizedBox(height: 8.h),
          Text('${(_progress * 100).toInt()}%'),
          if (_slidesGenerated > 0)
            Text('📊 Создано $_slidesGenerated слайдов'),
        ],
      ),
    );
  }
}

class DoodleProgressPainter extends CustomPainter {
  final double progress;

  DoodleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 3;

    final fg = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      bg,
    );

    final path = Path();
    final width = size.width * progress;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x < width; x += 5) {
      final y = size.height / 2 + sin(x * 0.02) * 2;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, fg);
  }

  @override
  bool shouldRepaint(covariant DoodleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}