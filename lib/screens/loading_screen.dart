import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  Timer? _progressTimer;
  double _progress = 0.0;
  
  final List<String> _messages = [
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
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    _bounceController.repeat(reverse: true);
    _startAnimations();
  }

  void _startAnimations() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_step < _messages.length - 1) {
        setState(() => _step++);
      }
    });
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        if (_progress < 0.9) {
          _progress += 0.02;
        }
      });
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _messageTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Doodle профессор
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4F46E5),
                    width: 3,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Профессор (эмодзи)
                    Text(
                      '🧑‍🏫',
                      style: TextStyle(fontSize: 80.sp),
                    ),
                    // Лампочка
                    Positioned(
                      top: 20,
                      right: 30,
                      child: Text(
                        '💡',
                        style: TextStyle(fontSize: 40.sp),
                      ),
                    ),
                    // Звёздочки
                    Positioned(
                      top: 10,
                      left: 20,
                      child: Text(
                        '✨',
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Text(
                        '📝',
                        style: TextStyle(fontSize: 30.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Тема презентации
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                widget.topic,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Анимированный текст
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey<int>(_step),
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  _messages[_step],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Caveat',
                    color: isDark ? Colors.white : const Color(0xFF1E1E2A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Прогресс бар в doodle стиле
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.w),
              child: Column(
                children: [
                  CustomPaint(
                    size: Size(double.infinity, 8.h),
                    painter: DoodleProgressPainter(progress: _progress),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Кастомный рисованный прогресс-бар
class DoodleProgressPainter extends CustomPainter {
  final double progress;

  DoodleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final progressPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Фоновая линия
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      backgroundPaint,
    );
    
    // Прогресс линия с doodle эффектом
    final progressWidth = size.width * progress;
    final path = Path();
    path.moveTo(0, size.height / 2);
    
    for (double x = 0; x < progressWidth; x += 5) {
      final y = size.height / 2 + (x * 0.01).sin() * 2;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, progressPaint);
    
    // Кружок на конце
    if (progress > 0.05) {
      canvas.drawCircle(
        Offset(progressWidth, size.height / 2 + (progressWidth * 0.01).sin() * 2),
        4,
        Paint()..color = const Color(0xFF4F46E5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant DoodleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Расширение для sin
extension on double {
  double sin() => _sin(this);
}

double _sin(double x) {
  double result = 0;
  double term = x;
  for (int i = 1; i <= 10; i++) {
    result += term;
    term *= -x * x / ((2 * i) * (2 * i + 1));
  }
  return result;
}