import '../models/presentation.dart';

class GeneratedMaterials {
  final String pdfDocument;
  final String linkedinPost;
  final String twitterThread;
  final String emailNewsletter;
  final String blogPost;

  const GeneratedMaterials({
    required this.pdfDocument,
    required this.linkedinPost,
    required this.twitterThread,
    required this.emailNewsletter,
    required this.blogPost,
  });
}

class MaterialsGeneratorService {
  /// Генерирует все материалы из презентации
  static GeneratedMaterials generateAll(Presentation presentation) {
    return GeneratedMaterials(
      pdfDocument: _generatePDFDocument(presentation),
      linkedinPost: _generateLinkedInPost(presentation),
      twitterThread: _generateTwitterThread(presentation),
      emailNewsletter: _generateEmailNewsletter(presentation),
      blogPost: _generateBlogPost(presentation),
    );
  }

  static String _generatePDFDocument(Presentation presentation) {
    final buffer = StringBuffer();
    buffer.writeln('=' * 60);
    buffer.writeln('РАЗДАТОЧНЫЙ МАТЕРИАЛ');
    buffer.writeln('=' * 60);
    buffer.writeln();
    buffer.writeln('Тема: ${presentation.title}');
    buffer.writeln('Дата: ${DateTime.now().toLocal().toString().split(' ')[0]}');
    buffer.writeln('Слайдов: ${presentation.slides.length}');
    buffer.writeln();
    
    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];
      buffer.writeln('--- Слайд ${i + 1}: ${slide.title} ---');
      for (final point in slide.content) {
        buffer.writeln('  • $point');
      }
      buffer.writeln();
    }
    
    buffer.writeln('=' * 60);
    buffer.writeln('Создано в Презентатор ИИ');
    buffer.writeln('=' * 60);
    
    return buffer.toString();
  }

  static String _generateLinkedInPost(Presentation presentation) {
    final firstSlide = presentation.slides.first;
    final keyPoints = presentation.slides.take(3).map((s) => s.content.first).toList();
    
    return '''
📊 ${presentation.title}

Только что закончил презентацию на тему "${presentation.title}". Делюсь ключевыми выводами:

🔥 Главные инсайты:
${keyPoints.map((p) => '• $p').join('\n')}

💡 Мой главный вывод:
${firstSlide.content.last}

А что вы думаете по этой теме? Делитесь в комментариях! 👇

#презентация #бизнес #AI #продуктивность
''';
  }

  static String _generateTwitterThread(Presentation presentation) {
    final tweets = <String>[];
    
    tweets.add('🧵 Тред: ${presentation.title}\n\nКраткая выжимка моей новой презентации 👇');
    
    for (int i = 0; i < presentation.slides.length && i < 7; i++) {
      final slide = presentation.slides[i];
      final point = slide.content.isNotEmpty ? slide.content.first : slide.title;
      tweets.add('${i + 2}/. ${slide.title}: $point');
    }
    
    tweets.add('Конец треда! Полная презентация доступна по ссылке 🔗\n\nСоздано в @PresentationAI ✨');
    
    return tweets.join('\n\n');
  }

  static String _generateEmailNewsletter(Presentation presentation) {
    return '''
Тема: ${presentation.title} — главные выводы

Здравствуйте!

Мы подготовили для вас краткую выжимку презентации "${presentation.title}".

📌 Ключевые моменты:
${presentation.slides.take(5).map((s) => '• ${s.title}').join('\n')}

📊 Интересные факты:
${presentation.slides.expand((s) => s.content).take(3).map((c) => '• $c').join('\n')}

Хотите увидеть полную версию? Нажмите на ссылку ниже.

С уважением,
Команда Презентатор ИИ
''';
  }

  static String _generateBlogPost(Presentation presentation) {
    return '''
# ${presentation.title}: Полное руководство

*Опубликовано: ${DateTime.now().toLocal().toString().split(' ')[0]}*

## Введение
${presentation.slides.first.content.join('\n')}

${presentation.slides.skip(1).take(presentation.slides.length - 2).map((slide) => '''
## ${slide.title}
${slide.content.map((c) => '- $c').join('\n')}
''').join('\n')}

## Заключение
${presentation.slides.last.content.join('\n')}

---
*Эта статья автоматически создана на основе презентации с помощью Презентатор ИИ.*
''';
  }
}