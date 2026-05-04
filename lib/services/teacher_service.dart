class TeacherService {
  static final Map<String, Map<String, dynamic>> educationSystems = {
    'US': {'country': 'США', 'standard': 'Common Core', 'languages': ['English']},
    'GB': {'country': 'Великобритания', 'standard': 'National Curriculum', 'languages': ['English']},
    'DE': {'country': 'Германия', 'standard': 'Bildungsstandards', 'languages': ['Deutsch']},
    'FR': {'country': 'Франция', 'standard': 'Programmes Officiels', 'languages': ['Francais']},
    'RU': {'country': 'Россия', 'standard': 'ФГОС', 'languages': ['Русский']},
    'BY': {'country': 'Беларусь', 'standard': 'Стандарты РБ', 'languages': ['Русский', 'Беларуская']},
    'KZ': {'country': 'Казахстан', 'standard': 'ГОСО РК', 'languages': ['Казакша', 'Русский']},
    'IN': {'country': 'Индия', 'standard': 'CBSE / NCERT', 'languages': ['English', 'Hindi']},
    'BR': {'country': 'Бразилия', 'standard': 'BNCC', 'languages': ['Portugues']},
    'JP': {'country': 'Япония', 'standard': 'MEXT', 'languages': ['日本語']},
  };

  static Map<String, dynamic>? getSystem(String countryCode) {
    return educationSystems[countryCode.toUpperCase()];
  }

  static List<Map<String, String>> getSupportedCountries() {
    return educationSystems.entries.map((e) => {
      'code': e.key,
      'country': e.value['country'] as String,
      'standard': e.value['standard'] as String,
    }).toList();
  }

  static Map<String, dynamic> generateLessonPlan({
    required String topic,
    required String subject,
    required String countryCode,
    String grade = '6-8',
    int durationMinutes = 45,
  }) {
    final system = getSystem(countryCode);
    return {
      'topic': topic,
      'country': system?['country'] ?? countryCode,
      'standard': system?['standard'] ?? 'Международный',
      'grade': grade,
      'duration': '$durationMinutes минут',
      'stages': [
        {'name': 'Орг. момент', 'minutes': (durationMinutes * 0.1).round(), 'description': 'Приветствие, проверка готовности'},
        {'name': 'Актуализация', 'minutes': (durationMinutes * 0.15).round(), 'description': 'Повторение пройденного'},
        {'name': 'Новый материал', 'minutes': (durationMinutes * 0.35).round(), 'description': 'Объяснение темы'},
        {'name': 'Закрепление', 'minutes': (durationMinutes * 0.25).round(), 'description': 'Практическая работа'},
        {'name': 'Рефлексия', 'minutes': (durationMinutes * 0.15).round(), 'description': 'Подведение итогов'},
      ],
      'homework': 'Подготовить краткое сообщение по теме "$topic"',
      'assessment': 'Тест из 5 вопросов, самооценка',
    };
  }
}