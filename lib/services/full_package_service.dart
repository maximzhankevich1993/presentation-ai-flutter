import '../models/presentation.dart';

class FullPackage {
  final Presentation presentation;
  final String speakerNotes;
  final List<String> qaScript;
  final String handoutDocument;
  final String socialMediaKit;
  final String videoScript;
  final List<String> followUpEmails;

  const FullPackage({
    required this.presentation,
    required this.speakerNotes,
    required this.qaScript,
    required this.handoutDocument,
    required this.socialMediaKit,
    required this.videoScript,
    required this.followUpEmails,
  });
}

class FullPackageService {
  static FullPackage generateFullPackage(Presentation presentation) {
    return FullPackage(
      presentation: presentation,
      speakerNotes: _generateSpeakerNotes(presentation),
      qaScript: _generateQAScript(presentation),
      handoutDocument: _generateHandout(presentation),
      socialMediaKit: _generateSocialMediaKit(presentation),
      videoScript: _generateVideoScript(presentation),
      followUpEmails: _generateFollowUpEmails(presentation),
    );
  }

  static String _generateSpeakerNotes(Presentation presentation) {
    final buffer = StringBuffer();
    buffer.writeln('🎤 ЗАМЕТКИ ДОКЛАДЧИКА');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];

      final firstPoint = slide.content.isNotEmpty
          ? slide.content.first
          : 'Добавьте ключевую мысль';

      buffer.writeln('--- Слайд ${i + 1}: ${slide.title} ---');
      buffer.writeln('• Начните с: [зрительный контакт, пауза 2 сек]');
      buffer.writeln('• Ключевое сообщение: $firstPoint');
      buffer.writeln('• Дополнительный пример: [история из опыта]');
      buffer.writeln(
        '• Вопрос аудитории: "${_generateEngagementQuestion(slide.title)}"',
      );
      buffer.writeln(
        '• Переход: "${_generateTransition(i, presentation.slides.length)}"',
      );
      buffer.writeln();
    }

    return buffer.toString();
  }

  static List<String> _generateQAScript(Presentation presentation) {
    return [
      '❓ В: Как это применить на практике?',
      '✅ О: Дайте 2-3 конкретных шага.',
      '',
      '❓ В: Какие есть риски?',
      '✅ О: Честно обозначьте ограничения.',
      '',
      '❓ В: Сколько это стоит / занимает времени?',
      '✅ О: Дайте конкретные цифры.',
      '',
      '❓ В: Где узнать больше?',
      '✅ О: Дайте ссылку или контакт.',
    ];
  }

  static String _generateHandout(Presentation presentation) {
    final buffer = StringBuffer();
    buffer.writeln('📄 РАЗДАТОЧНЫЙ МАТЕРИАЛ');
    buffer.writeln();
    buffer.writeln('Тема: ${presentation.title}');
    buffer.writeln(
      'Дата: ${DateTime.now().toString().split(' ')[0]}',
    );
    buffer.writeln();

    buffer.writeln('КЛЮЧЕВЫЕ ВЫВОДЫ:');

    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];

      final firstPoint = slide.content.isNotEmpty
          ? slide.content.first
          : 'Нет данных';

      buffer.writeln('${i + 1}. ${slide.title}');
      buffer.writeln('   $firstPoint');
    }

    buffer.writeln();
    buffer.writeln('ДЕЙСТВИЯ ПОСЛЕ ПРЕЗЕНТАЦИИ:');
    buffer.writeln('1. Изучить материалы');
    buffer.writeln('2. Применить на практике');
    buffer.writeln('3. Поделиться с командой');

    return buffer.toString();
  }

  static String _generateSocialMediaKit(Presentation presentation) {
    return '''
📱 КОМПЛЕКТ ДЛЯ СОЦСЕТЕЙ:

LinkedIn:
"${presentation.title}
Ключевые идеи: [3 пункта]"

Twitter:
🧵 ${presentation.title}
1/ Основная идея
2/ Ключевой инсайт
3/ Вывод

Instagram:
• Обложка
• Идея 1
• Идея 2
• Итог
''';
  }

  static String _generateVideoScript(Presentation presentation) {
    return '''
🎬 СЦЕНАРИЙ (60 сек):

[0-5] ${presentation.title}
[5-15] Проблема
[15-40] Решение
[40-55] Результат
[55-60] CTA
''';
  }

  static List<String> _generateFollowUpEmails(Presentation presentation) {
    return [
      '''
Тема: Спасибо за участие

Спасибо за интерес к "${presentation.title}".
''',
      '''
Тема: Материалы

Дополнительные материалы по теме.
''',
      '''
Тема: Следующие шаги

Как применить идеи на практике.
''',
    ];
  }

  static String _generateEngagementQuestion(String title) {
    final questions = [
      'Кто сталкивался с этим?',
      'Что вы думаете об этом?',
      'Как бы вы решили это?',
      'Где это можно применить?',
    ];

    return questions[title.length % questions.length];
  }

  static String _generateTransition(int current, int total) {
    if (current == total - 1) {
      return 'Спасибо за внимание!';
    }
    return 'Перейдём дальше...';
  }
}