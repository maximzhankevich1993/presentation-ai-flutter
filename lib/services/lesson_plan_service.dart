import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lesson_plan.dart';
import '../providers/user_provider.dart';

class LessonPlanService {
  static const String _apiUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  static Future<LessonPlan> generate({
    required String topic,
    required String subject,
    required String standard,
    required String grade,
    required int durationMinutes,
    required String token, // Добавляем токен авторизации
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/lesson-plan/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'topic': topic,
          'subject': subject,
          'standard': standard,
          'grade': grade,
          'durationMinutes': durationMinutes,
          'includeAssessments': true,
          'includeDifferentiation': true,
          'includeHomework': true,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LessonPlan(
          topic: data['topic'],
          subject: data['subject'],
          grade: data['grade'],
          standard: data['standard'],
          duration: data['duration'],
          objectives: List<String>.from(data['objectives']),
          stages: (data['stages'] as List)
              .map((stage) => LessonStage(
                    name: stage['name'],
                    minutes: stage['minutes'],
                    teacherActions: stage['teacherActions'],
                    studentActions: stage['studentActions'],
                    resources: stage['resources'],
                  ))
              .toList(),
          homework: data['homework'],
          assessment: data['assessment'],
          differentiation: List<String>.from(data['differentiation']),
        );
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка генерации плана урока: $e');
      // Если API не готов, возвращаем заглушку
      return _getMockLessonPlan(topic, subject, standard, grade, durationMinutes);
    }
  }
  
  // Заглушка на случай, если бэкенд ещё не готов
  static LessonPlan _getMockLessonPlan(
    String topic,
    String subject,
    String standard,
    String grade,
    int durationMinutes,
  ) {
    return LessonPlan(
      topic: topic,
      subject: subject,
      grade: grade,
      standard: standard,
      duration: '$durationMinutes минут',
      objectives: [
        'Понять основные концепции темы "$topic"',
        'Научиться применять знания на практике',
        'Развить критическое мышление',
      ],
      stages: [
        LessonStage(
          name: 'Организационный момент',
          minutes: 5,
          teacherActions: 'Приветствие, проверка готовности',
          studentActions: 'Подготовка к уроку',
          resources: 'Презентация',
        ),
        LessonStage(
          name: 'Изучение нового материала',
          minutes: 20,
          teacherActions: 'Объяснение темы',
          studentActions: 'Конспектирование',
          resources: 'Учебник, доска',
        ),
        LessonStage(
          name: 'Закрепление',
          minutes: 15,
          teacherActions: 'Практические задания',
          studentActions: 'Выполнение упражнений',
          resources: 'Рабочие листы',
        ),
        LessonStage(
          name: 'Итоги',
          minutes: 5,
          teacherActions: 'Подведение итогов',
          studentActions: 'Рефлексия',
          resources: 'Дневники',
        ),
      ],
      homework: 'Повторить пройденный материал',
      assessment: 'Фронтальный опрос',
      differentiation: ['Индивидуальные задания'],
    );
  }
}