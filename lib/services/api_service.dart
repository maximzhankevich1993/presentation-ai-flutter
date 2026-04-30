import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  // Генерация презентации по теме
  static Future<dynamic> generatePresentation(String topic, {int maxSlides = 10}) async {
    try {
      final response = await _dio.post('$_baseUrl/generate', data: jsonEncode({
        'topic': topic,
        'maxSlides': maxSlides,
      }));

      if (response.statusCode == 200) {
        return response.data; // Возвращаем данные из ответа
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Обработка различных типов исключений
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Превышено время ожидания подключения');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Не удалось подключиться к серверу');
      }
      throw Exception('Ошибка сети: ${e.message}');
    }
  }

  // Улучшение текста (например, для улучшения качества)
  static Future<String> improveText(String text) async {
    try {
      final response = await _dio.post('$_baseUrl/improve', data: jsonEncode({'text': text}));

      if (response.statusCode == 200) {
        return response.data['improved'] ?? text; // Возвращаем улучшенный текст
      }
      return text;
    } catch (e) {
      // Если произошла ошибка, возвращаем исходный текст
      return text;
    }
  }

  // Проверка доступности API
  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      // Если произошла ошибка при запросе, возвращаем false
      return false;
    }
  }
}