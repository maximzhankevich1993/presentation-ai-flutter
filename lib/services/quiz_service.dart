import 'dart:math';

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
}

class QuizService {
  static final Random _random = Random();

  static Quiz generateFromPresentation({
    required String presentationTitle,
    required List<String> slideContents,
    String difficulty = 'medium',
    int questionCount = 5,
  }) {
    final questions = <QuizQuestion>[];

    final usableSlides = slideContents.isNotEmpty
        ? slideContents
        : ['Нет данных'];

    for (int i = 0; i < questionCount; i++) {
      final content = usableSlides[i % usableSlides.length];

      final correctOptionIndex = _random.nextInt(4);

      final options = _generateOptions(content, correctOptionIndex);

      questions.add(QuizQuestion(
        question: 'Что описано в этом фрагменте: "$content"?',
        options: options,
        correctIndex: correctOptionIndex,
        explanation: 'Правильный ответ основан на содержании: "$content".',
      ));
    }

    return Quiz(
      title: 'Тест по презентации "$presentationTitle"',
      questions: questions,
      difficulty: difficulty,
      timeLimitMinutes: questionCount * 2,
    );
  }

  static List<String> _generateOptions(
    String content,
    int correctIndex,
  ) {
    final options = List<String>.filled(4, '');

    final distractors = [
      'Совершенно другое утверждение',
      'Частично неверная интерпретация',
      'Противоположный смысл',
      'Неправильный вывод',
      'Несвязанный факт',
    ];

    for (int i = 0; i < 4; i++) {
      if (i == correctIndex) {
        options[i] = content;
      } else {
        options[i] = distractors[_random.nextInt(distractors.length)];
      }
    }

    return options;
  }
}