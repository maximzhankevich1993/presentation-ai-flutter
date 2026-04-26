import 'dart:math';

class NarrativeAdvice {
  final String type;
  final String advice;
  final String? slideReference;
  final int priority; // 1 = срочно, 2 = важно, 3 = рекомендация

  const NarrativeAdvice({
    required this.type,
    required this.advice,
    this.slideReference,
    this.priority = 2,
  });
}

class NarrativeAnalysis {
  final int overallScore; // 0-100
  final String structureType;
  final List<NarrativeAdvice> advice;
  final List<String> strengths;
  final List<String> weaknesses;

  const NarrativeAnalysis({
    required this.overallScore,
    required this.structureType,
    required this.advice,
    required this.strengths,
    required this.weaknesses,
  });
}

class AiConsultantService {
  static final Random _random = Random();

  /// Анализирует структуру презентации
  static NarrativeAnalysis analyzeStructure({
    required String title,
    required List<String> slideTitles,
    required List<List<String>> slideContent,
  }) {
    final advice = <NarrativeAdvice>[];
    final strengths = <String>[];
    final weaknesses = <String>[];

    // Проверяем первый слайд
    if (slideTitles.isNotEmpty) {
      if (!_hasHook(slideContent.first)) {
        advice.add(const NarrativeAdvice(
          type: 'Открытие',
          advice: 'Добавьте шокирующую статистику или неожиданный факт в первый слайд, чтобы захватить внимание',
          slideReference: 'Слайд 1',
          priority: 1,
        ));
      } else {
        strengths.add('Сильное открытие с хуком');
      }
    }

    // Проверяем структуру
    if (slideTitles.length < 5) {
      advice.add(const NarrativeAdvice(
        type: 'Структура',
        advice: 'Слишком мало слайдов. Рекомендуем минимум 5-7 для полного раскрытия темы',
        priority: 1,
      ));
    }

    // Проверяем последний слайд
    if (slideTitles.isNotEmpty && !_hasCallToAction(slideContent.last)) {
      advice.add(NarrativeAdvice(
        type: 'Закрытие',
        advice: 'Добавьте призыв к действию на последнем слайде. Например: "${_generateCTA()}"',
        slideReference: 'Слайд ${slideTitles.length}',
        priority: 2,
      ));
    } else {
      strengths.add('Чёткий призыв к действию в конце');
    }

    // Проверяем наличие кейсов
    final hasCaseStudy = slideContent.any((content) => 
      content.any((line) => line.toLowerCase().contains('пример') || line.toLowerCase().contains('кейс'))
    );
    
    if (!hasCaseStudy && slideTitles.length > 5) {
      advice.add(const NarrativeAdvice(
        type: 'Примеры',
        advice: 'Добавьте реальный кейс или пример между слайдами 3 и 4 для удержания внимания',
        priority: 3,
      ));
    } else if (hasCaseStudy) {
      strengths.add('Использование кейсов для иллюстрации');
    }

    // Общая оценка
    var score = 70;
    score += strengths.length * 5;
    score -= advice.where((a) => a.priority == 1).length * 15;
    score -= advice.where((a) => a.priority == 2).length * 8;
    score = score.clamp(0, 100);

    return NarrativeAnalysis(
      overallScore: score,
      structureType: _detectStructureType(slideTitles),
      advice: advice,
      strengths: strengths,
      weaknesses: weaknesses,
    );
  }

  static bool _hasHook(List<String> content) {
    final hookIndicators = ['статистика', 'факт', 'знаете ли вы', 'представьте', 'шокирует', 'рекорд'];
    return content.any((line) => hookIndicators.any((h) => line.toLowerCase().contains(h)));
  }

  static bool _hasCallToAction(List<String> content) {
    final ctaIndicators = ['действуйте', 'начните', 'попробуйте', 'свяжитесь', 'подпишитесь', 'купите'];
    return content.any((line) => ctaIndicators.any((c) => line.toLowerCase().contains(c)));
  }

  static String _generateCTA() {
    final ctas = [
      'Начните применять эти советы уже сегодня',
      'Запишитесь на бесплатную консультацию',
      'Скачайте полную версию отчёта',
      'Подпишитесь на наши обновления',
      'Попробуйте бесплатный триал',
    ];
    return ctas[_random.nextInt(ctas.length)];
  }

  static String _detectStructureType(List<String> slideTitles) {
    if (slideTitles.isEmpty) return 'Не определена';
    if (slideTitles.first.toLowerCase().contains('проблема') || slideTitles.first.toLowerCase().contains('вызов')) {
      return 'Проблема → Решение';
    }
    if (slideTitles.last.toLowerCase().contains('вывод') || slideTitles.last.toLowerCase().contains('итог')) {
      return 'Классическая (Введение → Основная часть → Заключение)';
    }
    return 'Повествовательная';
  }

  /// Генерирует сценарий для Q&A-сессии
  static List<String> generateQAScript(String topic) {
    return [
      'Вопрос 1: Как это работает на практике?',
      'Ответ: Приведите конкретный пример из вашего опыта.',
      '',
      'Вопрос 2: Какие есть ограничения?',
      'Ответ: Честно расскажите о границах применимости.',
      '',
      'Вопрос 3: Сколько это стоит?',
      'Ответ: Подготовьте прозрачную таблицу с ценами.',
      '',
      'Вопрос 4: Чем вы отличаетесь от конкурентов?',
      'Ответ: Выделите 2-3 ключевых преимущества.',
    ];
  }

  /// Генерирует заметки докладчика для каждого слайда
  static String generateSpeakerNotes(String slideTitle, List<String> slideContent) {
    final notes = StringBuffer();
    notes.writeln('🎤 Заметки докладчика для слайда "$slideTitle":');
    notes.writeln('- Начните с паузы в 2 секунды');
    notes.writeln('- Не читайте текст со слайда слово в слово');
    notes.writeln('- Приведите дополнительный пример, которого нет на слайде');
    notes.writeln('- Задайте вопрос аудитории для вовлечения');
    return notes.toString();
  }
}