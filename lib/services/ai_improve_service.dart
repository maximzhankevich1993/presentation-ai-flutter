import 'package:dio/dio.dart';

class AiImproveService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static Future<String> improveText(String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/improve',
        data: {'text': text},
      );

      final data = _normalize(response.data);
      return data['improved'] ?? text;
    } catch (e) {
      return _localImprove(text);
    }
  }

  static Future<String> rephraseText(String text) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/rephrase',
        data: {'text': text},
      );

      final data = _normalize(response.data);
      return data['rephrased'] ?? text;
    } catch (e) {
      return _localRephrase(text);
    }
  }

  static Future<String> shortenText(
    String text, {
    int maxLength = 100,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/shorten',
        data: {
          'text': text,
          'max_length': maxLength,
        },
      );

      final data = _normalize(response.data);
      return data['shortened'] ??
          _safeShort(text, maxLength);
    } catch (e) {
      return _safeShort(text, maxLength);
    }
  }

  static Future<List<String>> generateTitleVariants(
    String originalTitle, {
    int count = 3,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/title-variants',
        data: {
          'title': originalTitle,
          'count': count,
        },
      );

      final data = _normalize(response.data);
      final variants = data['variants'];

      if (variants is List) {
        return variants.map((e) => e.toString()).toList();
      }

      return [originalTitle];
    } catch (e) {
      return _localTitleVariants(originalTitle, count);
    }
  }

  // ===== SAFE HELPERS =====

  static Map<String, dynamic> _normalize(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  static String _safeShort(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trim()}...';
  }

  // ===== LOCAL FALLBACKS =====

  static String _localImprove(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _localRephrase(String text) {
    return text;
  }

  static List<String> _localTitleVariants(
    String title,
    int count,
  ) {
    return [
      title,
      '$title — ключевые аспекты',
      'Почему важно: $title',
    ].take(count).toList();
  }
}