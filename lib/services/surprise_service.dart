import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/animation_service.dart';

class SurpriseStyle {
  final String themeName;
  final String fontPair;
  final String gradientId;
  final String transitionId;
  final Color primaryColor;
  final Color backgroundColor;

  const SurpriseStyle({
    required this.themeName,
    required this.fontPair,
    required this.gradientId,
    required this.transitionId,
    required this.primaryColor,
    required this.backgroundColor,
  });
}

class SurpriseService {
  static final Random _random = Random();

  // Список названий стилей для интриги
  static final List<String> _styleNames = [
    '🔥 Огненный закат',
    '🌊 Морская волна',
    '🌸 Весенний сад',
    '🌙 Ночной город',
    '🪐 Космическая одиссея',
    '🍂 Осенний лес',
    '⚡ Электрический шторм',
    '🎪 Цирковое представление',
    '🏛 Античный мрамор',
    '🤖 Киберпанк-будущее',
    '🎨 Импрессионизм',
    '📟 Ретро-терминал',
    '🌈 Радужный взрыв',
    '🕶 Нуарный детектив',
    '🧪 Химическая лаборатория',
  ];

  // Список забавных фактов для показа во время генерации
  static final List<String> _funFacts = [
    'Знаете ли вы? Первая компьютерная презентация была создана в 1979 году.',
    'Факт: Слушатели запоминают только 10% сказанного, но 65% увиденного на слайдах.',
    'Совет: Один слайд — одна мысль. Не перегружайте аудиторию.',
    'Интересно: Самый популярный шрифт для презентаций — Helvetica.',
    'Лайфхак: Используйте правило 10-20-30: 10 слайдов, 20 минут, 30-й кегль.',
  ];

  /// Генерирует случайный стиль презентации
  static SurpriseStyle generateRandomStyle() {
    final themes = [
      'Киберпанк', 'Закат', 'Северный лес', 'Мятный', 
      'Вишнёвый', 'Космический', 'Песчаный', 'Графитовый',
    ];
    
    final fonts = [
      'modern_tech', 'clean_swiss', 'classic_elegance', 
      'playful_hand', 'brutal_mono', 'serious_business',
    ];
    
    final gradients = [
      'aurora', 'peach', 'purple', 'mojito', 'blood_moon', 'simple',
    ];
    
    final transitions = AnimationService.getTransitions();
    
    final colors = [
      Colors.indigo, Colors.teal, Colors.deepOrange, Colors.pink,
      Colors.amber, Colors.cyan, Colors.lightGreen, Colors.deepPurple,
    ];

    return SurpriseStyle(
      themeName: _styleNames[_random.nextInt(_styleNames.length)],
      fontPair: fonts[_random.nextInt(fonts.length)],
      gradientId: gradients[_random.nextInt(gradients.length)],
      transitionId: transitions[_random.nextInt(transitions.length)].id,
      primaryColor: colors[_random.nextInt(colors.length)],
      backgroundColor: _random.nextBool() 
          ? Colors.white 
          : const Color(0xFF1E1E2A),
    );
  }

  /// Возвращает случайный забавный факт
  static String getRandomFunFact() {
    return _funFacts[_random.nextInt(_funFacts.length)];
  }

  /// Проверяет, можно ли использовать функцию
  static bool canUseSurprise(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.canUseSurpriseMe;
  }

  /// Использует одну попытку «Удиви меня»
  static Future<bool> useSurprise(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return await userProvider.useSurpriseMe();
  }

  /// Показывает экран «Удиви меня» с анимацией
  static void showSurpriseAnimation(BuildContext context, VoidCallback onComplete) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _SurpriseAnimationDialog(onComplete: onComplete);
      },
    );
  }
}

// Анимированный диалог «Удиви меня»
class _SurpriseAnimationDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _SurpriseAnimationDialog({required this.onComplete});

  @override
  State<_SurpriseAnimationDialog> createState() => _SurpriseAnimationDialogState();
}

class _SurpriseAnimationDialogState extends State<_SurpriseAnimationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  int _factIndex = 0;
  final List<String> _facts = SurpriseService._funFacts;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.forward();
    
    // Меняем факты каждые 1.5 секунды
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _factIndex = 1);
      }
    });
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.1,
              child: child,
            ),
          );
        },
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF7C3AED),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎲', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Удивляем!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _facts[_factIndex],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const LinearProgressIndicator(
                color: Color(0xFF7C3AED),
              ),
            ],
          ),
        ),
      ),
    );
  }
}