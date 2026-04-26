/// Модель фичи приложения
class AppFeature {
  final String id;
  final String name;
  final String description;
  final String icon;
  final FeatureCategory category;
  final FeatureTier tier;
  final bool isHighlighted;

  const AppFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.tier = FeatureTier.free,
    this.isHighlighted = false,
  });
}

enum FeatureCategory {
  aiGeneration,
  design,
  smartContext,
  aiAssistant,
  social,
  monetization,
  export,
  security,
}

enum FeatureTier {
  free,
  premium,
  enterprise,
}

/// Полный каталог всех фишек
class FeaturesCatalog {
  static const List<AppFeature> allFeatures = [
    // ===== AI-ГЕНЕРАЦИЯ =====
    AppFeature(
      id: 'ai_generation',
      name: 'AI-генерация презентаций',
      description: 'Введите тему — и нейросеть DeepSeek создаст структуру презентации за 30 секунд. ИИ анализирует тему и генерирует логичную последовательность слайдов.',
      icon: '🤖',
      category: FeatureCategory.aiGeneration,
      tier: FeatureTier.free,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'auto_images',
      name: 'Авто-подбор картинок',
      description: 'Для каждого слайда автоматически подбираются релевантные изображения из библиотеки Unsplash. Экономит часы ручного поиска.',
      icon: '🖼',
      category: FeatureCategory.aiGeneration,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'ai_improve',
      name: 'AI-улучшение текста',
      description: 'Выделите текст — и ИИ сделает его профессиональнее, чётче и убедительнее. Поддерживает рерайт, сокращение и генерацию вариантов заголовков.',
      icon: '✨',
      category: FeatureCategory.aiGeneration,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),

    // ===== ДИЗАЙН =====
    AppFeature(
      id: 'backgrounds',
      name: 'Выбор фона',
      description: 'Меняйте фон слайдов: 12 цветов, 6 градиентов, 5 текстур. Загружайте свои изображения с настройкой затемнения и размытия.',
      icon: '🎨',
      category: FeatureCategory.design,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'fonts',
      name: 'Шрифтовые пары',
      description: '6 профессиональных пар шрифтов «заголовок + текст». От Modern Tech до Playful Hand — под любую задачу.',
      icon: '✍️',
      category: FeatureCategory.design,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'animations',
      name: 'Анимированные переходы',
      description: '10 эффектов перехода между слайдами: плавное появление, 3D-куб, волна, глитч и другие. Сделайте презентацию динамичной.',
      icon: '🎬',
      category: FeatureCategory.design,
      tier: FeatureTier.premium,
    ),
    AppFeature(
      id: 'anti_template',
      name: 'Режим «Анти-шаблон»',
      description: 'Каждый слайд в уникальном стиле! Наш алгоритм создаёт визуальный ритм, который невозможно повторить. Ваша презентация будет непохожа на другие.',
      icon: '🎪',
      category: FeatureCategory.design,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'brand_kit',
      name: 'Бренд-кит из логотипа',
      description: 'Загрузите логотип компании — приложение автоматически подберёт цвета, шрифты и стиль, чтобы презентация выглядела фирменной.',
      icon: '🏷',
      category: FeatureCategory.design,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'story_mode',
      name: 'Story Mode',
      description: 'Вместо классических слайдов — скроллящаяся история как в Instagram. Идеально для отправки в мессенджеры и соцсети.',
      icon: '📱',
      category: FeatureCategory.design,
      tier: FeatureTier.premium,
    ),

    // ===== УМНЫЙ КОНТЕКСТ =====
    AppFeature(
      id: 'competitor_analysis',
      name: 'Анализ конкурентов',
      description: 'Перед генерацией ИИ изучает публичные презентации по вашей теме и предлагает уникальный угол, которого нет у других.',
      icon: '🔍',
      category: FeatureCategory.smartContext,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'smart_data',
      name: 'Smart Data Injection',
      description: 'Автоматически вставляем актуальные цифры и факты из проверенных источников (Statista, McKinsey, Gartner) прямо в слайды.',
      icon: '📊',
      category: FeatureCategory.smartContext,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'citations',
      name: 'Авто-цитаты и источники',
      description: 'Каждый факт получает сноску с источником. Поддержка APA и ГОСТ. Для студентов — автоматическое оформление литературы.',
      icon: '📚',
      category: FeatureCategory.smartContext,
      tier: FeatureTier.premium,
    ),

    // ===== AI-АССИСТЕНТ =====
    AppFeature(
      id: 'rehearsal',
      name: 'Репетиция с AI',
      description: 'Загрузите презентацию — AI прослушает вашу речь и даст советы: «Слишком быстро», «Добавьте паузу», «Объясните термин проще».',
      icon: '🎤',
      category: FeatureCategory.aiAssistant,
      tier: FeatureTier.premium,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'translation',
      name: 'AI-перевод с адаптацией',
      description: 'Перевод на 15+ языков с культурной адаптацией. Не дословно — а с заменой примеров и метафор под культуру страны.',
      icon: '🌍',
      category: FeatureCategory.aiAssistant,
      tier: FeatureTier.premium,
    ),
    AppFeature(
      id: 'materials',
      name: 'Авто-генерация материалов',
      description: 'Из одной презентации создаются: PDF-документ, пост для LinkedIn, Twitter-тред и email-рассылка. Один клик — 4 формата.',
      icon: '📝',
      category: FeatureCategory.aiAssistant,
      tier: FeatureTier.premium,
    ),
    AppFeature(
      id: 'consultant',
      name: 'AI-консультант',
      description: 'Анализирует структуру повествования: «Добавьте кейс между слайдами 3 и 4», «Начните с шокирующей статистики».',
      icon: '🧠',
      category: FeatureCategory.aiAssistant,
      tier: FeatureTier.premium,
    ),
    AppFeature(
      id: 'speaker_notes',
      name: 'Заметки докладчика',
      description: 'Автоматически генерируются заметки для каждого слайда: что сказать, где сделать паузу, какой вопрос задать аудитории.',
      icon: '📋',
      category: FeatureCategory.aiAssistant,
      tier: FeatureTier.premium,
    ),

    // ===== СОЦИАЛЬНЫЕ МЕХАНИКИ =====
    AppFeature(
      id: 'gallery',
      name: 'Публичная галерея',
      description: 'Публикуйте свои работы и смотрите презентации других. Топ-10 недели получают Premium бесплатно.',
      icon: '🏆',
      category: FeatureCategory.social,
      tier: FeatureTier.free,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'referral',
      name: 'Реферальная программа',
      description: 'Пригласите друга — оба получите бонусы. 3 друга = +3 генерации, 10 друзей = месяц Premium бесплатно.',
      icon: '👥',
      category: FeatureCategory.social,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'digest',
      name: 'Еженедельный AI-дайджест',
      description: 'Подписчики получают письмо с трендами недели и готовой презентацией по каждому тренду.',
      icon: '📧',
      category: FeatureCategory.social,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'surprise',
      name: 'Кнопка «Удиви меня»',
      description: 'Случайный стиль оформления одним нажатием. Во время генерации показывает забавные факты о презентациях.',
      icon: '🎲',
      category: FeatureCategory.social,
      tier: FeatureTier.free,
    ),

    // ===== ЭКСПОРТ =====
    AppFeature(
      id: 'export_pptx',
      name: 'Экспорт в PPTX',
      description: 'Скачивайте презентацию в формате PowerPoint. Бесплатная версия — с водяным знаком, Premium — без.',
      icon: '📥',
      category: FeatureCategory.export,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'export_pdf',
      name: 'Экспорт в PDF',
      description: 'Экспорт в PDF без водяного знака. Доступно только в Premium.',
      icon: '📄',
      category: FeatureCategory.export,
      tier: FeatureTier.premium,
    ),
    AppFeature(
      id: 'qr_share',
      name: 'QR-код для шаринга',
      description: 'Мгновенно делитесь презентацией через QR-код. Удобно для конференций и встреч.',
      icon: '📱',
      category: FeatureCategory.export,
      tier: FeatureTier.free,
    ),

    // ===== МОНЕТИЗАЦИЯ =====
    AppFeature(
      id: 'full_package',
      name: 'Пакет «Под ключ»',
      description: 'Полный комплект: структура, заметки докладчика, Q&A-сценарий, соцсети, видео-скрипт, follow-up письма.',
      icon: '🎁',
      category: FeatureCategory.monetization,
      tier: FeatureTier.enterprise,
      isHighlighted: true,
    ),
    AppFeature(
      id: 'white_label',
      name: 'White-label для агентств',
      description: 'Используйте наш движок под своим брендом. Ваш логотип, цвета, домен. Для маркетинговых агентств.',
      icon: '🏢',
      category: FeatureCategory.monetization,
      tier: FeatureTier.enterprise,
    ),

    // ===== БЕЗОПАСНОСТЬ =====
    AppFeature(
      id: 'encryption',
      name: 'Шифрование данных',
      description: 'Все данные шифруются. Защита от повторной установки и взлома. Ваши презентации в безопасности.',
      icon: '🔒',
      category: FeatureCategory.security,
      tier: FeatureTier.free,
    ),
    AppFeature(
      id: 'no_registration',
      name: 'Без регистрации',
      description: 'Первые 5 презентаций создаются без регистрации. Никаких обязательств — просто попробуйте.',
      icon: '✅',
      category: FeatureCategory.security,
      tier: FeatureTier.free,
    ),
  ];

  /// Возвращает фичи по категории
  static List<AppFeature> getByCategory(FeatureCategory category) {
    return allFeatures.where((f) => f.category == category).toList();
  }

  /// Возвращает фичи по тарифу
  static List<AppFeature> getByTier(FeatureTier tier) {
    return allFeatures.where((f) => f.tier == tier).toList();
  }

  /// Возвращает бесплатные фичи
  static List<AppFeature> getFreeFeatures() {
    return allFeatures.where((f) => f.tier == FeatureTier.free).toList();
  }

  /// Возвращает Premium фичи
  static List<AppFeature> getPremiumFeatures() {
    return allFeatures.where((f) => f.tier == FeatureTier.premium).toList();
  }

  /// Возвращает Enterprise фичи
  static List<AppFeature> getEnterpriseFeatures() {
    return allFeatures.where((f) => f.tier == FeatureTier.enterprise).toList();
  }

  /// Возвращает самые крутые фичи (highlighted)
  static List<AppFeature> getHighlightedFeatures() {
    return allFeatures.where((f) => f.isHighlighted).toList();
  }

  /// Возвращает список всех категорий с названиями
  static Map<FeatureCategory, String> get categories => {
    FeatureCategory.aiGeneration: '🤖 AI-Генерация',
    FeatureCategory.design: '🎨 Дизайн',
    FeatureCategory.smartContext: '🧠 Умный контекст',
    FeatureCategory.aiAssistant: '🤝 AI-Ассистент',
    FeatureCategory.social: '👥 Социальные механики',
    FeatureCategory.export: '📤 Экспорт',
    FeatureCategory.monetization: '💼 Для бизнеса',
    FeatureCategory.security: '🔒 Безопасность',
  };
}