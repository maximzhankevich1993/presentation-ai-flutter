import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/presentation.dart';

class ExportService {
  static Future<String?> exportToPPTX({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = '${presentation.title}_${DateTime.now().millisecondsSinceEpoch}.pptx';
      final file = File('${directory.path}/$fileName');
      
      final content = _generatePPTXContent(presentation, isPremium);
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], subject: presentation.title);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> exportToPDF({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    if (!isPremium) throw Exception('Экспорт в PDF доступен только в Premium');
    try {
      final directory = await getTemporaryDirectory();
      final fileName = '${presentation.title}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');
      final content = _generatePDFContent(presentation);
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], subject: presentation.title);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>?> exportToImages({
    required Presentation presentation,
    required bool isPremium,
  }) async {
    if (!isPremium) throw Exception('Экспорт в PNG доступен только в Premium');
    try {
      final directory = await getTemporaryDirectory();
      final paths = <String>[];
      for (int i = 0; i < presentation.slides.length; i++) {
        final fileName = 'slide_${i + 1}.png';
        final file = File('${directory.path}/$fileName');
        await file.writeAsString('PNG placeholder ${i + 1}');
        paths.add(file.path);
      }
      return paths;
    } catch (e) {
      return null;
    }
  }

  static String _generatePPTXContent(Presentation presentation, bool isPremium) {
    final buffer = StringBuffer();
    buffer.writeln('PPTX: ${presentation.title}');
    buffer.writeln('Слайдов: ${presentation.slides.length}');
    for (int i = 0; i < presentation.slides.length; i++) {
      final s = presentation.slides[i];
      buffer.writeln('Слайд ${i + 1}: ${s.title}');
      for (final p in s.content) { buffer.writeln('  • $p'); }
    }
    if (!isPremium) buffer.writeln('Создано в Презентатор ИИ');
    return buffer.toString();
  }

  static String _generatePDFContent(Presentation presentation) {
    final buffer = StringBuffer();
    buffer.writeln('PDF: ${presentation.title}');
    for (int i = 0; i < presentation.slides.length; i++) {
      final s = presentation.slides[i];
      buffer.writeln('=== Слайд ${i + 1} ===');
      buffer.writeln(s.title);
      for (final p in s.content) { buffer.writeln('  • $p'); }
    }
    return buffer.toString();
  }

  static Future<void> shareAsText(Presentation presentation) async {
    final buffer = StringBuffer();
    buffer.writeln('📊 ${presentation.title}');
    buffer.writeln('Слайдов: ${presentation.slides.length}');
    await Share.share(buffer.toString());
  }
}