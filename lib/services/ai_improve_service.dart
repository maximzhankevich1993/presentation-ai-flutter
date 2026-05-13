import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AiImproveService {
  static const String baseUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  static Future<String> improveText(String text) async {
    try {
      // Используем ApiService.improveText напрямую
      return await ApiService.improveText(text);
    } catch (e) {
      throw Exception('Ошибка улучшения текста: $e');
    }
  }
}