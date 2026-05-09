import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String _baseUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  /// Генерация презентации по теме
  static Future<Map<String, dynamic>> generatePresentation(String topic, {int maxSlides = 10}) async {
    try {
      final response = await _dio.post('$_baseUrl/generate', data: jsonEncode({
        'topic': topic,
        'maxSlides': maxSlides,
      }));
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) throw Exception('Превышено время ожидания');
      if (e.type == DioExceptionType.connectionError) throw Exception('Не удалось подключиться к серверу');
      throw Exception('Ошибка сети: ${e.message}');
    }
  }

  /// Генерация из текста (диплом, статья)
  static Future<Map<String, dynamic>> generateFromText(String text, {String? title, int maxSlides = 10}) async {
    final response = await _dio.post('$_baseUrl/generate-from-text', data: jsonEncode({
      'text': text,
      'title': title ?? 'Презентация',
      'maxSlides': maxSlides,
    }));
    return response.data;
  }

  /// Улучшение текста
  static Future<String> improveText(String text) async {
    try {
      final response = await _dio.post('$_baseUrl/improve', data: jsonEncode({'text': text}));
      return response.data['improved'] ?? text;
    } catch (e) {
      return text;
    }
  }

  /// Проверка здоровья сервера
  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}