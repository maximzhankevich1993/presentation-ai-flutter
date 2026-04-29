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

    for (int i = 0; i < questionCount && i < slideContents.length; i++) {
      final content = slideContents[i];
      final isCorrect = _random.nextBool();
      
      questions.add(QuizQuestion(
        question: 'Вопрос по материалу слайда ${i + 1}: $content',
        options: _generateOptions(content, isCorrect),
        correctIndex: isCorrect ? 0 : _random.nextInt(3) + 1,
        explanation: 'Правильный ответ основан на материале слайда ${i + 1}.',
      ));
    }

    return Quiz(
      title: 'Тест по презентации "$presentationTitle"',
      questions: questions,
      difficulty: difficulty,
      timeLimitMinutes: questionCount * 2,
    );
  }

  static List<String> _generateOptions(String content, bool firstIsCorrect) {
    final options = <String>[];
    if (firstIsCorrect) {
      options.add(content);
      options.add('Неверный вариант 1');
      options.add('Неверный вариант 2');
      options.add('Все вышеперечисленное');
    } else {
      options.add('Неверный вариант 1');
      options.add(content);
      options.add('Неверный вариант 2');
      options.add('Ничего из перечисленного');
    }
    return options;
  }
}