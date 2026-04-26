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

  /// Анализирует тему и предлагает уникальный угол
  static Future<CompetitorInsight> analyzeTopic(String topic) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/analyze-competitors',
        data: jsonEncode({'topic': topic}),
      );
      
      if (response.statusCode == 200) {
        return CompetitorInsight(
          topic: topic,
          uniqueAngle: response.data['unique_angle'] ?? '',
          whatOthersSay: List<String>.from(response.data['what_others_say'] ?? []),
          gaps: List<String>.from(response.data['gaps'] ?? []),
          suggestions: List<String>.from(response.data['suggestions'] ?? []),
        );
      }
    } catch (e) {
      // Fallback на локальную генерацию
    }
    
    return _localAnalysis(topic);
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