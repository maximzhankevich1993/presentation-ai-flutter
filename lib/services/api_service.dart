import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3001/api';
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  /// Генерация по теме
  static Future<Map<String, dynamic>> generatePresentation(String topic, {int maxSlides = 10}) async {
    final response = await _dio.post('$_baseUrl/generate', data: jsonEncode({'topic': topic, 'maxSlides': maxSlides}));
    return response.data;
  }

  /// Генерация по тексту (диплом, статья)
  static Future<Map<String, dynamic>> generateFromText(String text, {String? title, int maxSlides = 10}) async {
    final response = await _dio.post('$_baseUrl/generate-from-text', data: jsonEncode({
      'text': text,
      'title': title ?? 'Презентация',
      'maxSlides': maxSlides,
    }));
    return response.data;
  }

  /// Генерация бренд-кита из логотипа
  static Future<Map<String, dynamic>> generateBrandKit(String logoUrl) async {
    final response = await _dio.post('$_baseUrl/brand-kit', data: jsonEncode({'logo_url': logoUrl}));
    return response.data;
  }

  static Future<String> improveText(String text) async => text;
  static Future<bool> checkHealth() async {
    try { final r = await _dio.get('$_baseUrl/health'); return r.statusCode == 200; } catch (e) { return false; }
  }
}