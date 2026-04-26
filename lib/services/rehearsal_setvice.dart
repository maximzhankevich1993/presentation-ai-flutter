import 'dart:math';

class RehearsalFeedback {
  final int overallScore;
  final List<SpeechTip> tips;
  final List<String> strengths;
  final List<String> improvements;

  const RehearsalFeedback({
    required this.overallScore,
    required this.tips,
    required this.strengths,
    required this.improvements,
  });
}

class SpeechTip {
  final String slideReference;
  final String type;
  final String advice;
  final TipSeverity severity;

  const SpeechTip({
    required this.slideReference,
    required this.type,
    required this.advice,
    this.severity = TipSeverity.suggestion,
  });
}

enum TipSeverity { critical, warning, suggestion, positive }

class RehearsalService {
  static final Random _random = Random();

  /// Симулирует анализ речи (в реальной версии — через микрофон)
  static Future<RehearsalFeedback> analyzeSpeech({
    required List<String> slideTitles,
    required List<List<String>> slideContent,
    double? speechDurationMinutes,
    int? wordsPerMinute,
  }) async {
    final tips = <SpeechTip>[];
    final strengths = <String>[];
    final improvements = <String>[];

    // Проверка темпа речи
    final wpm = wordsPerMinute ?? _random.nextInt(100) + 100;
    
    if (wpm > 160) {
      tips.add(SpeechTip(
        slideReference: 'Все слайды',
        type: 'Темп',
        advice: 'Вы говорите слишком быстро ($wpm слов/мин). Оптимальный темп — 120-150 слов/мин. Добавьте паузы между слайдами.',
        severity: TipSeverity.warning,
      ));
      improvements.add('Снизить темп речи');
    } else if (wpm < 100) {
      tips.add(SpeechTip(
        slideReference: 'Все слайды',
        type: 'Темп',
        advice: 'Темп речи низкий ($wpm слов/мин). Попробуйте говорить энергичнее.',
        severity: TipSeverity.suggestion,
      ));
    } else {
      strengths.add('Оптимальный темп речи ($wpm слов/мин)');
    }

    // Проверка на сложные термины
    for (int i = 0; i < slideContent.length; i++) {
      final content = slideContent[i];
      for (final line in content) {
        if (_hasComplexTerms(line)) {
          tips.add(SpeechTip(
            slideReference: 'Слайд ${i + 1}',
            type: 'Терминология',
            advice: 'Термин "${_extractComplexTerm(line)}" может быть непонятен аудитории. Объясните его простыми словами.',
            severity: TipSeverity.suggestion,
          ));
        }
      }
    }

    // Проверка пауз
    tips.add(SpeechTip(
      slideReference: 'Слайд 1',
      type: 'Открытие',
      advice: 'Сделайте 3-секундную паузу перед началом. Это привлечёт внимание.',
      severity: TipSeverity.suggestion,
    ));

    tips.add(SpeechTip(
      slideReference: 'Слайд ${slideTitles.length}',
      type: 'Закрытие',
      advice: 'Закончите сильным утверждением и сделайте паузу. Не говорите "ну вот и всё".',
      severity: TipSeverity.warning,
    ));

    strengths.add('Хорошая структура презентации');
    strengths.add('Понятные заголовки слайдов');

    final score = (strengths.length * 15 + 30).clamp(0, 100);

    return RehearsalFeedback(
      overallScore: score,
      tips: tips,
      strengths: strengths,
      improvements: improvements,
    );
  }

  static bool _hasComplexTerms(String text) {
    final complexTerms = ['синергия', 'дизруптивный', 'конвергенция', 'парадигма', 'экспоненциальный'];
    return complexTerms.any((term) => text.toLowerCase().contains(term));
  }

  static String _extractComplexTerm(String text) {
    final complexTerms = ['синергия', 'дизруптивный', 'конвергенция', 'парадигма', 'экспоненциальный'];
    for (final term in complexTerms) {
      if (text.toLowerCase().contains(term)) return term;
    }
    return 'неизвестный термин';
  }

  /// Генерирует рекомендации по языку тела
  static List<String> getBodyLanguageTips() {
    return [
      'Держите зрительный контакт с аудиторией',
      'Не стойте на месте — перемещайтесь по сцене',
      'Используйте жесты для акцентирования ключевых моментов',
      'Не поворачивайтесь спиной к аудитории',
      'Улыбайтесь в начале и в конце выступления',
    ];
  }
}