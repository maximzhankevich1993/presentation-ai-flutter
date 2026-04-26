import 'package:dio/dio.dart';
import 'dart:convert';

class AiImproveService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// Улучшает текст, делая его более профессиональным
  static Future<String> improveText(String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/improve',
        data: jsonEncode({'text': text}),
      );
      
      if (response.statusCode == 200) {
        return response.data['improved'] ?? text;
      }
      return text;
    } catch (e) {
      return _localImprove(text);
    }
  }

  /// Перефразирует текст другими словами
  static Future<String> rephraseText(String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/rephrase',
        data: jsonEncode({'text': text}),
      );
      
      if (response.statusCode == 200) {
        return response.data['rephrased'] ?? text;
      }
      return text;
    } catch (e) {
      return _localRephrase(text);
    }
  }

  /// Сокращает текст до заданной длины
  static Future<String> shortenText(String text, {int maxLength = 100}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/shorten',
        data: jsonEncode({'text': text, 'max_length': maxLength}),
      );
      
      if (response.statusCode == 200) {
        return response.data['shortened'] ?? text;
      }
      return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
    } catch (e) {
      return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
    }
  }

  /// Генерирует варианты заголовков для слайда
  static Future<List<String>> generateTitleVariants(String originalTitle, {int count = 3}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/title-variants',
        data: jsonEncode({'title': originalTitle, 'count': count}),
      );
      
      if (response.statusCode == 200) {
        final variants = response.data['variants'] as List?;
        return variants?.cast<String>() ?? [originalTitle];
      }
      return [originalTitle];
    } catch (e) {
      return _localTitleVariants(originalTitle, count);
    }
  }

  // ===== ЛОКАЛЬНЫЕ МЕТОДЫ (если API недоступен) =====

  static String _localImprove(String text) {
    // Убираем повторяющиеся пробелы
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _localRephrase(String text) {
    return text;
  }

  static List<String> _localTitleVariants(String title, int count) {
    return [
      title,
      '$title — ключевые аспекты',
      'Почему $title важен',
    ];
  }
}