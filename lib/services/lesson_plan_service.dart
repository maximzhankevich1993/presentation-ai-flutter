import '../models/lesson_plan.dart';
import 'api_service.dart';

class LessonPlanService {
  static Future<LessonPlan> generate({
    required String topic,
    required String subject,
    required String standard,
    required String grade,
    required int durationMinutes,
    required String token,
  }) async {
    try {
      // Устанавливаем токен в ApiService
      ApiService.setAuthToken(token);
      
      final data = await ApiService.generateLessonPlan(
        topic: topic,
        subject: subject,
        standard: standard,
        grade: grade,
        durationMinutes: durationMinutes,
      );
      
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
    } catch (e) {
      print('Ошибка генерации плана урока: $e');
      rethrow;
    }
  }
}