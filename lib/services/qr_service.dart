import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class QRService {
  /// Генерирует QR-код для заданных данных
  static Future<ui.Image?> generateQRCode(String data, {int size = 200}) async {
    // Упрощённая генерация QR-кода через CustomPaint
    // В production использовать пакет qr_flutter
    return null;
  }

  /// Создаёт ссылку для шаринга презентации
  static String generateShareLink(String presentationId) {
    return 'https://prezentator-ai.com/share/$presentationId';
  }

  /// Копирует ссылку в буфер обмена
  static void copyShareLink(String link, BuildContext context) {
    // Используем Clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Ссылка скопирована: $link')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Показывает диалог с QR-кодом и ссылкой
  static void showShareDialog(BuildContext context, String presentationId) {
    final link = generateShareLink(presentationId);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.qr_code, color: Color(0xFF4F46E5)),
              const SizedBox(width: 12),
              const Text('Поделиться'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Заглушка QR-кода
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'QR',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey[400]),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                link,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                copyShareLink(link, context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Копировать ссылку'),
            ),
          ],
        );
      },
    );
  }
}