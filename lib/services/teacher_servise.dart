class TeacherService {
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

  static Map<String, dynamic>? getSystem(String countryCode) {
    if (countryCode.isEmpty) return null;
    return educationSystems[countryCode.toUpperCase()];
  }

  static String _safeString(dynamic value, String fallback) {
    if (value is String && value.trim().isNotEmpty) return value;
    return fallback;
  }

  static List<String> _safeStringList(dynamic value, List<String> fallback) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return fallback;
  }

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
      'language': languages.first,
      'integrations': integrations,
      'stages': _generateStages(safeDuration),
      'homework': _generateHomework(topic, languages.first),
      'assessment': _generateAssessment(standard),
    };
  }

  static List<Map<String, dynamic>> _generateStages(int total) {
    final parts = [0.1, 0.15, 0.35, 0.25, 0.15];

    final names = [
      'Организационный момент',
      'Актуализация знаний',
      'Изучение нового',
      'Закрепление',
      'Рефлексия',
    ];

    final descriptions = [
      'Приветствие, проверка готовности',
      'Повторение пройденного, вопросы',
      'Объяснение темы, примеры',
      'Практика, задания',
      'Итоги и обратная связь',
    ];

    int used = 0;

    final result = List.generate(parts.length, (i) {
      final minutes = (total * parts[i]).round();
      used += minutes;

      return {
        'name': names[i],
        'minutes': minutes,
        'description': descriptions[i],
      };
    });

    final diff = total - used;
    if (diff != 0) result.last['minutes'] += diff;

    return result;
  }

  static String _generateHomework(String topic, String language) {
    switch (language) {
      case 'Русский':
        return 'Подготовить сообщение по теме "$topic"';
      case 'Deutsch':
        return 'Zusammenfassung zum Thema "$topic"';
      case 'Français':
        return 'Résumé sur "$topic"';
      default:
        return 'Prepare a summary on "$topic"';
    }
  }

  static String _generateAssessment(String standard) {
    if (standard.contains('ФГОС')) {
      return 'Тест + самооценка';
    }
    if (standard.contains('Common Core')) {
      return 'Exit ticket + peer review';
    }
    return 'Quick quiz';
  }
}