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
  /// Создаёт полный пакет «под ключ»
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
      buffer.writeln('--- Слайд ${i + 1}: ${slide.title} ---');
      buffer.writeln('• Начните с: [зрительный контакт, пауза 2 сек]');
      buffer.writeln('• Ключевое сообщение: ${slide.content.first}');
      buffer.writeln('• Дополнительный пример: [подготовьте историю из опыта]');
      buffer.writeln('• Вопрос аудитории: "${_generateEngagementQuestion(slide)}"');
      buffer.writeln('• Переход к следующему: "${_generateTransition(i, presentation.slides.length)}"');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  static List<String> _generateQAScript(Presentation presentation) {
    return [
      '❓ В: Как это применить на практике?',
      '✅ О: Приведите 2-3 конкретных шага, которые аудитория может сделать сразу.',
      '',
      '❓ В: Какие есть риски?',
      '✅ О: Честно обозначьте ограничения, но подчеркните, что выигрыш перевешивает.',
      '',
      '❓ В: Сколько это стоит / занимает времени?',
      '✅ О: Дайте чёткие цифры. Если применимо — сравните с альтернативами.',
      '',
      '❓ В: Где узнать больше?',
      '✅ О: Направьте на сайт, в блог или предложите подписаться на рассылку.',
    ];
  }

  static String _generateHandout(Presentation presentation) {
    final buffer = StringBuffer();
    buffer.writeln('📄 РАЗДАТОЧНЫЙ МАТЕРИАЛ');
    buffer.writeln();
    buffer.writeln('Тема: ${presentation.title}');
    buffer.writeln('Дата: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln();
    buffer.writeln('КЛЮЧЕВЫЕ ВЫВОДЫ:');
    
    for (int i = 0; i < presentation.slides.length; i++) {
      buffer.writeln('${i + 1}. ${presentation.slides[i].title}');
      buffer.writeln('   ${presentation.slides[i].content.first}');
    }
    
    buffer.writeln();
    buffer.writeln('ДЕЙСТВИЯ ПОСЛЕ ПРЕЗЕНТАЦИИ:');
    buffer.writeln('1. Изучить дополнительные материалы');
    buffer.writeln('2. Запланировать следующий шаг');
    buffer.writeln('3. Поделиться с командой');
    
    return buffer.toString();
  }

  static String _generateSocialMediaKit(Presentation presentation) {
    return '''
📱 КОМПЛЕКТ ДЛЯ СОЦСЕТЕЙ:

LinkedIn (длинный пост):
"Только что подготовил презентацию на тему "${presentation.title}". 
Ключевые выводы: [вставьте 3 главных пункта]. А что думаете вы?"

Twitter (тред):
1/ 🧵 ${presentation.title}
2/ ${presentation.slides.first.content.first}
3/ [продолжение в том же духе]

Instagram (карусель):
Слайд 1: Обложка с заголовком
Слайд 2-5: По одному ключевому выводу
Слайд 6: Призыв к действию + ссылка
''';
  }

  static String _generateVideoScript(Presentation presentation) {
    return '''
🎬 СЦЕНАРИЙ ДЛЯ ВИДЕО (60 секунд):

[0-5 сек] Заголовок на экране + голос: "${presentation.title}"
[5-15 сек] Проблема: "${presentation.slides.first.content.first}"
[15-40 сек] Решение: 3 ключевых пункта с визуализацией
[40-55 сек] Результат: что получит зритель
[55-60 сек] Призыв к действию: "Узнайте больше по ссылке"

Музыка: энергичная, инструментальная
Текст на экране: крупный, контрастный
''';
  }

  static List<String> _generateFollowUpEmails(Presentation presentation) {
    return [
      '''
Тема: Спасибо за внимание к презентации "${presentation.title}"

Здравствуйте!

Благодарю за интерес к моей презентации. Как и обещал, отправляю ключевые материалы.

Буду рад ответить на вопросы!
''',
      '''
Тема: Дополнительные материалы по "${presentation.title}"

Здравствуйте!

Прошло несколько дней после презентации. Хочу поделиться дополнительными ресурсами по теме.
''',
      '''
Тема: Как применить идеи из "${presentation.title}" на практике

Здравствуйте!

В этом письме — конкретные шаги по внедрению того, о чём мы говорили.
''',
    ];
  }

  static String _generateEngagementQuestion(Slide slide) {
    final questions = [
      'Кто из вас сталкивался с этим?',
      'Какие ещё примеры вы можете привести?',
      'Что вас удивило в этом факте?',
      'Как бы вы решили эту проблему?',
    ];
    return questions[slide.title.length % questions.length];
  }

  static String _generateTransition(int currentIndex, int totalSlides) {
    if (currentIndex == totalSlides - 1) return 'На этом всё, спасибо за внимание!';
    return 'Теперь давайте перейдём к следующему вопросу...';
  }
}