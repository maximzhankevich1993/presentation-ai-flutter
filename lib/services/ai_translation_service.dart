import 'package:dio/dio.dart';
import 'dart:convert';

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String language;
  final List<String> culturalNotes;
  final bool wasAdapted;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.language,
    this.culturalNotes = const [],
    this.wasAdapted = false,
  });
}

class AiTranslationService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static final Dio _dio = Dio();

  /// Поддерживаемые языки с культурными особенностями
  static final Map<String, Map<String, dynamic>> _languages = {
    'ru': {'name': 'Русский', 'flag': '🇷🇺', 'emoji': '🇷🇺'},
    'en': {'name': 'English', 'flag': '🇬🇧', 'emoji': '🇬🇧'},
    'es': {'name': 'Español', 'flag': '🇪🇸', 'emoji': '🇪🇸'},
    'de': {'name': 'Deutsch', 'flag': '🇩🇪', 'emoji': '🇩🇪'},
    'fr': {'name': 'Français', 'flag': '🇫🇷', 'emoji': '🇫🇷'},
    'zh': {'name': '中文', 'flag': '🇨🇳', 'emoji': '🇨🇳'},
    'ja': {'name': '日本語', 'flag': '🇯🇵', 'emoji': '🇯🇵'},
    'ko': {'name': '한국어', 'flag': '🇰🇷', 'emoji': '🇰🇷'},
    'pt': {'name': 'Português', 'flag': '🇧🇷', 'emoji': '🇧🇷'},
    'ar': {'name': 'العربية', 'flag': '🇸🇦', 'emoji': '🇸🇦'},
    'hi': {'name': 'हिन्दी', 'flag': '🇮🇳', 'emoji': '🇮🇳'},
    'tr': {'name': 'Türkçe', 'flag': '🇹🇷', 'emoji': '🇹🇷'},
    'it': {'name': 'Italiano', 'flag': '🇮🇹', 'emoji': '🇮🇹'},
    'nl': {'name': 'Nederlands', 'flag': '🇳🇱', 'emoji': '🇳🇱'},
    'pl': {'name': 'Polski', 'flag': '🇵🇱', 'emoji': '🇵🇱'},
  };

  /// Переводит текст с культурной адаптацией
  static Future<TranslationResult> translateWithAdaptation({
    required String text,
    required String targetLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/translate',
        data: jsonEncode({
          'text': text,
          'target_language': targetLanguage,
          'adapt_culture': true,
        }),
      );
      
      if (response.statusCode == 200) {
        return TranslationResult(
          originalText: text,
          translatedText: response.data['translated'] ?? text,
          language: targetLanguage,
          culturalNotes: List<String>.from(response.data['cultural_notes'] ?? []),
          wasAdapted: response.data['was_adapted'] ?? false,
        );
      }
    } catch (e) {
      // Fallback на локальную адаптацию
    }
    
    return _localAdaptation(text, targetLanguage);
  }

  /// Локальная культурная адаптация
  static TranslationResult _localAdaptation(String text, String targetLanguage) {
    final adaptations = <String, Map<String, String>>{
      'es': {'спасибо': 'gracias', 'привет': 'hola'},
      'de': {'спасибо': 'danke', 'привет': 'hallo'},
      'fr': {'спасибо': 'merci', 'привет': 'bonjour'},
      'zh': {'спасибо': '谢谢', 'привет': '你好'},
      'ja': {'спасибо': 'ありがとう', 'привет': 'こんにちは'},
    };

    final langAdaptations = adaptations[targetLanguage] ?? {};
    var adapted = text;
    
    for (final entry in langAdaptations.entries) {
      if (adapted.toLowerCase().contains(entry.key)) {
        adapted = adapted.replaceAll(entry.key, entry.value);
      }
    }

    return TranslationResult(
      originalText: text,
      translatedText: adapted,
      language: targetLanguage,
      culturalNotes: ['Адаптировано локально'],
      wasAdapted: true,
    );
  }

  /// Возвращает список поддерживаемых языков
  static List<Map<String, dynamic>> getSupportedLanguages() {
    return _languages.entries.map((e) => {
      'code': e.key,
      ...e.value,
    }).toList();
  }
}