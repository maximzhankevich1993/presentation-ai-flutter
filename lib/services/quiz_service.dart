import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correct': correctIndex,
    'explanation': explanation,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct'],
      explanation: json['explanation'] ?? '',
    );
  }
}

class Quiz {
  final String title;
  final List<QuizQuestion> questions;
  final String difficulty;
  final int timeLimitMinutes;

  const Quiz({
    required this.title,
    required this.questions,
    required this.difficulty,
    required this.timeLimitMinutes,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'questions': questions.map((q) => q.toJson()).toList(),
    'difficulty': difficulty,
    'timeLimitMinutes': timeLimitMinutes,
  };

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      difficulty: json['difficulty'],
      timeLimitMinutes: json['timeLimitMinutes'],
    );
  }

  String get answerKey {
    final buffer = StringBuffer();
    buffer.writeln('КЛЮЧ К ТЕСТУ: $title');
    buffer.writeln('');
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final correctLetter = String.fromCharCode(65 + q.correctIndex);
      buffer.writeln('${i + 1}. $correctLetter) ${q.options[q.correctIndex]}');
    }
    buffer.writeln('');
    buffer.writeln('Критерии оценивания:');
    final total = questions.length;
    buffer.writeln('"5" — ${(total * 0.85).ceil()}+ правильных');
    buffer.writeln('"4" — ${(total * 0.65).ceil()}-${(total * 0.84).ceil()} правильных');
    buffer.writeln('"3" — ${(total * 0.45).ceil()}-${(total * 0.64).ceil()} правильных');
    return buffer.toString();
  }
}

class QuizService {
  static const String _baseUrl = 'https://presentation-ai-backend.onrender.com/api';
  
  /// Генерация теста из презентации через AI
  static Future<Quiz> generateFromPresentation({
    required String presentationTitle,
    required List<String> slideContents,
    required String? token,
    int questionCount = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quiz/from-presentation'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': presentationTitle,
          'slides': slideContents,
          'questionCount': questionCount,
        }),
      );
      
      if (response.statusCode == 200) {
        return Quiz.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        throw Exception('Требуется авторизация');
      } else if (response.statusCode == 402) {
        throw Exception('Бесплатные генерации закончились');
      } else if (response.statusCode == 429) {
        throw Exception('Превышен лимит генераций');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка генерации теста');
      }
    } catch (e) {
      print('Error generating quiz from presentation: $e');
      rethrow;
    }
  }
  
  /// Генерация теста по теме через YandexGPT
  static Future<Quiz> generateFromTopic({
    required String topic,
    required String? textbook,
    required String grade,
    required String? token,
    int questionCount = 5,
    String? countryCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quiz/generate'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'topic': topic,
          'textbook': textbook,
          'grade': grade,
          'questionCount': questionCount,
          'countryCode': countryCode,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final questions = (data['questions'] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList();
        
        return Quiz(
          title: 'Тест: $topic',
          questions: questions,
          difficulty: data['difficulty'] ?? 'medium',
          timeLimitMinutes: data['timeLimitMinutes'] ?? questionCount * 2,
        );
      } else if (response.statusCode == 401) {
        throw Exception('Требуется авторизация');
      } else if (response.statusCode == 402) {
        throw Exception('Бесплатные генерации закончились');
      } else if (response.statusCode == 429) {
        throw Exception('Превышен лимит генераций');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Ошибка генерации теста');
      }
    } catch (e) {
      print('Error generating quiz from topic: $e');
      rethrow;
    }
  }

  /// Экспорт теста + ответов для Word
  static String exportToWord(Quiz quiz, {bool includeAnswers = true}) {
    final buffer = StringBuffer();
    
    buffer.writeln('ТЕСТ');
    buffer.writeln(quiz.title);
    buffer.writeln('Уровень: ${quiz.difficulty} | Время: ${quiz.timeLimitMinutes} мин');
    buffer.writeln('');
    buffer.writeln('ФИО: ____________________  Дата: __________  Класс: __________');
    buffer.writeln('');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    for (int i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      buffer.writeln('${i + 1}. ${q.question}');
      for (int j = 0; j < q.options.length; j++) {
        buffer.writeln('   ${_letter(j)}) ${q.options[j]}');
      }
      buffer.writeln('');
    }

    if (includeAnswers) {
      buffer.writeln('');
      buffer.writeln('=' * 50);
      buffer.writeln('ОТВЕТЫ ДЛЯ УЧИТЕЛЯ');
      buffer.writeln('=' * 50);
      buffer.writeln('');
      buffer.writeln(quiz.answerKey);
    }

    return buffer.toString();
  }

  static String _letter(int index) {
    return String.fromCharCode(65 + index);
  }
}