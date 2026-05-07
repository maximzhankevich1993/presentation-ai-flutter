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

  /// Возвращает строку с правильными ответами
  String get answerKey {
    final buffer = StringBuffer();
    buffer.writeln('КЛЮЧ К ТЕСТУ: $title');
    buffer.writeln('');
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      buffer.writeln('${i + 1}. ${q.options[q.correctIndex]}');
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
  static final Random _random = Random();

  /// Генерация теста из презентации
  static Quiz generateFromPresentation({
    required String presentationTitle,
    required List<String> slideContents,
    String difficulty = 'medium',
    int questionCount = 5,
  }) {
    final questions = <QuizQuestion>[];
    for (int i = 0; i < questionCount && i < slideContents.length; i++) {
      final content = slideContents[i];
      questions.add(QuizQuestion(
        question: 'Вопрос по материалу: ${content.length > 50 ? content.substring(0, 50) + '...' : content}',
        options: _generateOptions(content),
        correctIndex: 0,
        explanation: 'См. материал урока.',
      ));
    }
    return Quiz(title: 'Тест: $presentationTitle', questions: questions, difficulty: difficulty, timeLimitMinutes: questionCount * 2);
  }

  /// Генерация теста по учебнику и теме
  static Quiz generateFromTextbook({
    required String textbook,
    required String topic,
    String grade = '9 класс',
    int questionCount = 10,
  }) {
    final questions = <QuizQuestion>[];
    final topics = [
      'Основные понятия по теме "$topic"',
      'Определения из учебника "$textbook"',
      'Ключевые даты и события',
      'Причины и следствия',
      'Сравнительный анализ',
      'Практическое применение',
      'Исторический контекст',
      'Формулы и законы',
      'Примеры из учебника',
      'Обобщающий вопрос',
    ];

    for (int i = 0; i < questionCount; i++) {
      final t = topics[i % topics.length];
      questions.add(QuizQuestion(
        question: '$t (по учебнику "$textbook", $grade)',
        options: _generateOptions(t),
        correctIndex: 0,
        explanation: 'См. учебник "$textbook", раздел "$topic".',
      ));
    }

    return Quiz(
      title: 'Тест: $topic ($textbook, $grade)',
      questions: questions,
      difficulty: 'medium',
      timeLimitMinutes: questionCount * 2,
    );
  }

  static List<String> _generateOptions(String content) {
    return [
      content.length > 40 ? content.substring(0, 40) + '...' : content,
      'Неверный вариант А',
      'Неверный вариант Б',
      'Все вышеперечисленное',
    ];
  }

  /// Экспорт теста + ответов для Word
  static String exportToWord(Quiz quiz, {bool includeAnswers = true}) {
    final buffer = StringBuffer();
    
    // Заголовок
    buffer.writeln('ТЕСТ');
    buffer.writeln(quiz.title);
    buffer.writeln('Уровень: ${quiz.difficulty} | Время: ${quiz.timeLimitMinutes} мин');
    buffer.writeln('');
    buffer.writeln('ФИО: ____________________  Дата: __________  Класс: __________');
    buffer.writeln('');
    buffer.writeln('=' * 50);
    buffer.writeln('');

    // Вопросы
    for (int i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      buffer.writeln('${i + 1}. ${q.question}');
      for (int j = 0; j < q.options.length; j++) {
        buffer.writeln('   ${_letter(j)}) ${q.options[j]}');
      }
      buffer.writeln('');
    }

    // Ответы для учителя
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

  /// Экспорт только ответов (для печати на отдельном листе)
  static String exportAnswerKey(Quiz quiz) {
    return quiz.answerKey;
  }

  static String _letter(int index) {
    return String.fromCharCode(65 + index); // A, B, C, D
  }
}