import 'package:flutter/material.dart';
import '../models/design_template.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ЦВЕТОВЫЕ СХЕМЫ
// ═══════════════════════════════════════════════════════════════════════════════

const _womenBusinessColorScheme = TemplateColorScheme(
  background: Color(0xFFF7F5F0),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF8B5F5C),
  secondary: Color(0xFFD4C5C2),
  accent: Color(0xFFC89F9A),
  textPrimary: Color(0xFF2D2D2D),
  textSecondary: Color(0xFF6B6B6B),
  gradient: [Color(0xFFF7F5F0), Color(0xFFEDE8E3)],
);

const _womenBusinessFontPair = FontPair(
  heading: 'Playfair Display',
  body: 'Inter',
  accent: 'Montserrat',
);

const _techMinimalColorScheme = TemplateColorScheme(
  background: Color(0xFF0A0E27),
  surface: Color(0xFF1A1F3A),
  primary: Color(0xFF3B82F6),
  secondary: Color(0xFF64748B),
  accent: Color(0xFF38BDF8),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0A0E27), Color(0xFF1A1F3A)],
);

const _techMinimalFontPair = FontPair(
  heading: 'Space Grotesk',
  body: 'Inter',
  accent: 'JetBrains Mono',
);

const _partyEventColorScheme = TemplateColorScheme(
  background: Color(0xFF1A0B2E),
  surface: Color(0xFF2D1B4E),
  primary: Color(0xFFEAB308),
  secondary: Color(0xFFD946EF),
  accent: Color(0xFFF97316),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFD4D4D8),
  gradient: [Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF4C1D95)],
);

const _partyEventFontPair = FontPair(
  heading: 'Poppins',
  body: 'Inter',
  accent: 'Montserrat',
);

const _cleanAcademicColorScheme = TemplateColorScheme(
  background: Color(0xFFF8FAFC),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E40AF),
  secondary: Color(0xFF3B82F6),
  accent: Color(0xFF60A5FA),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF475569),
  gradient: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
);

const _cleanAcademicFontPair = FontPair(
  heading: 'Merriweather',
  body: 'Open Sans',
  accent: 'Lato',
);

const _natureFreshColorScheme = TemplateColorScheme(
  background: Color(0xFFF0FDF4),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF166534),
  secondary: Color(0xFF22C55E),
  accent: Color(0xFF4ADE80),
  textPrimary: Color(0xFF14532D),
  textSecondary: Color(0xFF4B5563),
  gradient: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
);

const _natureFreshFontPair = FontPair(
  heading: 'Lora',
  body: 'Inter',
  accent: 'Montserrat',
);

const _darkEleganceColorScheme = TemplateColorScheme(
  background: Color(0xFF0F0F0F),
  surface: Color(0xFF1C1C1C),
  primary: Color(0xFFD4AF37),
  secondary: Color(0xFF8B7355),
  accent: Color(0xFFF5E6B8),
  textPrimary: Color(0xFFF0F0F0),
  textSecondary: Color(0xFFA0A0A0),
  gradient: [Color(0xFF0F0F0F), Color(0xFF1C1C1C), Color(0xFF2A2A2A)],
);

const _darkEleganceFontPair = FontPair(
  heading: 'Cormorant Garamond',
  body: 'Inter',
  accent: 'Montserrat',
);

const _pastelDreamColorScheme = TemplateColorScheme(
  background: Color(0xFFFDF4F5),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFF472B6),
  secondary: Color(0xFFF9A8D4),
  accent: Color(0xFFFBCFE8),
  textPrimary: Color(0xFF831843),
  textSecondary: Color(0xFF9D174D),
  gradient: [Color(0xFFFDF4F5), Color(0xFFFCE7F3)],
);

const _pastelDreamFontPair = FontPair(
  heading: 'Quicksand',
  body: 'Poppins',
  accent: 'Nunito',
);

const _urbanStreetColorScheme = TemplateColorScheme(
  background: Color(0xFF1A1A1A),
  surface: Color(0xFF2A2A2A),
  primary: Color(0xFFEF4444),
  secondary: Color(0xFFF97316),
  accent: Color(0xFFFBBF24),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF9CA3AF),
  gradient: [Color(0xFF1A1A1A), Color(0xFF2A2A2A), Color(0xFF3F3F46)],
);

const _urbanStreetFontPair = FontPair(
  heading: 'Bebas Neue',
  body: 'Inter',
  accent: 'Montserrat',
);

const _medicalCleanColorScheme = TemplateColorScheme(
  background: Color(0xFFF0F9FF),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF0284C7),
  secondary: Color(0xFF38BDF8),
  accent: Color(0xFF7DD3FC),
  textPrimary: Color(0xFF075985),
  textSecondary: Color(0xFF475569),
  gradient: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
);

const _medicalCleanFontPair = FontPair(
  heading: 'Nunito',
  body: 'Inter',
  accent: 'Open Sans',
);

const _creativeAgencyColorScheme = TemplateColorScheme(
  background: Color(0xFFFFFDF5),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF8B5CF6),
  secondary: Color(0xFFC4B5FD),
  accent: Color(0xFFA78BFA),
  textPrimary: Color(0xFF1E1B4B),
  textSecondary: Color(0xFF4C1D95),
  gradient: [Color(0xFFFFFDF5), Color(0xFFF5F3FF)],
);

const _creativeAgencyFontPair = FontPair(
  heading: 'DM Sans',
  body: 'Inter',
  accent: 'Poppins',
);

// Premium цветовые схемы
const _liveWebinarColorScheme = TemplateColorScheme(
  background: Color(0xFF0F172A),
  surface: Color(0xFF1E293B),
  primary: Color(0xFF3B82F6),
  secondary: Color(0xFF06B6D4),
  accent: Color(0xFF8B5CF6),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0EA5E9)],
);

const _liveWebinarFontPair = FontPair(
  heading: 'Poppins',
  body: 'Inter',
  accent: 'Space Grotesk',
);

const _corporateLuxuryColorScheme = TemplateColorScheme(
  background: Color(0xFF0A0A0A),
  surface: Color(0xFF1A1A1A),
  primary: Color(0xFFD4AF37),
  secondary: Color(0xFF808080),
  accent: Color(0xFFC0C0C0),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA3A3A3),
  gradient: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
);

const _modernGradientColorScheme = TemplateColorScheme(
  background: Color(0xFF4F46E5),
  surface: Color(0xFF6366F1),
  primary: Color(0xFF22D3EE),
  secondary: Color(0xFF818CF8),
  accent: Color(0xFFF472B6),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFC7D2FE),
  gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF22D3EE)],
);

const _bauhausStyleColorScheme = TemplateColorScheme(
  background: Color(0xFFFFF5E6),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFE53935),
  secondary: Color(0xFF1E88E5),
  accent: Color(0xFFFDD835),
  textPrimary: Color(0xFF212121),
  textSecondary: Color(0xFF757575),
  gradient: [Color(0xFFFFF5E6), Color(0xFFFFF0D4)],
);

const _cyberPunkColorScheme = TemplateColorScheme(
  background: Color(0xFF0D0D0D),
  surface: Color(0xFF1A1A2E),
  primary: Color(0xFF00FF9D),
  secondary: Color(0xFF00D9FF),
  accent: Color(0xFFFF007F),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFB0B0B0),
  gradient: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF2D0A4C)],
);

const _ecoGreenColorScheme = TemplateColorScheme(
  background: Color(0xFFF4F9F4),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF2E7D32),
  secondary: Color(0xFF43A047),
  accent: Color(0xFF81C784),
  textPrimary: Color(0xFF1B5E20),
  textSecondary: Color(0xFF558B2F),
  gradient: [Color(0xFFF4F9F4), Color(0xFFE8F5E9)],
);

const _luxuryFashionColorScheme = TemplateColorScheme(
  background: Color(0xFF1A1A1A),
  surface: Color(0xFF2D2D2D),
  primary: Color(0xFFE91E63),
  secondary: Color(0xFFF06292),
  accent: Color(0xFFF48FB1),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFBDBDBD),
  gradient: [Color(0xFF1A1A1A), Color(0xFF2D2D2D), Color(0xFF3E2723)],
);

const _spaceExplorationColorScheme = TemplateColorScheme(
  background: Color(0xFF0A0E27),
  surface: Color(0xFF1A1F3A),
  primary: Color(0xFF7C3AED),
  secondary: Color(0xFF06B6D4),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF3B0764)],
);

const _foodBeverageColorScheme = TemplateColorScheme(
  background: Color(0xFFFFF8F0),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFF97316),
  secondary: Color(0xFFFB923C),
  accent: Color(0xFFFDE047),
  textPrimary: Color(0xFF431407),
  textSecondary: Color(0xFF9A3412),
  gradient: [Color(0xFFFFF8F0), Color(0xFFFFF3E8)],
);

const _architecturePortfolioColorScheme = TemplateColorScheme(
  background: Color(0xFFF5F5F0),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF374151),
  secondary: Color(0xFF4B5563),
  accent: Color(0xFF6B7280),
  textPrimary: Color(0xFF111827),
  textSecondary: Color(0xFF6B7280),
  gradient: [Color(0xFFF5F5F0), Color(0xFFE5E5E0)],
);

const _sportsMotivationColorScheme = TemplateColorScheme(
  background: Color(0xFF0F172A),
  surface: Color(0xFF1E293B),
  primary: Color(0xFFEF4444),
  secondary: Color(0xFFF97316),
  accent: Color(0xFFFBBF24),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF7F1D1D)],
);

const _travelAdventureColorScheme = TemplateColorScheme(
  background: Color(0xFFE8F4F8),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF0891B2),
  secondary: Color(0xFF06B6D4),
  accent: Color(0xFF22D3EE),
  textPrimary: Color(0xFF164E63),
  textSecondary: Color(0xFF155E75),
  gradient: [Color(0xFFE8F4F8), Color(0xFFD9F1F5)],
);

const _artGalleryColorScheme = TemplateColorScheme(
  background: Color(0xFFFDFBF7),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFD4AF37),
  secondary: Color(0xFF8B7355),
  accent: Color(0xFFC19A6B),
  textPrimary: Color(0xFF2D2D2D),
  textSecondary: Color(0xFF6B6B6B),
  gradient: [Color(0xFFFDFBF7), Color(0xFFF5F0E8)],
);

const _scienceResearchColorScheme = TemplateColorScheme(
  background: Color(0xFFE8EAF6),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E88E5),
  secondary: Color(0xFF42A5F5),
  accent: Color(0xFF90CAF9),
  textPrimary: Color(0xFF0D47A1),
  textSecondary: Color(0xFF1565C0),
  gradient: [Color(0xFFE8EAF6), Color(0xFFE3F2FD)],
);

const _startupPitchColorScheme = TemplateColorScheme(
  background: Color(0xFFFFFFFF),
  surface: Color(0xFFF8FAFC),
  primary: Color(0xFF10B981),
  secondary: Color(0xFF34D399),
  accent: Color(0xFF6EE7B7),
  textPrimary: Color(0xFF064E3B),
  textSecondary: Color(0xFF047857),
  gradient: [Color(0xFFFFFFFF), Color(0xFFF0FDF4)],
);

const _legalLawColorScheme = TemplateColorScheme(
  background: Color(0xFFF5F2EB),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E3A5F),
  secondary: Color(0xFF2C4C6E),
  accent: Color(0xFFD4AF37),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF334155),
  gradient: [Color(0xFFF5F2EB), Color(0xFFEDE8E3)],
);

const _musicFestivalColorScheme = TemplateColorScheme(
  background: Color(0xFF1A0B2E),
  surface: Color(0xFF2D1B4E),
  primary: Color(0xFFD946EF),
  secondary: Color(0xFFF43F5E),
  accent: Color(0xFFFBBF24),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFE2E8F0),
  gradient: [Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF701A75)],
);

const _realEstateColorScheme = TemplateColorScheme(
  background: Color(0xFFF8FAFC),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E40AF),
  secondary: Color(0xFF3B82F6),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF475569),
  gradient: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
);

const _fitnessWellnessColorScheme = TemplateColorScheme(
  background: Color(0xFFF0FDF4),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF059669),
  secondary: Color(0xFF10B981),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFF064E3B),
  textSecondary: Color(0xFF047857),
  gradient: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
);

const _charityColorScheme = TemplateColorScheme(
  background: Color(0xFFFEFCE8),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFEAB308),
  secondary: Color(0xFFFDE047),
  accent: Color(0xFFF97316),
  textPrimary: Color(0xFF422006),
  textSecondary: Color(0xFF854D0E),
  gradient: [Color(0xFFFEFCE8), Color(0xFFFEF9C3)],
);

// ═══════════════════════════════════════════════════════════════════════════════
// СТРУКТУРЫ СЛАЙДОВ ДЛЯ КАЖДОГО ШАБЛОНА
// ═══════════════════════════════════════════════════════════════════════════════

// Women Business - структура
const _womenBusinessLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Women Business',
    sampleContent: ['Профессиональная презентация для бизнес-леди'],
  ),
  SlideLayout(
    id: 'about',
    name: 'О компании',
    type: 'content',
    sampleTitle: 'О компании',
    sampleContent: ['Наша миссия - помогать женщинам достигать успеха', '10+ лет на рынке', '1000+ довольных клиентов'],
  ),
  SlideLayout(
    id: 'services',
    name: 'Услуги',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Наши услуги',
    sampleContent: ['Консалтинг', 'Обучение', 'Менторство', 'Нетворкинг'],
  ),
  SlideLayout(
    id: 'team',
    name: 'Команда',
    type: 'image_right',
    imagePosition: 'right',
    sampleTitle: 'Наша команда',
    sampleContent: ['Профессионалы с опытом более 10 лет', 'Эксперты в своих областях', 'Готовы помочь вам'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Спасибо за внимание!',
    sampleContent: ['Контакты: info@womenbusiness.ru'],
  ),
];

// Tech Minimal - структура
const _techMinimalLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Tech Minimal',
    sampleContent: ['Инновационные технологические решения'],
  ),
  SlideLayout(
    id: 'problem',
    name: 'Проблема',
    type: 'content',
    sampleTitle: 'С какими проблемами сталкиваются компании?',
    sampleContent: ['Устаревшее программное обеспечение', 'Низкая эффективность процессов', 'Высокие операционные затраты'],
  ),
  SlideLayout(
    id: 'solution',
    name: 'Решение',
    type: 'image_left',
    imagePosition: 'left',
    sampleTitle: 'Наше решение',
    sampleContent: ['Современная облачная платформа', 'Автоматизация бизнес-процессов', 'Снижение затрат до 40%'],
  ),
  SlideLayout(
    id: 'features',
    name: 'Особенности',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Ключевые особенности',
    sampleContent: ['Высокая скорость', 'Максимальная безопасность', 'Лёгкая масштабируемость', 'Поддержка 24/7'],
  ),
  SlideLayout(
    id: 'roadmap',
    name: 'План',
    type: 'content',
    sampleTitle: 'Дорожная карта',
    sampleContent: ['Q1 2024: Запуск бета-версии', 'Q2 2024: Интеграция с CRM', 'Q3 2024: Выход на международный рынок'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Готовы к цифровой трансформации?',
    sampleContent: ['contact@techminimal.com'],
  ),
];

// Party Event - структура
const _partyEventLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'PARTY EVENT',
    sampleContent: ['Лучшие мероприятия в городе'],
  ),
  SlideLayout(
    id: 'info',
    name: 'Информация',
    type: 'image_right',
    imagePosition: 'right',
    sampleTitle: 'О мероприятии',
    sampleContent: ['Дата: 25 декабря 2024', 'Время: 20:00', 'Место: Клуб "Атмосфера"'],
  ),
  SlideLayout(
    id: 'program',
    name: 'Программа',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Программа вечера',
    sampleContent: ['20:00 Встреча гостей', '21:00 Выступление диджея', '22:00 Шоу-программа', '00:00 Фейерверк'],
  ),
  SlideLayout(
    id: 'tickets',
    name: 'Билеты',
    type: 'content',
    sampleTitle: 'Стоимость билетов',
    sampleContent: ['Стандарт - 2000₽', 'VIP - 5000₽', 'Вход до 23:00'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Ждём вас!',
    sampleContent: ['Билеты на сайте party-event.ru'],
  ),
];

// Clean Academic - структура
const _cleanAcademicLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Академическая презентация',
    sampleContent: ['Научное исследование'],
  ),
  SlideLayout(
    id: 'intro',
    name: 'Введение',
    type: 'content',
    sampleTitle: 'Введение',
    sampleContent: ['Актуальность исследования', 'Цели и задачи', 'Объект и предмет исследования'],
  ),
  SlideLayout(
    id: 'methodology',
    name: 'Методология',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Методы исследования',
    sampleContent: ['Анализ литературы', 'Эксперимент', 'Наблюдение', 'Статистический анализ'],
  ),
  SlideLayout(
    id: 'results',
    name: 'Результаты',
    type: 'content',
    sampleTitle: 'Полученные результаты',
    sampleContent: ['Результат 1: подтверждение гипотезы', 'Результат 2: новые данные', 'Результат 3: практические рекомендации'],
  ),
  SlideLayout(
    id: 'conclusion',
    name: 'Заключение',
    type: 'thanks',
    sampleTitle: 'Спасибо за внимание!',
    sampleContent: ['Вопросы?', 'email@university.ru'],
  ),
];

// Nature Fresh - структура
const _natureFreshLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Nature Fresh',
    sampleContent: ['Экологически чистые продукты'],
  ),
  SlideLayout(
    id: 'about',
    name: 'О нас',
    type: 'image_left',
    imagePosition: 'left',
    sampleTitle: 'Кто мы?',
    sampleContent: ['Фермерское хозяйство с 2010 года', 'Выращиваем натуральные продукты', 'Без ГМО и химикатов'],
  ),
  SlideLayout(
    id: 'products',
    name: 'Продукты',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Наша продукция',
    sampleContent: ['Овощи', 'Фрукты', 'Зелень', 'Ягоды'],
  ),
  SlideLayout(
    id: 'delivery',
    name: 'Доставка',
    type: 'image_right',
    imagePosition: 'right',
    sampleTitle: 'Доставка по городу',
    sampleContent: ['Бесплатная доставка от 1000₽', 'Свежесть гарантируем', 'Эко-упаковка'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Выбирайте здоровое питание!',
    sampleContent: ['nature-fresh.ru'],
  ),
];

// Dark Elegance - структура
const _darkEleganceLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Dark Elegance',
    sampleContent: ['Премиальный бренд'],
  ),
  SlideLayout(
    id: 'philosophy',
    name: 'Философия',
    type: 'content',
    sampleTitle: 'Наша философия',
    sampleContent: ['Роскошь в деталях', 'Индивидуальный подход', 'Безупречный сервис'],
  ),
  SlideLayout(
    id: 'collection',
    name: 'Коллекция',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Новая коллекция',
    sampleContent: ['Осень-Зима 2024', 'Лимитированные позиции', 'Эксклюзивные материалы', 'Ручная работа'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Подпишитесь на новости',
    sampleContent: ['darkelegance.com'],
  ),
];

// Pastel Dream - структура
const _pastelDreamLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Pastel Dream',
    sampleContent: ['Творческая студия'],
  ),
  SlideLayout(
    id: 'portfolio',
    name: 'Портфолио',
    type: 'image_top',
    imagePosition: 'top',
    sampleTitle: 'Наши работы',
    sampleContent: ['Дизайн сайтов', 'Иллюстрации', 'Брендинг', 'Упаковка'],
  ),
  SlideLayout(
    id: 'services',
    name: 'Услуги',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Что мы предлагаем',
    sampleContent: ['Веб-дизайн', 'Графический дизайн', 'Анимация', 'Фирменный стиль'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Давайте создавать красивое вместе!',
    sampleContent: ['hello@pasteldream.com'],
  ),
];

// Urban Street - структура
const _urbanStreetLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'URBAN STREET',
    sampleContent: ['Уличная культура'],
  ),
  SlideLayout(
    id: 'brand',
    name: 'Бренд',
    type: 'image_right',
    imagePosition: 'right',
    sampleTitle: 'О бренде',
    sampleContent: ['Одежда для города', 'Уличный стиль', 'Коллаборации с художниками'],
  ),
  SlideLayout(
    id: 'lookbook',
    name: 'Lookbook',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Новая коллекция',
    sampleContent: ['Футболки', 'Худи', 'Аксессуары', 'Лимитированные дропы'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Будь в центре событий',
    sampleContent: ['urbanstreet.com'],
  ),
];

// Medical Clean - структура
const _medicalCleanLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Medical Clean',
    sampleContent: ['Медицинский центр'],
  ),
  SlideLayout(
    id: 'about',
    name: 'О центре',
    type: 'content',
    sampleTitle: 'О медицинском центре',
    sampleContent: ['Современное оборудование', 'Квалифицированные врачи', 'Комфортные условия'],
  ),
  SlideLayout(
    id: 'services',
    name: 'Услуги',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Направления',
    sampleContent: ['Терапия', 'Кардиология', 'Неврология', 'Диагностика'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Ваше здоровье - наша забота',
    sampleContent: ['Запись по телефону: +7 (xxx) xxx-xx-xx'],
  ),
];

// Creative Agency - структура
const _creativeAgencyLayouts = [
  SlideLayout(
    id: 'title',
    name: 'Титульный',
    type: 'title',
    sampleTitle: 'Creative Agency',
    sampleContent: ['Креативное агентство полного цикла'],
  ),
  SlideLayout(
    id: 'approach',
    name: 'Подход',
    type: 'image_left',
    imagePosition: 'left',
    sampleTitle: 'Наш подход',
    sampleContent: ['Креативные стратегии', 'Индивидуальное решение', 'Измеримые результаты'],
  ),
  SlideLayout(
    id: 'services',
    name: 'Услуги',
    type: 'two_columns',
    columns: 2,
    sampleTitle: 'Что мы делаем',
    sampleContent: ['Реклама', 'SMM', 'Брендинг', 'Стратегия'],
  ),
  SlideLayout(
    id: 'thanks',
    name: 'Спасибо',
    type: 'thanks',
    sampleTitle: 'Воплотим идеи в жизнь',
    sampleContent: ['hello@creative.agency'],
  ),
];

// Premium шаблоны - структуры (упрощенные для краткости)
const _liveWebinarLayouts = _techMinimalLayouts;
const _corporateLuxuryLayouts = _darkEleganceLayouts;
const _modernGradientLayouts = _techMinimalLayouts;
const _bauhausStyleLayouts = _creativeAgencyLayouts;
const _cyberPunkLayouts = _techMinimalLayouts;
const _ecoGreenLayouts = _natureFreshLayouts;
const _luxuryFashionLayouts = _darkEleganceLayouts;
const _spaceExplorationLayouts = _techMinimalLayouts;
const _foodBeverageLayouts = _partyEventLayouts;
const _architecturePortfolioLayouts = _cleanAcademicLayouts;
const _sportsMotivationLayouts = _urbanStreetLayouts;
const _travelAdventureLayouts = _natureFreshLayouts;
const _artGalleryLayouts = _creativeAgencyLayouts;
const _scienceResearchLayouts = _cleanAcademicLayouts;
const _startupPitchLayouts = _techMinimalLayouts;
const _legalLawLayouts = _cleanAcademicLayouts;
const _musicFestivalLayouts = _partyEventLayouts;
const _realEstateLayouts = _cleanAcademicLayouts;
const _fitnessWellnessLayouts = _natureFreshLayouts;
const _charityLayouts = _creativeAgencyLayouts;

// ═══════════════════════════════════════════════════════════════════════════════
// ВСЕ 30 ШАБЛОНОВ
// ═══════════════════════════════════════════════════════════════════════════════

const List<DesignTemplate> allDesignTemplates = [
  // БЕСПЛАТНЫЕ (10)
  DesignTemplate(
    id: 'women_business',
    name: 'Women Business',
    description: 'Элегантный профессиональный шаблон',
    category: 'business',
    previewUrl: 'assets/templates/women_business.jpg',
    isPremium: false,
    colorScheme: _womenBusinessColorScheme,
    fontPair: _womenBusinessFontPair,
    layouts: _womenBusinessLayouts,
    slideCount: 5,
    icon: Icons.people_rounded,
  ),
  DesignTemplate(
    id: 'tech_minimal',
    name: 'Tech Minimal',
    description: 'Минималистичный технологичный шаблон',
    category: 'technology',
    previewUrl: 'assets/templates/tech_minimal.jpg',
    isPremium: false,
    colorScheme: _techMinimalColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.computer_rounded,
  ),
  DesignTemplate(
    id: 'party_event',
    name: 'Party Event',
    description: 'Яркий праздничный шаблон',
    category: 'events',
    previewUrl: 'assets/templates/party_event.jpg',
    isPremium: false,
    colorScheme: _partyEventColorScheme,
    fontPair: _partyEventFontPair,
    layouts: _partyEventLayouts,
    slideCount: 5,
    icon: Icons.celebration_rounded,
  ),
  DesignTemplate(
    id: 'clean_academic',
    name: 'Clean Academic',
    description: 'Чистый академический шаблон',
    category: 'education',
    previewUrl: 'assets/templates/clean_academic.jpg',
    isPremium: false,
    colorScheme: _cleanAcademicColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _cleanAcademicLayouts,
    slideCount: 5,
    icon: Icons.school_rounded,
  ),
  DesignTemplate(
    id: 'nature_fresh',
    name: 'Nature Fresh',
    description: 'Свежий природный шаблон',
    category: 'nature',
    previewUrl: 'assets/templates/nature_fresh.jpg',
    isPremium: false,
    colorScheme: _natureFreshColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _natureFreshLayouts,
    slideCount: 5,
    icon: Icons.eco_rounded,
  ),
  DesignTemplate(
    id: 'dark_elegance',
    name: 'Dark Elegance',
    description: 'Тёмный элегантный шаблон',
    category: 'business',
    previewUrl: 'assets/templates/dark_elegance.jpg',
    isPremium: false,
    colorScheme: _darkEleganceColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _darkEleganceLayouts,
    slideCount: 4,
    icon: Icons.stars_rounded,
  ),
  DesignTemplate(
    id: 'pastel_dream',
    name: 'Pastel Dream',
    description: 'Мягкий пастельный шаблон',
    category: 'creative',
    previewUrl: 'assets/templates/pastel_dream.jpg',
    isPremium: false,
    colorScheme: _pastelDreamColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _pastelDreamLayouts,
    slideCount: 4,
    icon: Icons.palette_rounded,
  ),
  DesignTemplate(
    id: 'urban_street',
    name: 'Urban Street',
    description: 'Смелый урбанистический шаблон',
    category: 'creative',
    previewUrl: 'assets/templates/urban_street.jpg',
    isPremium: false,
    colorScheme: _urbanStreetColorScheme,
    fontPair: _urbanStreetFontPair,
    layouts: _urbanStreetLayouts,
    slideCount: 4,
    icon: Icons.style_rounded,
  ),
  DesignTemplate(
    id: 'medical_clean',
    name: 'Medical Clean',
    description: 'Чистый медицинский шаблон',
    category: 'medical',
    previewUrl: 'assets/templates/medical_clean.jpg',
    isPremium: false,
    colorScheme: _medicalCleanColorScheme,
    fontPair: _medicalCleanFontPair,
    layouts: _medicalCleanLayouts,
    slideCount: 4,
    icon: Icons.medical_services_rounded,
  ),
  DesignTemplate(
    id: 'creative_agency',
    name: 'Creative Agency',
    description: 'Креативный агентский шаблон',
    category: 'business',
    previewUrl: 'assets/templates/creative_agency.jpg',
    isPremium: false,
    colorScheme: _creativeAgencyColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _creativeAgencyLayouts,
    slideCount: 4,
    icon: Icons.brush_rounded,
  ),

  // ПЛАТНЫЕ PREMIUM (20)
  DesignTemplate(
    id: 'live_webinar',
    name: 'Live Webinar',
    description: 'Современный шаблон для онлайн-мероприятий (Premium)',
    category: 'technology',
    previewUrl: 'assets/templates/live_webinar.jpg',
    isPremium: true,
    colorScheme: _liveWebinarColorScheme,
    fontPair: _liveWebinarFontPair,
    layouts: _liveWebinarLayouts,
    slideCount: 6,
    icon: Icons.videocam_rounded,
  ),
  DesignTemplate(
    id: 'corporate_luxury',
    name: 'Corporate Luxury',
    description: 'Премиальный корпоративный шаблон (Premium)',
    category: 'business',
    previewUrl: 'assets/templates/corporate_luxury.jpg',
    isPremium: true,
    colorScheme: _corporateLuxuryColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _corporateLuxuryLayouts,
    slideCount: 4,
    icon: Icons.workspace_premium_rounded,
  ),
  DesignTemplate(
    id: 'modern_gradient',
    name: 'Modern Gradient',
    description: 'Современный градиентный дизайн (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/modern_gradient.jpg',
    isPremium: true,
    colorScheme: _modernGradientColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _modernGradientLayouts,
    slideCount: 6,
    icon: Icons.gradient_rounded,
  ),
  DesignTemplate(
    id: 'bauhaus_style',
    name: 'Bauhaus Style',
    description: 'Стиль Баухаус для креативных презентаций (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/bauhaus_style.jpg',
    isPremium: true,
    colorScheme: _bauhausStyleColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _bauhausStyleLayouts,
    slideCount: 4,
    icon: Icons.art_track_rounded,
  ),
  DesignTemplate(
    id: 'cyber_punk',
    name: 'Cyber Punk',
    description: 'Киберпанк стиль для технологических презентаций (Premium)',
    category: 'technology',
    previewUrl: 'assets/templates/cyber_punk.jpg',
    isPremium: true,
    colorScheme: _cyberPunkColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _cyberPunkLayouts,
    slideCount: 6,
    icon: Icons.science_rounded,
  ),
  DesignTemplate(
    id: 'eco_green',
    name: 'Eco Green',
    description: 'Экологический шаблон (Premium)',
    category: 'nature',
    previewUrl: 'assets/templates/eco_green.jpg',
    isPremium: true,
    colorScheme: _ecoGreenColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _ecoGreenLayouts,
    slideCount: 5,
    icon: Icons.eco_rounded,
  ),
  DesignTemplate(
    id: 'luxury_fashion',
    name: 'Luxury Fashion',
    description: 'Модный люксовый шаблон (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/luxury_fashion.jpg',
    isPremium: true,
    colorScheme: _luxuryFashionColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _luxuryFashionLayouts,
    slideCount: 4,
    icon: Icons.style_rounded,
  ),
  DesignTemplate(
    id: 'space_exploration',
    name: 'Space Exploration',
    description: 'Космическая тема (Premium)',
    category: 'technology',
    previewUrl: 'assets/templates/space_exploration.jpg',
    isPremium: true,
    colorScheme: _spaceExplorationColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _spaceExplorationLayouts,
    slideCount: 6,
    icon: Icons.rocket_launch_rounded,
  ),
  DesignTemplate(
    id: 'food_beverage',
    name: 'Food & Beverage',
    description: 'Аппетитный шаблон (Premium)',
    category: 'business',
    previewUrl: 'assets/templates/food_beverage.jpg',
    isPremium: true,
    colorScheme: _foodBeverageColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _foodBeverageLayouts,
    slideCount: 5,
    icon: Icons.restaurant_rounded,
  ),
  DesignTemplate(
    id: 'architecture_portfolio',
    name: 'Architecture',
    description: 'Минималистичный шаблон для архитекторов (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/architecture_portfolio.jpg',
    isPremium: true,
    colorScheme: _architecturePortfolioColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _architecturePortfolioLayouts,
    slideCount: 5,
    icon: Icons.architecture_rounded,
  ),
  DesignTemplate(
    id: 'sports_motivation',
    name: 'Sports Motivation',
    description: 'Энергичный шаблон для спорта (Premium)',
    category: 'events',
    previewUrl: 'assets/templates/sports_motivation.jpg',
    isPremium: true,
    colorScheme: _sportsMotivationColorScheme,
    fontPair: _urbanStreetFontPair,
    layouts: _sportsMotivationLayouts,
    slideCount: 4,
    icon: Icons.sports_soccer_rounded,
  ),
  DesignTemplate(
    id: 'travel_adventure',
    name: 'Travel Adventure',
    description: 'Вдохновляющий шаблон для путешествий (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/travel_adventure.jpg',
    isPremium: true,
    colorScheme: _travelAdventureColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _travelAdventureLayouts,
    slideCount: 5,
    icon: Icons.flight_rounded,
  ),
  DesignTemplate(
    id: 'art_gallery',
    name: 'Art Gallery',
    description: 'Художественный шаблон для галерей (Premium)',
    category: 'creative',
    previewUrl: 'assets/templates/art_gallery.jpg',
    isPremium: true,
    colorScheme: _artGalleryColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _artGalleryLayouts,
    slideCount: 4,
    icon: Icons.museum_rounded,
  ),
  DesignTemplate(
    id: 'science_research',
    name: 'Science & Research',
    description: 'Научный шаблон (Premium)',
    category: 'education',
    previewUrl: 'assets/templates/science_research.jpg',
    isPremium: true,
    colorScheme: _scienceResearchColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _scienceResearchLayouts,
    slideCount: 5,
    icon: Icons.biotech_rounded,
  ),
  DesignTemplate(
    id: 'startup_pitch',
    name: 'Startup Pitch',
    description: 'Шаблон для питча инвесторам (Premium)',
    category: 'business',
    previewUrl: 'assets/templates/startup_pitch.jpg',
    isPremium: true,
    colorScheme: _startupPitchColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _startupPitchLayouts,
    slideCount: 6,
    icon: Icons.rocket_launch_rounded,
  ),
  DesignTemplate(
    id: 'legal_law',
    name: 'Legal & Law',
    description: 'Юридический шаблон (Premium)',
    category: 'business',
    previewUrl: 'assets/templates/legal_law.jpg',
    isPremium: true,
    colorScheme: _legalLawColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _legalLawLayouts,
    slideCount: 5,
    icon: Icons.gavel_rounded,
  ),
  DesignTemplate(
    id: 'music_festival',
    name: 'Music Festival',
    description: 'Шаблон для музыкальных фестивалей (Premium)',
    category: 'events',
    previewUrl: 'assets/templates/music_festival.jpg',
    isPremium: true,
    colorScheme: _musicFestivalColorScheme,
    fontPair: _partyEventFontPair,
    layouts: _musicFestivalLayouts,
    slideCount: 5,
    icon: Icons.music_note_rounded,
  ),
  DesignTemplate(
    id: 'real_estate',
    name: 'Real Estate',
    description: 'Шаблон для недвижимости (Premium)',
    category: 'business',
    previewUrl: 'assets/templates/real_estate.jpg',
    isPremium: true,
    colorScheme: _realEstateColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _realEstateLayouts,
    slideCount: 5,
    icon: Icons.home_work_rounded,
  ),
  DesignTemplate(
    id: 'fitness_wellness',
    name: 'Fitness & Wellness',
    description: 'Шаблон для фитнеса и здоровья (Premium)',
    category: 'health',
    previewUrl: 'assets/templates/fitness_wellness.jpg',
    isPremium: true,
    colorScheme: _fitnessWellnessColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _fitnessWellnessLayouts,
    slideCount: 5,
    icon: Icons.fitness_center_rounded,
  ),
  DesignTemplate(
    id: 'charity_nonprofit',
    name: 'Charity & Non-profit',
    description: 'Шаблон для благотворительности (Premium)',
    category: 'events',
    previewUrl: 'assets/templates/charity_nonprofit.jpg',
    isPremium: true,
    colorScheme: _charityColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _charityLayouts,
    slideCount: 4,
    icon: Icons.favorite_rounded,
  ),
];

// Экспорт для использования
final List<DesignTemplate> allPremiumTemplates = allDesignTemplates.where((t) => t.isPremium).toList();
final List<DesignTemplate> allFreeTemplates = allDesignTemplates.where((t) => !t.isPremium).toList();