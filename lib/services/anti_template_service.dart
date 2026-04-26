import 'dart:math';
import 'package:flutter/material.dart';

class AntiTemplateStyle {
  final List<SlideStyle> slideStyles;
  final String name;

  const AntiTemplateStyle({
    required this.slideStyles,
    required this.name,
  });
}

class SlideStyle {
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;
  final double titleSize;
  final double bodySize;
  final Alignment textAlignment;

  const SlideStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.titleSize,
    required this.bodySize,
    required this.textAlignment,
  });
}

class AntiTemplateService {
  static final Random _random = Random();

  // Библиотека «разрывных» стилей — намеренно разных
  static final List<SlideStyle> _styleLibrary = [
    const SlideStyle(backgroundColor: Color(0xFFFFFFFF), textColor: Color(0xFF1A1A2E), fontFamily: 'Inter', titleSize: 36, bodySize: 18, textAlignment: Alignment.centerLeft),
    const SlideStyle(backgroundColor: Color(0xFF1A1A2E), textColor: Color(0xFFFFFFFF), fontFamily: 'Poppins', titleSize: 42, bodySize: 20, textAlignment: Alignment.center),
    const SlideStyle(backgroundColor: Color(0xFFFFF8E7), textColor: Color(0xFF3E1E1E), fontFamily: 'Georgia', titleSize: 32, bodySize: 16, textAlignment: Alignment.topLeft),
    const SlideStyle(backgroundColor: Color(0xFFF4F8F4), textColor: Color(0xFF1A3A2A), fontFamily: 'Inter', titleSize: 38, bodySize: 18, textAlignment: Alignment.centerLeft),
    const SlideStyle(backgroundColor: Color(0xFF2D1B4E), textColor: Color(0xFFFFF7E6), fontFamily: 'Poppins', titleSize: 44, bodySize: 22, textAlignment: Alignment.centerRight),
    const SlideStyle(backgroundColor: Color(0xFFE8F5E9), textColor: Color(0xFF1B3A1B), fontFamily: 'Caveat', titleSize: 40, bodySize: 20, textAlignment: Alignment.center),
    const SlideStyle(backgroundColor: Color(0xFFFFF3E0), textColor: Color(0xFF5D4037), fontFamily: 'Georgia', titleSize: 34, bodySize: 17, textAlignment: Alignment.topLeft),
    const SlideStyle(backgroundColor: Color(0xFF0B0C10), textColor: Color(0xFF00FFCC), fontFamily: 'Inter', titleSize: 46, bodySize: 24, textAlignment: Alignment.center),
  ];

  // Названия стилей для интриги
  static final List<String> _styleNames = [
    'Хаос и порядок',
    'Контрастный взрыв',
    'Визуальный джаз',
    'Типографский бунт',
    'Цветовой шторм',
    'Ритмический диссонанс',
    'Стилевая какофония',
    'Дизайнерский эксперимент',
  ];

  /// Генерирует уникальную последовательность стилей для слайдов
  static AntiTemplateStyle generateForSlides(int slideCount) {
    final styles = <SlideStyle>[];
    
    // Обеспечиваем, чтобы соседние слайды были максимально разными
    SlideStyle? previous;
    
    for (int i = 0; i < slideCount; i++) {
      SlideStyle next;
      
      // Выбираем стиль, максимально отличающийся от предыдущего
      final available = _styleLibrary.where((s) => s != previous).toList();
      next = available[_random.nextInt(available.length)];
      
      styles.add(next);
      previous = next;
    }
    
    return AntiTemplateStyle(
      slideStyles: styles,
      name: _styleNames[_random.nextInt(_styleNames.length)],
    );
  }

  /// Возвращает случайный «разрывной» переход между стилями
  static String getRandomTransitionEffect() {
    final effects = [
      'fade', 'slide', 'zoom', 'dissolve', 'glitch'
    ];
    return effects[_random.nextInt(effects.length)];
  }

  /// Рассчитывает «индекс уникальности» презентации (0-100)
  static int calculateUniquenessScore(AntiTemplateStyle style) {
    // Чем больше разных стилей — тем выше уникальность
    final uniqueStyles = style.slideStyles.toSet().length;
    final totalSlides = style.slideStyles.length;
    
    if (totalSlides == 0) return 0;
    
    final ratio = uniqueStyles / totalSlides;
    return (ratio * 100).round().clamp(0, 100);
  }
}