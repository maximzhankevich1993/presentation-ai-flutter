import 'dart:math';
import '../models/presentation.dart';

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

class SpeechNotes {
  final String fullSpeech;
  final String shortVersion;
  final List<SlideNote> slideNotes;

  const SpeechNotes({
    required this.fullSpeech,
    required this.shortVersion,
    required this.slideNotes,
  });
}

class SlideNote {
  final int slideNumber;
  final String title;
  final String whatToSay;
  final String? tip;

  const SlideNote({
    required this.slideNumber,
    required this.title,
    required this.whatToSay,
    this.tip,
  });
}

class AiConsultantService {
  static final Random _random = Random();

  /// Генерирует полный текст выступления по слайдам
  static SpeechNotes generateSpeechNotes(Presentation presentation) {
    final slideNotes = <SlideNote>[];
    final fullSpeechBuffer = StringBuffer();
    final shortVersionBuffer = StringBuffer();

    // Вступление
    fullSpeechBuffer.writeln('Добрый день, уважаемые коллеги!');
    fullSpeechBuffer.writeln('Сегодня я представлю вам презентацию на тему "${presentation.title}".');
    fullSpeechBuffer.writeln();

    shortVersionBuffer.writeln('Тема: ${presentation.title}.');

    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];
      final firstPoint = slide.content.isNotEmpty ? slide.content.first : '';
      final secondPoint = slide.content.length > 1 ? slide.content[1] : '';

      String whatToSay;
      String? tip;

      if (i == 0) {
        whatToSay = 'Итак, начнём с первого слайда. ${slide.title}. $firstPoint.';
        tip = 'Сделайте паузу 2 секунды перед началом';
      } else if (i == presentation.slides.length - 1) {
        whatToSay = 'И в заключение. ${slide.title}. $firstPoint. Спасибо за внимание!';
        tip = 'Закончите уверенно, не говорите "ну вот и всё"';
      } else {
        whatToSay = 'Переходим к следующему. ${slide.title}. $firstPoint. $secondPoint.';
      }

      slideNotes.add(SlideNote(
        slideNumber: i + 1,
        title: slide.title,
        whatToSay: whatToSay,
        tip: tip,
      ));

      fullSpeechBuffer.writeln(whatToSay);
      fullSpeechBuffer.writeln();

      if (i == 0 || i == presentation.slides.length - 1) {
        shortVersionBuffer.writeln(whatToSay);
      }
    }

    fullSpeechBuffer.writeln('Буду рад ответить на ваши вопросы!');

    return SpeechNotes(
      fullSpeech: fullSpeechBuffer.toString(),
      shortVersion: shortVersionBuffer.toString(),
      slideNotes: slideNotes,
    );
  }

  /// Генерирует Q&A сценарий
  static List<String> generateQAScript(String topic) {
    return [
      '❓ Вопрос: Как это применить на практике?',
      '✅ Ответ: Приведите 2-3 конкретных шага из вашего опыта.',
      '',
      '❓ Вопрос: Какие есть ограничения?',
      '✅ Ответ: Честно расскажите о границах применимости.',
      '',
      '❓ Вопрос: Сколько это стоит / занимает времени?',
      '✅ Ответ: Дайте чёткие цифры, сравните с альтернативами.',
      '',
      '❓ Вопрос: Где узнать больше?',
      '✅ Ответ: Направьте на сайт, блог или подпишитесь на рассылку.',
    ];
  }

  /// Анализирует структуру презентации
  static NarrativeAnalysis analyzeStructure({
    required String title,
    required List<String> slideTitles,
    required List<List<String>> slideContent,
  }) {
    final advice = <NarrativeAdvice>[];
    final strengths = <String>[];
    final weaknesses = <String>[];

    if (slideTitles.isNotEmpty && !_hasHook(slideContent.first)) {
      advice.add(const NarrativeAdvice(type: 'Открытие', advice: 'Добавьте шокирующую статистику в первый слайд', slideReference: 'Слайд 1', priority: 1));
    } else {
      strengths.add('Сильное открытие');
    }

    if (slideTitles.length < 5) {
      advice.add(const NarrativeAdvice(type: 'Структура', advice: 'Слишком мало слайдов. Минимум 5-7.', priority: 1));
    }

    if (slideTitles.isNotEmpty && !_hasCallToAction(slideContent.last)) {
      advice.add(NarrativeAdvice(type: 'Закрытие', advice: 'Добавьте призыв к действию', slideReference: 'Слайд ${slideTitles.length}', priority: 2));
    } else {
      strengths.add('Чёткий призыв к действию');
    }

    var score = 70 + strengths.length * 5 - advice.where((a) => a.priority == 1).length * 15;
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
    return content.any((line) => ['статистика', 'факт', 'знаете ли вы', 'представьте', 'рекорд'].any((h) => line.toLowerCase().contains(h)));
  }

  static bool _hasCallToAction(List<String> content) {
    return content.any((line) => ['действуйте', 'начните', 'попробуйте', 'свяжитесь', 'подпишитесь', 'купите'].any((c) => line.toLowerCase().contains(c)));
  }

  static String _detectStructureType(List<String> slideTitles) {
    if (slideTitles.isEmpty) return 'Не определена';
    if (slideTitles.first.toLowerCase().contains('проблема')) return 'Проблема → Решение';
    if (slideTitles.last.toLowerCase().contains('вывод') || slideTitles.last.toLowerCase().contains('итог')) return 'Классическая';
    return 'Повествовательная';
  }
}