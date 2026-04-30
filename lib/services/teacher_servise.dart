class TeacherService {
  /// База образовательных систем по странам
  static final Map<String, Map<String, dynamic>> educationSystems = {
    'US': {
      'country': 'США',
      'standard': 'Common Core State Standards',
      'curriculum': 'CCSS + NGSS',
      'integrations': ['Google Classroom', 'Schoology', 'Canvas'],
      'grading': 'A-F (4.0 GPA)',
      'academicYear': 'Август-Май',
      'languages': ['English'],
    },
    'GB': {
      'country': 'Великобритания',
      'standard': 'National Curriculum',
      'curriculum': 'GCSE / A-Levels',
      'integrations': ['Google Classroom', 'Microsoft Teams'],
      'grading': '9-1 (GCSE)',
      'academicYear': 'Сентябрь-Июль',
      'languages': ['English'],
    },
    'DE': {
      'country': 'Германия',
      'standard': 'Bildungsstandards (KMK)',
      'curriculum': 'Lehrplan',
      'integrations': ['Moodle', 'IServ'],
      'grading': '1-6',
      'academicYear': 'Август-Июль',
      'languages': ['Deutsch'],
    },
    'FR': {
      'country': 'Франция',
      'standard': 'Programmes Officiels',
      'curriculum': 'Éducation Nationale',
      'integrations': ['ENT', 'Pronote'],
      'grading': '0-20',
      'academicYear': 'Сентябрь-Июнь',
      'languages': ['Français'],
    },
    'RU': {
      'country': 'Россия',
      'standard': 'ФГОС',
      'curriculum': 'ФГОС + Примерная программа',
      'integrations': ['МЭШ', 'Дневник.ру', 'Сферум'],
      'grading': '2-5',
      'academicYear': 'Сентябрь-Май',
      'languages': ['Русский'],
    },
  };

  /// Безопасное получение системы
  static Map<String, dynamic>? getSystem(String countryCode) {
    if (countryCode.isEmpty) return null;
    return educationSystems[countryCode.toUpperCase()];
  }

  /// Безопасное получение строки
  static String _safeString(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  /// Безопасное получение списка строк
  static List<String> _safeStringList(dynamic value, List<String> fallback) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return fallback;
  }

  /// Возвращает список поддерживаемых стран
  static List<Map<String, String>> getSupportedCountries() {
    return educationSystems.entries.map((e) {
      final data = e.value;

      return {
        'code': e.key,
        'country': _safeString(data['country'], 'Unknown'),
        'standard': _safeString(data['standard'], '—'),
      };
    }).toList();
  }

  /// Генерирует план урока под конкретную страну
  static Map<String, dynamic> generateLessonPlan({
    required String topic,
    required String subject,
    required String countryCode,
    String grade = '6-8',
    int durationMinutes = 45,
  }) {
    final system = getSystem(countryCode);

    final standard =
        _safeString(system?['standard'], 'Международный стандарт');
    final country = _safeString(system?['country'], countryCode);

    final integrations = _safeStringList(
      system?['integrations'],
      ['Google Classroom'],
    );

    final languages = _safeStringList(
      system?['languages'],
      ['English'],
    );

    final safeDuration = durationMinutes.clamp(10, 180);

    return {
      'topic': topic,
      'subject': subject,
      'country': country,
      'standard': standard,
      'grade': grade,
      'duration': '$safeDuration минут',
      'language': languages.isNotEmpty ? languages.first : 'English',
      'integrations': integrations,
      'stages': _generateStages(safeDuration),
      'homework': _generateHomework(topic, languages.isNotEmpty ? languages.first : 'English'),
      'assessment': _generateAssessment(standard),
    };
  }

  /// Генерация этапов урока (с контролем суммы)
  static List<Map<String, dynamic>> _generateStages(int total) {
    final parts = [
      0.1,
      0.15,
      0.35,
      0.25,
      0.15,
    ];

    final stages = [
      'Организационный момент',
      'Актуализация знаний',
      'Изучение нового',
      'Закрепление',
      'Рефлексия',
    ];

    final descriptions = [
      'Приветствие, проверка готовности',
      'Повторение пройденного, вопросы',
      'Объяснение темы, презентация, примеры',
      'Практическая работа, групповая активность',
      'Подведение итогов, домашнее задание',
    ];

    int used = 0;

    final result = List.generate(parts.length, (i) {
      int minutes = (total * parts[i]).round();
      used += minutes;

      return {
        'name': stages[i],
        'minutes': minutes,
        'description': descriptions[i],
      };
    });

    // корректируем последний элемент, чтобы сумма совпала
    final diff = total - used;
    if (diff != 0 && result.isNotEmpty) {
      result.last['minutes'] += diff;
    }

    return result;
  }

  static String _generateHomework(String topic, String language) {
    switch (language) {
      case 'Русский':
        return 'Подготовить краткое сообщение по теме "$topic"';
      case 'Deutsch':
        return 'Erstellen Sie eine kurze Zusammenfassung zum Thema "$topic"';
      case 'Français':
        return 'Préparer un résumé sur "$topic"';
      default:
        return 'Prepare a short summary on "$topic"';
    }
  }

  static String _generateAssessment(String standard) {
    if (standard.contains('ФГОС')) {
      return 'Самооценка по критериям, тест из 5 вопросов';
    }
    if (standard.contains('Common Core')) {
      return 'Exit ticket with 3 questions, peer assessment';
    }
    return 'Quick quiz (5 questions), self-reflection';
  }
}