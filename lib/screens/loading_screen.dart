import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

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
    _startGeneration();
  }

  void _startGeneration() {
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_step < _messages.length - 1 && _isGenerating) {
        setState(() => _step++);
      }
    });
    
    _simulateProgress();
    _generatePresentation();
  }

  void _simulateProgress() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isGenerating && _progress < 0.9) {
        setState(() => _progress += 0.015);
      } else if (!_isGenerating) {
        timer.cancel();
      }
    });
  }

  Future<void> _generatePresentation() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Используем генерацию
      final success = await userProvider.useGeneration();
      if (!success) {
        throw Exception('Нет доступных генераций');
      }
      
      // Отправляем запрос к API
      final presentation = await ApiService.generatePresentation(
        widget.topic,
        maxSlides: userProvider.maxSlidesPerPresentation,
      );
      
      _slidesGenerated = presentation.slides.length;
      
      // Завершаем загрузку
      setState(() {
        _isGenerating = false;
        _progress = 1.0;
        _step = _messages.length - 1;
      });
      
      _messageTimer?.cancel();
      
      // Ждём немного и переходим к редактору (пока просто возвращаемся)
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        _showSuccessDialog(presentation);
      }
      
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _error = e.toString();
      });
      _messageTimer?.cancel();
    }
  }

  void _showSuccessDialog(Presentation presentation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text('Готово!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Презентация "${presentation.title}" создана!'),
            const SizedBox(height: 8),
            Text('📊 Слайдов: ${presentation.slides.length}'),
            const SizedBox(height: 4),
            Text('🖼 Картинок: ${presentation.slides.where((s) => s.imageUrl != null).length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться на HomeScreen
            },
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться на HomeScreen
              
              // TODO: Переход в редактор
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Редактор в разработке'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Редактировать'),
          ),
        ],
      ),
    );
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
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка назад (если ошибка)
            if (_error != null)
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            
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
                  color: _error != null 
                      ? Colors.red.withOpacity(0.1)
                      : const Color(0xFF4F46E5).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _error != null ? Colors.red : const Color(0xFF4F46E5),
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
                        child: Text('💡', style: TextStyle(fontSize: 40.sp)),
                      ),
                      Positioned(
                        top: 10,
                        left: 20,
                        child: Text('✨', style: TextStyle(fontSize: 20.sp)),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Text('📝', style: TextStyle(fontSize: 30.sp)),
                      ),
                    ],
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
            
            // Текст статуса
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_error != null ? 'error' : _step),
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  _error != null 
                      ? '❌ ${_error.toString().replaceAll('Exception: ', '')}'
                      : _messages[_step],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Caveat',
                    color: _error != null 
                        ? Colors.red 
                        : (isDark ? Colors.white : const Color(0xFF1E1E2A)),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 40.h),
            
            // Прогресс или кнопка повтора
            if (_error != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _step = 0;
                    _progress = 0.0;
                    _isGenerating = true;
                    _error = null;
                  });
                  _startGeneration();
                },
                child: const Text('Попробовать снова'),
              )
            else
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
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                    if (_slidesGenerated > 0)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          '📊 Создано $_slidesGenerated слайдов',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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
    
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      backgroundPaint,
    );
    
    final progressWidth = size.width * progress;
    final path = Path();
    path.moveTo(0, size.height / 2);
    
    for (double x = 0; x < progressWidth; x += 5) {
      final y = size.height / 2 + (x * 0.02).sin() * 2;
      path.lineTo(x, y);
    }
    
    canvas.drawPath(path, progressPaint);
    
    if (progress > 0.05) {
      canvas.drawCircle(
        Offset(progressWidth, size.height / 2 + (progressWidth * 0.02).sin() * 2),
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

extension on double {
  double sin() {
    double x = this;
    double result = x;
    double term = x;
    for (int i = 1; i <= 5; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}