import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:convert';

class CompetitorInsight {
  final String topic;
  final String uniqueAngle;
  final List<String> whatOthersSay;
  final List<String> gaps;
  final List<String> suggestions;

  const CompetitorInsight({
    required this.topic,
    required this.uniqueAngle,
    required this.whatOthersSay,
    required this.gaps,
    required this.suggestions,
  });
}

class CompetitorAnalysisService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static final Dio _dio = Dio();
  static final Random _random = Random();

  static Future<CompetitorInsight> analyzeTopic(String topic) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/analyze-competitors',
        data: {'topic': topic},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200) {
        final data = _normalizeResponse(response.data);

        return CompetitorInsight(
          topic: topic,
          uniqueAngle: data['unique_angle'] ?? '',
          whatOthersSay:
              List<String>.from(data['what_others_say'] ?? []),
          gaps: List<String>.from(data['gaps'] ?? []),
          suggestions:
              List<String>.from(data['suggestions'] ?? []),
        );
      }
    } catch (e) {
      // fallback
    }

    return _localAnalysis(topic);
  }

  /// Защита от String JSON или Map
  static Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return {};
      }
    }
    return {};
  }

  static CompetitorInsight _localAnalysis(String topic) {
    final angles = [
      'Все говорят о пользе — давайте разберём риски и ограничения',
      'Вместо теории — практические кейсы с цифрами',
      'Взгляд с точки зрения пользователя, а не разработчика',
      'Сравнение старого и нового подхода: что изменилось за 5 лет',
      'Неочевидные применения, о которых молчат конкуренты',
    ];

    final whatOthersSay = [
      'Большинство презентаций фокусируются на определениях',
      'Конкуренты часто упускают статистику и цифры',
      'Обычно не хватает конкретных примеров применения',
    ];

    final gaps = [
      'Нет сравнения с альтернативами',
      'Отсутствуют данные последних исследований',
      'Не раскрыта экономическая сторона вопроса',
    ];

    final suggestions = [
      'Начните с неожиданной статистики',
      'Добавьте слайд с разбором мифов',
      'Закончите конкретным призывом к действию',
    ];

    return CompetitorInsight(
      topic: topic,
      uniqueAngle: angles[_random.nextInt(angles.length)],
      whatOthersSay: whatOthersSay,
      gaps: gaps,
      suggestions: suggestions,
    );
  }
}