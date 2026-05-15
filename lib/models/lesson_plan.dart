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