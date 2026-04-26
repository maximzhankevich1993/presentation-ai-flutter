import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'app_language';
  
  static const Map<String, Map<String, String>> _translations = {
    'ru': {
      'app_name': 'Презентатор ИИ',
      'create_presentation': 'Создай презентацию',
      'with_ai': 'с помощью Искусственного Интеллекта',
      'enter_topic': 'Введи тему презентации...',
      'create': 'Создать',
      'try_example': 'Попробуй:',
      'free_generations': 'Осталось генераций',
      'of_5': 'из 5',
      'premium_active': 'Premium активен',
      'analyzing': '🤔 Анализирую тему...',
      'collecting': '📚 Собираю информацию...',
      'structuring': '💡 Придумываю структуру...',
      'writing': '✍️ Пишу текст слайдов...',
      'images': '🖼 Подбираю иллюстрации...',
      'design': '🎨 Оформляю дизайн...',
      'final': '✨ Финальные штрихи...',
      'done': '✅ Готово!',
      'error': 'Ошибка',
      'retry': 'Попробовать снова',
      'download': 'Скачать',
      'share': 'Поделиться',
      'settings': 'Настройки',
      'premium': 'Premium',
      'profile': 'Профиль',
      'history': 'История',
    },
    'en': {
      'app_name': 'Presentation AI',
      'create_presentation': 'Create a presentation',
      'with_ai': 'with Artificial Intelligence',
      'enter_topic': 'Enter presentation topic...',
      'create': 'Create',
      'try_example': 'Try:',
      'free_generations': 'Free generations left',
      'of_5': 'of 5',
      'premium_active': 'Premium active',
      'analyzing': '🤔 Analyzing topic...',
      'collecting': '📚 Collecting information...',
      'structuring': '💡 Creating structure...',
      'writing': '✍️ Writing slides...',
      'images': '🖼 Finding images...',
      'design': '🎨 Designing...',
      'final': '✨ Final touches...',
      'done': '✅ Done!',
      'error': 'Error',
      'retry': 'Try again',
      'download': 'Download',
      'share': 'Share',
      'settings': 'Settings',
      'premium': 'Premium',
      'profile': 'Profile',
      'history': 'History',
    },
    'es': {
      'app_name': 'Presentador IA',
      'create_presentation': 'Crear presentación',
      'with_ai': 'con Inteligencia Artificial',
      'enter_topic': 'Ingresa el tema...',
      'create': 'Crear',
      'try_example': 'Prueba:',
      'free_generations': 'Generaciones gratis',
      'of_5': 'de 5',
      'premium_active': 'Premium activo',
      'analyzing': '🤔 Analizando tema...',
      'collecting': '📚 Recopilando información...',
      'structuring': '💡 Creando estructura...',
      'writing': '✍️ Escribiendo diapositivas...',
      'images': '🖼 Buscando imágenes...',
      'design': '🎨 Diseñando...',
      'final': '✨ Toques finales...',
      'done': '✅ ¡Listo!',
      'error': 'Error',
      'retry': 'Intentar de nuevo',
      'download': 'Descargar',
      'share': 'Compartir',
      'settings': 'Ajustes',
      'premium': 'Premium',
      'profile': 'Perfil',
      'history': 'Historial',
    },
    'de': {
      'app_name': 'Präsentator KI',
      'create_presentation': 'Präsentation erstellen',
      'with_ai': 'mit Künstlicher Intelligenz',
      'enter_topic': 'Thema eingeben...',
      'create': 'Erstellen',
      'try_example': 'Versuche:',
      'free_generations': 'Kostenlose Generierungen',
      'of_5': 'von 5',
      'premium_active': 'Premium aktiv',
      'analyzing': '🤔 Analysiere Thema...',
      'collecting': '📚 Sammle Informationen...',
      'structuring': '💡 Erstelle Struktur...',
      'writing': '✍️ Schreibe Folien...',
      'images': '🖼 Suche Bilder...',
      'design': '🎨 Gestalte Design...',
      'final': '✨ Letzte Details...',
      'done': '✅ Fertig!',
      'error': 'Fehler',
      'retry': 'Erneut versuchen',
      'download': 'Herunterladen',
      'share': 'Teilen',
      'settings': 'Einstellungen',
      'premium': 'Premium',
      'profile': 'Profil',
      'history': 'Verlauf',
    },
    'fr': {
      'app_name': 'Présentateur IA',
      'create_presentation': 'Créer une présentation',
      'with_ai': "avec l'Intelligence Artificielle",
      'enter_topic': 'Entrez le sujet...',
      'create': 'Créer',
      'try_example': 'Essayez:',
      'free_generations': 'Générations gratuites',
      'of_5': 'sur 5',
      'premium_active': 'Premium actif',
      'analyzing': '🤔 Analyse du sujet...',
      'collecting': "📚 Collecte d'informations...",
      'structuring': '💡 Création de la structure...',
      'writing': '✍️ Rédaction des diapositives...',
      'images': '🖼 Recherche d\'images...',
      'design': '🎨 Conception du design...',
      'final': '✨ Touches finales...',
      'done': '✅ Terminé!',
      'error': 'Erreur',
      'retry': 'Réessayer',
      'download': 'Télécharger',
      'share': 'Partager',
      'settings': 'Paramètres',
      'premium': 'Premium',
      'profile': 'Profil',
      'history': 'Historique',
    },
  };

  static String _currentLanguage = 'ru';

  /// Возвращает перевод по ключу
  static String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? _translations['ru']![key] ?? key;
  }

  /// Устанавливает язык
  static Future<void> setLanguage(String languageCode) async {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    }
  }

  /// Загружает сохранённый язык
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_languageKey);
    if (saved != null && _translations.containsKey(saved)) {
      _currentLanguage = saved;
    }
  }

  /// Возвращает текущий язык
  static String get currentLanguage => _currentLanguage;

  /// Возвращает список поддерживаемых языков
  static List<Map<String, String>> get supportedLanguages => [
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  ];
}