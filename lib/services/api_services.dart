import 'dart:convert';
import 'package:dio/dio.dart';

class Presentation {
  final String id;
  final String title;
  final List<Slide> slides;
  final DateTime createdAt;

  Presentation({
    required this.id,
    required this.title,
    required this.slides,
    required this.createdAt,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    final slidesList = (json['slides'] as List).map((s) => Slide.fromJson(s)).toList();
    
    return Presentation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Без названия',
      slides: slidesList,
      createdAt: DateTime.now(),
    );
  }
}

class Slide {
  final String title;
  final String? subtitle;
  final List<String> content;
  final String? imageUrl;
  final String? imageKeywords;
  final Map<String, dynamic>? background;

  Slide({
    required this.title,
    this.subtitle,
    required this.content,
    this.imageUrl,
    this.imageKeywords,
    this.background,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      content: List<String>.from(json['content'] ?? []),
      imageUrl: json['image_url'],
      imageKeywords: json['image_keywords'],
      background: json['background'],
    );
  }
}

class ApiService {
  // Замени на URL своего бэкенда
  static const String _baseUrl = 'http://localhost:3000/api';
  
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// Генерация презентации с картинками
  static Future<Presentation> generatePresentation(
    String topic, {
    int maxSlides = 10,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/generate-with-images',
        data: jsonEncode({
          'topic': topic,
          'maxSlides': maxSlides,
        }),
      );
      
      if (response.statusCode == 200) {
        return Presentation.fromJson(response.data);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Превышено время ожидания. Проверьте подключение к серверу.');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('Не удалось подключиться к серверу. Убедитесь, что бэкенд запущен на $_baseUrl');
      }
      throw Exception('Ошибка сети: ${e.message}');
    } catch (e) {
      throw Exception('Неизвестная ошибка: $e');
    }
  }

  /// Генерация только структуры (без картинок)
  static Future<Presentation> generateStructure(
    String topic, {
    int maxSlides = 10,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/generate',
        data: jsonEncode({
          'topic': topic,
          'maxSlides': maxSlides,
        }),
      );
      
      if (response.statusCode == 200) {
        return Presentation.fromJson(response.data);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка генерации: $e');
    }
  }

  /// Поиск картинок по ключевым словам
  static Future<List<String>> searchImages(String keywords, {int count = 5}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/images/search',
        data: jsonEncode({
          'keywords': keywords,
          'count': count,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        return List<String>.from(data['images'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Проверка соединения с сервером
  static Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}