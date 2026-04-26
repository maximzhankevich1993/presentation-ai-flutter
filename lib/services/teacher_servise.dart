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
    'BY': {
      'country': 'Беларусь',
      'standard': 'Образовательные стандарты РБ',
      'curriculum': 'Программы Минобра РБ',
      'integrations': ['Знай.бай', 'Электронная школа'],
      'grading': '1-10',
      'academicYear': 'Сентябрь-Май',
      'languages': ['Русский', 'Беларуская'],
    },
    'KZ': {
      'country': 'Казахстан',
      'standard': 'ГОСО РК',
      'curriculum': 'Типовые учебные программы',
      'integrations': ['Күнделік', 'BilimLand'],
      'grading': '1-5',
      'academicYear': 'Сентябрь-Май',
      'languages': ['Қазақша', 'Русский'],
    },
    'IN': {
      'country': 'Индия',
      'standard': 'CBSE / NCERT',
      'curriculum': 'NCERT + State Boards',
      'integrations': ['Google Classroom', 'Diksha'],
      'grading': '0-100',
      'academicYear': 'Апрель-Март',
      'languages': ['English', 'Hindi'],
    },
    'BR': {
      'country': 'Бразилия',
      'standard': 'BNCC',
      'curriculum': 'Base Nacional Comum Curricular',
      'integrations': ['Google Classroom', 'Khan Academy'],
      'grading': '0-10',
      'academicYear': 'Февраль-Декабрь',
      'languages': ['Português'],
    },
    'JP': {
      'country': 'Япония',
      'standard': '学習指導要領 (MEXT)',
      'curriculum': 'MEXT Guidelines',
      'integrations': ['Google Classroom', 'ロイロノート'],
      'grading': '1-5',
      'academicYear': 'Апрель-Март',
      'languages': ['日本語'],
    },
  };

  /// Возвращает образовательную систему по коду страны
  static Map<String, dynamic>? getSystem(String countryCode) {
    return educationSystems[countryCode.toUpperCase()];
  }

  /// Возвращает список поддерживаемых стран
  static List<Map<String, String>> getSupportedCountries() {
    return educationSystems.entries.map((e) => {
      'code': e.key,
      'country': e.value['country'] as String,
      'standard': e.value['standard'] as String,
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
    final standard = system?['standard'] ?? 'Международный стандарт';
    final country = system?['country'] ?? countryCode;
    final integrations = system?['integrations'] as List<String>? ?? ['Google Classroom'];
    final languages = system?['languages'] as List<String>? ?? ['English'];

    return {
      'topic': topic,
      'country': country,
      'standard': standard,
      'grade': grade,
      'duration': '$durationMinutes минут',
      'language': languages.first,
      'integrations': integrations,
      'stages': _generateStages(standard, durationMinutes),
      'homework': _generateHomework(topic, languages.first),
      'assessment': _generateAssessment(standard),
    };
  }

  static List<Map<String, dynamic>> _generateStages(String standard, int total) {
    return [
      {'name': 'Организационный момент', 'minutes': (total * 0.1).round(), 'description': 'Приветствие, проверка готовности'},
      {'name': 'Актуализация знаний', 'minutes': (total * 0.15).round(), 'description': 'Повторение пройденного, вопросы'},
      {'name': 'Изучение нового', 'minutes': (total * 0.35).round(), 'description': 'Объяснение темы, презентация, примеры'},
      {'name': 'Закрепление', 'minutes': (total * 0.25).round(), 'description': 'Практическая работа, групповая активность'},
      {'name': 'Рефлексия', 'minutes': (total * 0.15).round(), 'description': 'Подведение итогов, домашнее задание'},
    ];
  }

  static String _generateHomework(String topic, String language) {
    if (language == 'Русский') return 'Подготовить краткое сообщение по теме "$topic"';
    if (language == 'Deutsch') return 'Erstellen Sie eine kurze Zusammenfassung zum Thema "$topic"';
    if (language == 'Français') return 'Préparer un résumé sur "$topic"';
    return 'Prepare a short summary on "$topic"';
  }

  static String _generateAssessment(String standard) {
    if (standard.contains('ФГОС')) return 'Самооценка по критериям, тест из 5 вопросов';
    if (standard.contains('Common Core')) return 'Exit ticket with 3 questions, peer assessment';
    return 'Quick quiz (5 questions), self-reflection';
  }
}