import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebhookService {
  static const String _baseUrl = 'http://localhost:3000/api';

  static const String _pendingKey = 'pending_tracking';
  static const int _maxPendingEvents = 100;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // ===== WEBHOOK ДЛЯ ЛЕНДИНГА =====

  static Future<Map<String, dynamic>> handleLandingRequest(String topic) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/webhook/generate',
        data: {
          'topic': topic.trim(),
          'source': 'landing',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data is Map) {
        final id = data['presentation_id'];

        if (id == null) {
          return {'success': false, 'error': 'Invalid response'};
        }

        return {
          'success': true,
          'presentation_id': id,
          'redirect_url': '/editor/$id',
        };
      }

      return {'success': false, 'error': 'Ошибка сервера'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> sendAnalytics(
      String event, Map<String, dynamic> data) async {
    try {
      await _dio.post(
        '$_baseUrl/analytics/event',
        data: {
          'event': event,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {
      // игнорируем
    }
  }

  // ===== NEWSLETTER =====

  static Future<bool> subscribeToNewsletter(String email) async {
    final normalized = email.trim().toLowerCase();

    try {
      final response = await _dio.post(
        '$_baseUrl/newsletter/subscribe',
        data: {'email': normalized},
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> unsubscribeFromNewsletter(String email) async {
    final normalized = email.trim().toLowerCase();

    try {
      final response = await _dio.post(
        '$_baseUrl/newsletter/unsubscribe',
        data: {'email': normalized},
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== FEEDBACK =====

  static Future<bool> sendFeedback(String email, String message) async {
    final normalized = email.trim().toLowerCase();

    try {
      final response = await _dio.post(
        '$_baseUrl/feedback',
        data: {
          'email': normalized,
          'message': message.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ===== TRACKING =====

  static Future<void> trackFreeGeneration(String deviceId) async {
    final event = {
      'type': 'free_generation',
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      await _dio.post(
        '$_baseUrl/track/free-generation',
        data: event,
      );
    } catch (_) {
      await _savePendingEvent(event);
    }
  }

  static Future<void> _savePendingEvent(Map<String, dynamic> event) async {
    final prefs = await SharedPreferences.getInstance();

    final pending = prefs.getStringList(_pendingKey) ?? [];

    // ограничиваем размер очереди
    if (pending.length >= _maxPendingEvents) {
      pending.removeAt(0);
    }

    pending.add(jsonEncode(event));

    await prefs.setStringList(_pendingKey, pending);
  }

  static Future<void> syncPendingEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getStringList(_pendingKey) ?? [];

    if (pending.isEmpty) return;

    final List<String> failed = [];

    for (final eventStr in pending) {
      try {
        final decoded = jsonDecode(eventStr);

        await _dio.post(
          '$_baseUrl/track/batch',
          data: {'events': [decoded]},
        );
      } catch (_) {
        failed.add(eventStr);
      }
    }

    await prefs.setStringList(_pendingKey, failed);
  }
}