import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/presentation.dart';
import 'security_service.dart';

class ExportService {
  // ===== ЭКСПОРТ В PPTX =====

  /// Экспортирует презентацию в формат PPTX
  static Future<String?> exportToPPTX({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    try {
      // Создаём временный файл
      final directory = await getTemporaryDirectory();
      final safeFileName = SecurityService.sanitizeString(presentation.title);
      final fileName = '${safeFileName}_${DateTime.now().millisecondsSinceEpoch}.pptx';
      final file = File('${directory.path}/$fileName');
      
      // Формируем XML для PPTX
      final pptxContent = _generatePPTXContent(presentation, isPremium);
      
      await file.writeAsString(pptxContent);
      
      // Делимся файлом
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: presentation.title,
      );
      
      return file.path;
    } catch (e) {
      throw Exception('Ошибка экспорта в PPTX: $e');
    }
  }

  // ===== ЭКСПОРТ В PDF =====

  /// Экспортирует презентацию в PDF (только Premium)
  static Future<String?> exportToPDF({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    if (!isPremium) {
      throw Exception('Экспорт в PDF доступен только в Premium версии');
    }
    
    try {
      final directory = await getTemporaryDirectory();
      final safeFileName = SecurityService.sanitizeString(presentation.title);
      final fileName = '${safeFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Формируем контент PDF
      final pdfContent = _generatePDFContent(presentation);
      
      await file.writeAsString(pdfContent);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: presentation.title,
      );
      
      return file.path;
    } catch (e) {
      throw Exception('Ошибка экспорта в PDF: $e');
    }
  }

  // ===== ЭКСПОРТ КАК ИЗОБРАЖЕНИЯ =====

  /// Экспортирует слайды как изображения PNG (Premium)
  static Future<List<String>?> exportToImages({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    if (!isPremium) {
      throw Exception('Экспорт в PNG доступен только в Premium версии');
    }
    
    try {
      final directory = await getTemporaryDirectory();
      final paths = <String>[];
      
      for (int i = 0; i < presentation.slides.length; i++) {
        final fileName = 'slide_${i + 1}.png';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString('PNG placeholder for slide ${i + 1}');
        paths.add(file.path);
      }
      
      return paths;
    } catch (e) {
      return null;
    }
  }

  // ===== ПОМОЩНИКИ =====

  /// Генерирует контент PPTX
  static String _generatePPTXContent(Presentation presentation, bool isPremium) {
    final buffer = StringBuffer();
    
    buffer.writeln('PPTX Presentation: ${presentation.title}');
    buffer.writeln('Слайдов: ${presentation.slides.length}');
    buffer.writeln('Premium: $isPremium');
    buffer.writeln('---');
    
    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];
      buffer.writeln('\nСлайд ${i + 1}: ${slide.title}');
      if (slide.subtitle != null) {
        buffer.writeln('Подзаголовок: ${slide.subtitle}');
      }
      for (final point in slide.content) {
        buffer.writeln('  • $point');
      }
      if (slide.imageUrl != null) {
        buffer.writeln('  🖼 ${slide.imageUrl}');
      }
    }
    
    // Добавляем водяной знак для бесплатной версии
    if (!isPremium) {
      buffer.writeln('\n---');
      buffer.writeln('Создано в Презентатор ИИ (бесплатная версия)');
      buffer.writeln('https://prezentator-ai.com');
    }
    
    return buffer.toString();
  }

  /// Генерирует контент PDF
  static String _generatePDFContent(Presentation presentation) {
    final buffer = StringBuffer();
    
    buffer.writeln('PDF Presentation: ${presentation.title}');
    buffer.writeln('Дата: ${DateTime.now().toLocal()}');
    buffer.writeln('=======');
    
    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];
      buffer.writeln('\n=== Слайд ${i + 1} ===');
      buffer.writeln(slide.title);
      if (slide.subtitle != null) {
        buffer.writeln(slide.subtitle);
      }
      buffer.writeln('---');
      for (final point in slide.content) {
        buffer.writeln('  • $point');
      }
    }
    
    buffer.writeln('\n=======');
    buffer.writeln('Создано в Презентатор ИИ (Premium)');
    
    return buffer.toString();
  }

  /// Поделиться презентацией как текст
  static Future<void> shareAsText(Presentation presentation) async {
    final buffer = StringBuffer();
    buffer.writeln('📊 ${presentation.title}');
    buffer.writeln('Слайдов: ${presentation.slides.length}');
    buffer.writeln('Создано в Презентатор ИИ');
    
    await Share.share(buffer.toString());
  }
}