import 'package:flutter/material.dart';
import '../models/presentation.dart';

class StoryFrame {
  final String title;
  final String? subtitle;
  final String content;
  final String? imageUrl;
  final Color backgroundColor;
  final double duration; // в секундах
  final StoryTransition transition;

  const StoryFrame({
    required this.title,
    this.subtitle,
    required this.content,
    this.imageUrl,
    required this.backgroundColor,
    this.duration = 5.0,
    this.transition = StoryTransition.fade,
  });
}

enum StoryTransition { fade, slideUp, zoom, dissolve }

class StoryModeService {
  /// Конвертирует презентацию в формат Story
  static List<StoryFrame> convertToStory(Presentation presentation) {
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF0D9488),
      const Color(0xFFDC2626),
      const Color(0xFF1E3A5F),
      const Color(0xFF7C3AED),
      const Color(0xFFB224EF),
      const Color(0xFF11998E),
      const Color(0xFFCB356B),
    ];

    return presentation.slides.asMap().entries.map((entry) {
      final index = entry.key;
      final slide = entry.value;
      
      return StoryFrame(
        title: slide.title,
        subtitle: slide.subtitle,
        content: slide.content.join('\n'),
        imageUrl: slide.imageUrl,
        backgroundColor: colors[index % colors.length],
        duration: _calculateDuration(slide),
        transition: _getTransitionForIndex(index),
      );
    }).toList();
  }

  /// Рассчитывает оптимальную длительность показа
  static double _calculateDuration(Slide slide) {
    final wordCount = slide.content.fold<int>(0, (sum, line) => sum + line.split(' ').length);
    // ~3 слова в секунду + 2 секунды на заголовок
    return (wordCount / 3) + 2;
  }

  /// Возвращает переход для кадра
  static StoryTransition _getTransitionForIndex(int index) {
    switch (index % 4) {
      case 0:
        return StoryTransition.fade;
      case 1:
        return StoryTransition.slideUp;
      case 2:
        return StoryTransition.zoom;
      default:
        return StoryTransition.dissolve;
    }
  }

  /// Создаёт виджет для одного кадра Story
  static Widget buildStoryFrame(BuildContext context, StoryFrame frame) {
    return Container(
      color: frame.backgroundColor,
      child: Stack(
        children: [
          // Фоновое изображение
          if (frame.imageUrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.network(
                  frame.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            ),
          
          // Контент
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  frame.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (frame.subtitle != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    frame.subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Text(
                  frame.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 18,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Индикатор прогресса
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(5, (i) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == 0 ? Colors.white : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Кнопка «Поделиться»
          Positioned(
            bottom: 40,
            right: 30,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.share, color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }

  /// Возвращает текст для шаринга Story
  static String getStoryShareText(String presentationTitle) {
    return '📱 Смотри мою презентацию "$presentationTitle" в формате Story!\n\nСоздано в Презентатор ИИ ✨';
  }
}