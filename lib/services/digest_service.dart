import 'dart:math';

class WeeklyDigest {
  final String title;
  final String weekRange;
  final List<DigestItem> topStories;
  final String tipOfTheWeek;
  final String presentationTemplate;

  const WeeklyDigest({
    required this.title,
    required this.weekRange,
    required this.topStories,
    required this.tipOfTheWeek,
    required this.presentationTemplate,
  });
}

class DigestItem {
  final String title;
  final String summary;
  final String category;
  final String emoji;

  const DigestItem({
    required this.title,
    required this.summary,
    required this.category,
    required this.emoji,
  });
}

class DigestService {
  static final Random _random = Random();

  /// Генерирует еженедельный дайджест
  static WeeklyDigest generateWeeklyDigest({String? industry}) {
    final stories = [
      DigestItem(
        title: 'ИИ научился создавать 3D-анимацию',
        summary: 'Новая модель от DeepMind генерирует трёхмерные сцены по текстовому описанию за секунды.',
        category: 'Технологии',
        emoji: '🤖',
      ),
      DigestItem(
        title: 'Рынок AI-инструментов вырос на 40%',
        summary: 'По данным Crunchbase, инвестиции в AI-стартапы достигли рекордных $50 млрд в первом квартале 2026.',
        category: 'Бизнес',
        emoji: '📈',
      ),
      DigestItem(
        title: 'Google обновил алгоритмы поиска',
        summary: 'Новое обновление отдаёт приоритет контенту, созданному экспертами. Качество важнее количества.',
        category: 'Маркетинг',
        emoji: '🔍',
      ),
      DigestItem(
        title: 'Как подготовить презентацию за 5 минут',
        summary: 'Эксперты Harvard Business Review поделились методикой быстрой подготовки убедительных презентаций.',
        category: 'Продуктивность',
        emoji: '⚡',
      ),
      DigestItem(
        title: 'Тренды дизайна презентаций в 2026',
        summary: 'Минимализм, смелая типографика и интерактивные элементы — главные тренды этого года.',
        category: 'Дизайн',
        emoji: '🎨',
      ),
    ];

    final tips = [
      'Используйте правило 10-20-30: 10 слайдов, 20 минут, 30-й размер шрифта.',
      'Добавляйте на каждый слайд не более одной ключевой мысли.',
      'Начинайте презентацию с неожиданного факта — это захватывает внимание.',
      'Заканчивайте призывом к действию, а не словами "спасибо за внимание".',
    ];

    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return WeeklyDigest(
      title: 'Топ-тренды недели${industry != null ? ' в $industry' : ''}',
      weekRange: '${_formatDate(weekStart)} — ${_formatDate(weekEnd)}',
      topStories: stories..shuffle(_random),
      tipOfTheWeek: tips[_random.nextInt(tips.length)],
      presentationTemplate: 'weekly_digest_template',
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}.${date.month}';
  }

  /// Форматирует дайджест для email-рассылки
  static String formatForEmail(WeeklyDigest digest) {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 ${digest.title}');
    buffer.writeln('Неделя: ${digest.weekRange}');
    buffer.writeln();
    buffer.writeln('🔥 ГЛАВНЫЕ НОВОСТИ:');
    buffer.writeln();
    
    for (final story in digest.topStories.take(3)) {
      buffer.writeln('${story.emoji} ${story.title}');
      buffer.writeln(story.summary);
      buffer.writeln();
    }
    
    buffer.writeln('💡 СОВЕТ НЕДЕЛИ:');
    buffer.writeln(digest.tipOfTheWeek);
    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Этот дайджест автоматически создан Презентатор ИИ.');
    
    return buffer.toString();
  }
}