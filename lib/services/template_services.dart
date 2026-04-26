class PresentationTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final List<String> slideStructure;
  final bool isFree;

  const PresentationTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.slideStructure,
    this.isFree = true,
  });
}

class TemplateService {
  static List<PresentationTemplate> getTemplates({bool? freeOnly}) {
    final templates = _allTemplates;
    
    if (freeOnly == true) {
      return templates.where((t) => t.isFree).toList();
    }
    
    return templates;
  }

  static List<PresentationTemplate> getTemplatesByCategory(String category) {
    return _allTemplates.where((t) => t.category == category).toList();
  }

  static List<String> getCategories() {
    return _allTemplates.map((t) => t.category).toSet().toList();
  }

  static final List<PresentationTemplate> _allTemplates = [
    // Бесплатные шаблоны
    const PresentationTemplate(
      id: 'pitch_deck',
      name: 'Pitch Deck',
      description: 'Презентация для привлечения инвесторов',
      category: 'Бизнес',
      icon: '💰',
      slideStructure: [
        'Титульный слайд',
        'Проблема',
        'Решение',
        'Рынок',
        'Бизнес-модель',
        'Команда',
        'Финансы',
        'Дорожная карта',
        'Призыв к действию',
      ],
      isFree: true,
    ),
    const PresentationTemplate(
      id: 'report',
      name: 'Отчёт',
      description: 'Еженедельный или ежемесячный отчёт',
      category: 'Бизнес',
      icon: '📊',
      slideStructure: [
        'Титульный слайд',
        'Ключевые метрики',
        'Достижения',
        'Проблемы',
        'Выводы',
        'План на следующий период',
      ],
      isFree: true,
    ),
    const PresentationTemplate(
      id: 'education',
      name: 'Учебная',
      description: 'Презентация для урока или лекции',
      category: 'Образование',
      icon: '📚',
      slideStructure: [
        'Тема урока',
        'Цели',
        'Основной материал',
        'Примеры',
        'Практика',
        'Итоги',
        'Домашнее задание',
      ],
      isFree: true,
    ),
    const PresentationTemplate(
      id: 'product_launch',
      name: 'Запуск продукта',
      description: 'Презентация для запуска нового продукта',
      category: 'Маркетинг',
      icon: '🚀',
      slideStructure: [
        'Анонс',
        'Проблема рынка',
        'Наше решение',
        'Особенности продукта',
        'Целевая аудитория',
        'Конкуренты',
        'Маркетинговый план',
        'Ожидаемые результаты',
      ],
      isFree: false,
    ),
    const PresentationTemplate(
      id: 'conference',
      name: 'Конференция',
      description: 'Выступление на конференции',
      category: 'Выступления',
      icon: '🎤',
      slideStructure: [
        'Приветствие',
        'О спикере',
        'Введение в тему',
        'Основная часть',
        'Кейсы',
        'Выводы',
        'Q&A',
      ],
      isFree: false,
    ),
  ];
}