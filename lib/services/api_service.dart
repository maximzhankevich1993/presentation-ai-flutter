import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api';
  
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<dynamic> generatePresentation(String topic, {int maxSlides = 10}) async {
    try {
      final response = await _dio.post('$_baseUrl/generate', data: jsonEncode({
        'topic': topic,
        'maxSlides': maxSlides,
      }));
      if (response.statusCode == 200) return response.data;
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) throw Exception('Превышено время ожидания');
      if (e.type == DioExceptionType.connectionError) throw Exception('Не удалось подключиться к серверу');
      throw Exception('Ошибка сети: ${e.message}');
    }
  }

  static Future<String> improveText(String text) async {
    try {
      final response = await _dio.post('$_baseUrl/improve', data: jsonEncode({'text': text}));
      if (response.statusCode == 200) return response.data['improved'] ?? text;
      return text;
    } catch (e) {
      return text;
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}