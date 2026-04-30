import 'dart:math';

class NarrativeAdvice {
  final String type;
  final String advice;
  final String? slideReference;
  final int priority;

  const NarrativeAdvice({
    required this.type,
    required this.advice,
    this.slideReference,
    this.priority = 2,
  });
}

class NarrativeAnalysis {
  final int overallScore;
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

  static NarrativeAnalysis analyzeStructure({
    required String title,
    required List<String> slideTitles,
    required List<List<String>> slideContent,
  }) {
    final advice = <NarrativeAdvice>[];
    final strengths = <String>[];
    final weaknesses = <String>[];

    if (slideTitles.isNotEmpty && slideContent.isNotEmpty) {
      final firstContent = slideContent.first;

      if (!_hasHook(firstContent)) {
        advice.add(const NarrativeAdvice(
          type: 'Открытие',
          advice:
              'Добавьте шокирующую статистику или факт в первый слайд',
          slideReference: 'Слайд 1',
          priority: 1,
        ));
        weaknesses.add('Слабое открытие');
      } else {
        strengths.add('Сильное открытие с хуком');
      }
    }

    if (slideTitles.length < 5) {
      advice.add(const NarrativeAdvice(
        type: 'Структура',
        advice:
            'Рекомендуем минимум 5–7 слайдов для раскрытия темы',
        priority: 1,
      ));
      weaknesses.add('Слишком короткая структура');
    }

    if (slideTitles.isNotEmpty &&
        slideContent.isNotEmpty &&
        !_hasCallToAction(slideContent.last)) {
      advice.add(NarrativeAdvice(
        type: 'Закрытие',
        advice:
            'Добавьте призыв к действию: "${_generateCTA()}"',
        slideReference: 'Слайд ${slideTitles.length}',
        priority: 2,
      ));
      weaknesses.add('Нет CTA');
    } else {
      strengths.add('Чёткий финал с CTA');
    }

    final hasCaseStudy = slideContent.any((content) {
      return content.any((line) {
        final l = line.toLowerCase();
        return l.contains('пример') ||
            l.contains('кейс') ||
            l.contains('case') ||
            l.contains('example');
      });
    });

    if (!hasCaseStudy && slideTitles.length > 5) {
      advice.add(const NarrativeAdvice(
        type: 'Примеры',
        advice:
            'Добавьте кейс между слайдами 3–4 для удержания внимания',
        priority: 3,
      ));
      weaknesses.add('Нет примеров');
    } else if (hasCaseStudy) {
      strengths.add('Используются кейсы');
    }

    var score = 70 +
        strengths.length * 5 -
        advice.where((a) => a.priority == 1).length * 15 -
        advice.where((a) => a.priority == 2).length * 8;

    final finalScore = score.clamp(0, 100).toInt();

    return NarrativeAnalysis(
      overallScore: finalScore,
      structureType: _detectStructureType(slideTitles),
      advice: advice,
      strengths: strengths,
      weaknesses: weaknesses,
    );
  }

  static bool _hasHook(List<String> content) {
    final hookIndicators = [
      'статистика',
      'факт',
      'знаете ли вы',
      'представьте',
      'шокирует',
      'рекорд',
    ];

    return content.any((line) {
      final l = line.toLowerCase();
      return hookIndicators.any((h) => l.contains(h));
    });
  }

  static bool _hasCallToAction(List<String> content) {
    final ctaIndicators = [
      'действуйте',
      'начните',
      'попробуйте',
      'свяжитесь',
      'подпишитесь',
      'купите',
    ];

    return content.any((line) {
      final l = line.toLowerCase();
      return ctaIndicators.any((c) => l.contains(c));
    });
  }

  static String _generateCTA() {
    const ctas = [
      'Начните применять советы уже сегодня',
      'Запишитесь на консультацию',
      'Скачайте полный отчёт',
      'Попробуйте бесплатно',
      'Изучите подробнее сейчас',
    ];

    return ctas[_random.nextInt(ctas.length)];
  }

  static String _detectStructureType(List<String> slideTitles) {
    if (slideTitles.isEmpty) return 'Не определена';

    final first = slideTitles.first.toLowerCase();
    final last = slideTitles.last.toLowerCase();

    if (first.contains('проблема') || first.contains('вызов')) {
      return 'Проблема → Решение';
    }

    if (last.contains('вывод') || last.contains('итог')) {
      return 'Классическая структура';
    }

    return 'Повествовательная';
  }

  static List<String> generateQAScript(String topic) {
    return [
      'Как это работает на практике?',
      'Какие есть ограничения?',
      'Сколько это стоит?',
      'Чем вы отличаетесь от конкурентов?',
    ];
  }

  static String generateSpeakerNotes(
    String slideTitle,
    List<String> slideContent,
  ) {
    return '''
🎤 $slideTitle

- Пауза 2 секунды перед началом
- Не читать текст со слайда
- Добавить личный пример
- Задать вопрос аудитории
''';
  }
}