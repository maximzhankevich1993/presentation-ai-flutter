import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/presentation.dart';

class ExportService {
  // Экспорт в PPTX (HTML файл)
  static void exportToPPTX({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) {
    _showLoading(context, 'Создание PPTX...');
    
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final htmlContent = _generateHtmlContent(presentation, isPremium);
        _downloadFile(htmlContent, '${_sanitizeFilename(presentation.title)}.html', 'text/html');
        
        if (context.mounted) Navigator.pop(context);
        _showSuccess(context, 'Презентация экспортирована');
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        _showError(context, 'Ошибка экспорта: $e');
      }
    });
  }

  // Экспорт в PDF через печать
  static void exportToPDF({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) {
    if (!isPremium) {
      _showError(context, 'PDF доступен только для Premium пользователей');
      return;
    }
    
    _showLoading(context, 'Создание PDF...');
    
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final htmlContent = _generateHtmlContent(presentation, isPremium);
        
        // Создаем Blob и открываем в новом окне
        final blob = html.Blob([htmlContent], 'text/html');
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        // Открываем в новом окне
        html.window.open(url, '_blank');
        
        // Освобождаем URL
        html.Url.revokeObjectUrl(url);
        
        if (context.mounted) Navigator.pop(context);
        _showSuccess(context, 'PDF открыт в новом окне. Нажмите Ctrl+P для печати и сохранения как PDF');
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        _showError(context, 'Ошибка экспорта PDF: $e');
      }
    });
  }
  
  // Генерация HTML содержимого
  static String _generateHtmlContent(Presentation presentation, bool isPremium) {
    final slidesHtml = StringBuffer();
    
    for (int i = 0; i < presentation.slides.length; i++) {
      final slide = presentation.slides[i];
      final isFirst = i == 0;
      
      slidesHtml.write('''
      <div class="slide">
        <div class="slide-number">${i + 1} / ${presentation.slides.length}</div>
        <h1 class="${isFirst ? 'title' : 'slide-title'}">${_escapeHtml(slide.title)}</h1>
        <div class="content">
          ${slide.content.map((c) => '<p>${_escapeHtml(c)}</p>').join('')}
        </div>
      </div>
      ''');
    }
    
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>${_escapeHtml(presentation.title)}</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
          font-family: 'Segoe UI', 'Roboto', 'Inter', Arial, sans-serif;
          background: ${isPremium ? '#f5f5f5' : '#1a1a1a'};
          padding: 20px;
        }
        .slide {
          background: white;
          margin: 0 auto 20px auto;
          padding: 50px;
          width: 900px;
          min-height: 600px;
          border-radius: 16px;
          box-shadow: 0 4px 20px rgba(0,0,0,0.15);
          position: relative;
          page-break-after: always;
        }
        .slide-number {
          position: absolute;
          top: 20px;
          right: 30px;
          font-size: 12px;
          color: #999;
        }
        h1 {
          font-size: 42px;
          color: #222;
          margin-bottom: 30px;
          font-weight: 700;
        }
        h1.title {
          font-size: 56px;
          text-align: center;
          margin-top: 150px;
          color: #1DB954;
        }
        .slide-title {
          font-size: 36px;
          border-left: 4px solid #1DB954;
          padding-left: 20px;
        }
        .content {
          font-size: 18px;
          line-height: 1.6;
          color: #444;
        }
        .content p {
          margin-bottom: 15px;
        }
        @media print {
          body { background: white; padding: 0; margin: 0; }
          .slide { box-shadow: none; margin: 0; border-radius: 0; min-height: auto; }
          .slide-number { display: none; }
        }
        ${!isPremium ? '.watermark { position: fixed; bottom: 20px; right: 20px; opacity: 0.3; font-size: 12px; color: #999; }' : ''}
      </style>
    </head>
    <body>
      ${slidesHtml.toString()}
      ${!isPremium ? '<div class="watermark">Created with Presentation AI</div>' : ''}
    </body>
    </html>
    ''';
  }
  
  // Скачивание файла
  static void _downloadFile(String content, String filename, String mimeType) {
    final blob = html.Blob([content], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  
  // Очистка имени файла
  static String _sanitizeFilename(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }
  
  // Экранирование HTML
  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
  
  // Показать загрузку
  static void _showLoading(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1DB954))),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
  
  // Показать успех
  static void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1DB954),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Показать ошибку
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}