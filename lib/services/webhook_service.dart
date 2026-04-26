import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebhookService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  // ===== WEBHOOK ДЛЯ ЛЕНДИНГА =====

  /// Принимает тему с лендинга и запускает генерацию
  static Future<Map<String, dynamic>> handleLandingRequest(String topic) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/webhook/generate',
        data: jsonEncode({
          'topic': topic,
          'source': 'landing',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'presentation_id': response.data['presentation_id'],
          'redirect_url': '/editor/${response.data['presentation_id']}',
        };
      }
      
      return {'success': false, 'error': 'Ошибка сервера'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Отправляет аналитику с лендинга
  static Future<void> sendAnalytics(String event, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '$_baseUrl/analytics/event',
        data: jsonEncode({
          'event': event,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      // Игнорируем ошибки аналитики
    }
  }

  // ===== СИСТЕМА УВЕДОМЛЕНИЙ =====

  /// Подписывает email на рассылку
  static Future<bool> subscribeToNewsletter(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/newsletter/subscribe',
        data: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Отписывает email от рассылки
  static Future<bool> unsubscribeFromNewsletter(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/newsletter/unsubscribe',
        data: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===== ОБРАТНАЯ СВЯЗЬ =====

  /// Отправляет отзыв пользователя
  static Future<bool> sendFeedback(String email, String message) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/feedback',
        data: jsonEncode({
          'email': email,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===== TRACKING =====

  /// Отслеживает использование бесплатных генераций
  static Future<void> trackFreeGeneration(String deviceId) async {
    try {
      await _dio.post(
        '$_baseUrl/track/free-generation',
        data: jsonEncode({
          'device_id': deviceId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      // Сохраняем локально для отправки позже
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList('pending_tracking') ?? [];
      pending.add(jsonEncode({
        'type': 'free_generation',
        'device_id': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      await prefs.setStringList('pending_tracking', pending);
    }
  }

  /// Синхронизирует отложенные события
  static Future<void> syncPendingEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList('pending_tracking') ?? [];
    
    if (pending.isEmpty) return;
    
    final List<String> failed = [];
    
    for (final event in pending) {
      try {
        await _dio.post(
          '$_baseUrl/track/batch',
          data: jsonEncode({'events': [jsonDecode(event)]}),
        );
      } catch (e) {
        failed.add(event);
      }
    }
    
    await prefs.setStringList('pending_tracking', failed);
  }
}