import 'dart:convert';
import 'dart:html' as html; // Только для web
import 'package:flutter/material.dart';
import 'package:file_saver/file_saver.dart';
import '../models/presentation.dart';

class ExportService {
  static Future<void> exportToPPTX({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    try {
      // Для web — скачиваем через браузер
      final bytes = utf8.encode(json.encode(presentation.toJson()));
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.presentationml.presentation');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${presentation.title}.pptx')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Презентация сохранена!'), backgroundColor: Color(0xFF1DB954)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<void> exportToPDF({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    // Аналогично PPTX
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF экспорт в разработке'), backgroundColor: Color(0xFFFFD700)),
    );
  }
}