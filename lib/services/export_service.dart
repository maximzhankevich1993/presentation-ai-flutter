import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/presentation.dart';
import 'api_service.dart';

class ExportService {
  static Future<void> exportToPPTX({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    _showLoading(context, 'Создание PPTX...');
    
    try {
      final result = await ApiService.exportToPPTX(presentation.toJson());
      
      if (context.mounted) Navigator.pop(context);
      
      if (result.containsKey('url')) {
        _downloadFromUrl(result['url'], '${presentation.title}.pptx');
      } else if (result.containsKey('data')) {
        _downloadFromBase64(result['data'], '${presentation.title}.pptx');
      } else {
        throw Exception('Некорректный ответ сервера');
      }
      
      _showSuccess(context, 'PPTX успешно создан');
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError(context, 'Ошибка экспорта PPTX: $e');
    }
  }

  static Future<void> exportToPDF({
    required BuildContext context,
    required Presentation presentation,
    required bool isPremium,
  }) async {
    if (!isPremium) {
      _showError(context, 'PDF доступен только для Premium пользователей');
      return;
    }
    
    _showLoading(context, 'Создание PDF...');
    
    try {
      final result = await ApiService.exportToPDF(presentation.toJson());
      
      if (context.mounted) Navigator.pop(context);
      
      if (result.containsKey('url')) {
        _downloadFromUrl(result['url'], '${presentation.title}.pdf');
      } else if (result.containsKey('data')) {
        _downloadFromBase64(result['data'], '${presentation.title}.pdf');
      } else {
        throw Exception('Некорректный ответ сервера');
      }
      
      _showSuccess(context, 'PDF успешно создан');
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      _showError(context, 'Ошибка экспорта PDF: $e');
    }
  }
  
  static void _downloadFromUrl(String url, String filename) {
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
  }
  
  static void _downloadFromBase64(String base64Data, String filename) {
    String rawData = base64Data;
    if (rawData.contains(',')) {
      rawData = rawData.split(',').last;
    }
    final bytes = base64Decode(rawData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  
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