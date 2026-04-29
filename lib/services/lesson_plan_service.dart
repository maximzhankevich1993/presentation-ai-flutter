class LessonPlan {
  final String topic;
  final String grade;
  final String subject;
  final String standard;
  final String duration;
  final List<String> objectives;
  final List<LessonStage> stages;
  final String homework;
  final String assessment;
  final List<String> differentiation;

  const LessonPlan({
    required this.topic,
    required this.grade,
    required this.subject,
    required this.standard,
    required this.duration,
    required this.objectives,
    required this.stages,
    required this.homework,
    required this.assessment,
    required this.differentiation,
  });
}

class LessonStage {
  final String name;
  final int minutes;
  final String teacherActions;
  final String studentActions;
  final String resources;

  const LessonStage({
    required this.name,
    required this.minutes,
    required this.teacherActions,
    required this.studentActions,
    required this.resources,
  });
}

class LessonPlanService {
  static const List<Map<String, String>> standards = [
    {'code': 'common_core', 'name': 'Common Core (USA)', 'region': 'США'},
    {'code': 'cambridge', 'name': 'Cambridge International', 'region': 'Международный'},
    {'code': 'ib', 'name': 'International Baccalaureate (IB)', 'region': 'Международный'},
    {'code': 'fgos', 'name': 'ФГОС (Россия)', 'region': 'Россия'},
    {'code': 'national_uk', 'name': 'National Curriculum (UK)', 'region': 'Великобритания'},
    {'code': 'australian', 'name': 'Australian Curriculum', 'region': 'Австралия'},
    {'code': 'cbse', 'name': 'CBSE (India)', 'region': 'Индия'},
    {'code': 'common_eu', 'name': 'European Framework', 'region': 'Евросоюз'},
  ];

  static LessonPlan generate({
    required String topic,
    required String subject,
    required String standard,
    String grade = '6-8',
    int durationMinutes = 45,
  }) {
    return LessonPlan(
      topic: topic,
      grade: grade,
      subject: subject,
      standard: standard,
      duration: '$durationMinutes минут',
      objectives: _getObjectives(topic, subject, standard),
      stages: _getStages(standard, durationMinutes),
      homework: _getHomework(topic),
      assessment: _getAssessment(standard),
      differentiation: _getDifferentiation(),
    );
  }

  static List<String> _getObjectives(String topic, String subject, String standard) {
    switch (standard) {
      case 'common_core':
        return [
          'Students will be able to explain key concepts of "$topic"',
          'Students will analyze and evaluate information related to $subject',
          'Students will apply critical thinking skills to solve problems',
        ];
      case 'cambridge':
        return [
          'Learners will demonstrate understanding of "$topic"',
          'Learners will develop analytical skills through inquiry-based learning',
          'Learners will reflect on their learning process',
        ];
      case 'ib':
        return [
          'Inquiry: Students will investigate "$topic" through guided inquiry',
          'Action: Students will apply their learning to real-world contexts',
          'Reflection: Students will evaluate their understanding and growth',
        ];
      case 'fgos':
        return [
          'Предметные: изучить основные понятия по теме "$topic"',
          'Метапредметные: развивать навыки анализа и синтеза информации',
          'Личностные: формировать интерес к предмету $subject',
        ];
      default:
        return [
          'Understand the main concepts of "$topic"',
          'Apply knowledge to solve related problems',
          'Develop critical thinking and communication skills',
        ];
    }
  }

  static List<LessonStage> _getStages(String standard, int totalMinutes) {
    return [
      LessonStage(name: 'Организационный момент', minutes: (totalMinutes * 0.1).round(), teacherActions: 'Приветствие, проверка готовности', studentActions: 'Подготовка к уроку', resources: 'Слайд 1'),
      LessonStage(name: 'Актуализация знаний', minutes: (totalMinutes * 0.15).round(), teacherActions: 'Вопросы по предыдущей теме', studentActions: 'Ответы на вопросы', resources: 'Слайды 2-3'),
      LessonStage(name: 'Изучение нового', minutes: (totalMinutes * 0.35).round(), teacherActions: 'Объяснение темы, презентация', studentActions: 'Запись ключевых моментов', resources: 'Слайды 4-8'),
      LessonStage(name: 'Закрепление', minutes: (totalMinutes * 0.25).round(), teacherActions: 'Практические задания', studentActions: 'Работа в группах', resources: 'Раздаточный материал'),
      LessonStage(name: 'Рефлексия', minutes: (totalMinutes * 0.15).round(), teacherActions: 'Подведение итогов', studentActions: 'Самооценка', resources: 'Слайд 9-10'),
    ];
  }

  static String _getHomework(String topic) {
    final homeworks = [
      'Создать ментальную карту по теме "$topic"',
      'Написать краткое эссе (150 слов) по теме "$topic"',
      'Подготовить 3 вопроса по теме "$topic" для одноклассников',
      'Найти интересный факт по теме "$topic" и поделиться с классом',
    ];
    return homeworks[topic.length % homeworks.length];
  }

  static String _getAssessment(String standard) {
    switch (standard) {
      case 'ib':
        return 'Formative: Exit ticket with open-ended questions. Summative: Project-based assessment.';
      case 'cambridge':
        return 'Formative: Peer assessment during group work. Summative: End-of-topic test.';
      default:
        return 'Formative: Quick quiz (5 questions). Summative: End-of-week test.';
    }
  }

  static List<String> _getDifferentiation() {
    return [
      '🟢 Support: Provide sentence starters and visual aids',
      '🟡 Core: Standard tasks with scaffolding as needed',
      '🔴 Extension: Open-ended questions and research tasks',
      '🌍 EAL/ESL: Key vocabulary list with translations',
    ];
  }
}