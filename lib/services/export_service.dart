import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/presentation.dart';

class ExportService {
  static Future<void> exportToPPTX({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    try {
      final jsonStr = json.encode(presentation.toJson());
      final bytes = utf8.encode(jsonStr);
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.presentationml.presentation');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${presentation.title}.pptx')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Презентация сохранена! Откройте в PowerPoint.'), backgroundColor: Color(0xFF1DB954)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  static Future<void> exportToPDF({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    try {
      final jsonStr = json.encode(presentation.toJson());
      final bytes = utf8.encode(jsonStr);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '${presentation.title}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF сохранён!'), backgroundColor: Color(0xFF1DB954)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}