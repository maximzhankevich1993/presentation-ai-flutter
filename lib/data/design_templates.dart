import 'package:flutter/material.dart';
import '../models/design_template.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 10 БЕСПЛАТНЫХ ДИЗАЙНЕРСКИХ ШАБЛОНОВ
// ═══════════════════════════════════════════════════════════════════════════════

// 1. Women Business (профессиональный, женский)
const _womenBusinessColorScheme = ColorScheme(
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

const _womenBusinessLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'two_columns', name: 'Две колонки', type: 'two_columns', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 2. Tech Minimal (технологичный, минималистичный)
const _techMinimalColorScheme = ColorScheme(
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

const _techMinimalLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'stats', name: 'Статистика', type: 'stats', decorations: []),
  SlideLayout(id: 'timeline', name: 'Таймлайн', type: 'timeline', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 3. Party Event (праздничный, яркий)
const _partyEventColorScheme = ColorScheme(
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

const _partyEventLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'image_text', name: 'Изображение + текст', type: 'image_text', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 4. Clean Academic (академический, чистый)
const _cleanAcademicColorScheme = ColorScheme(
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

const _cleanAcademicLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'two_columns', name: 'Две колонки', type: 'two_columns', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 5. Nature Fresh (природный, свежий)
const _natureFreshColorScheme = ColorScheme(
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

const _natureFreshLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'image_text', name: 'Изображение + текст', type: 'image_text', decorations: []),
  SlideLayout(id: 'stats', name: 'Статистика', type: 'stats', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 6. Dark Elegance (тёмный, элегантный)
const _darkEleganceColorScheme = ColorScheme(
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

const _darkEleganceLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'timeline', name: 'Таймлайн', type: 'timeline', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 7. Pastel Dream (пастельный, мягкий)
const _pastelDreamColorScheme = ColorScheme(
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

const _pastelDreamLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'image_text', name: 'Изображение + текст', type: 'image_text', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 8. Urban Street (урбанистический, смелый)
const _urbanStreetColorScheme = ColorScheme(
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

const _urbanStreetLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'stats', name: 'Статистика', type: 'stats', decorations: []),
  SlideLayout(id: 'two_columns', name: 'Две колонки', type: 'two_columns', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 9. Medical Clean (медицинский, чистый)
const _medicalCleanColorScheme = ColorScheme(
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

const _medicalCleanLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'stats', name: 'Статистика', type: 'stats', decorations: []),
  SlideLayout(id: 'two_columns', name: 'Две колонки', type: 'two_columns', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// 10. Creative Agency (креативный, агентский)
const _creativeAgencyColorScheme = ColorScheme(
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

const _creativeAgencyLayouts = [
  SlideLayout(id: 'title', name: 'Титульный', type: 'title', decorations: []),
  SlideLayout(id: 'content', name: 'Содержание', type: 'content', decorations: []),
  SlideLayout(id: 'image_text', name: 'Изображение + текст', type: 'image_text', decorations: []),
  SlideLayout(id: 'quote', name: 'Цитата', type: 'quote', decorations: []),
  SlideLayout(id: 'thanks', name: 'Спасибо', type: 'thanks', decorations: []),
];

// ═══════════════════════════════════════════════════════════════════════════════
// 20 ПЛАТНЫХ PREMIUM ДИЗАЙНЕРСКИХ ШАБЛОНОВ
// ═══════════════════════════════════════════════════════════════════════════════

// 11. Live Webinar (технологичный, для вебинаров)
const _liveWebinarColorScheme = ColorScheme(
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

// 12. Corporate Luxury (корпоративный, люкс)
const _corporateLuxuryColorScheme = ColorScheme(
  background: Color(0xFF0A0A0A),
  surface: Color(0xFF1A1A1A),
  primary: Color(0xFFD4AF37),
  secondary: Color(0xFF808080),
  accent: Color(0xFFC0C0C0),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFA3A3A3),
  gradient: [Color(0xFF0A0A0A), Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
);

// 13. Modern Gradient (современный градиент)
const _modernGradientColorScheme = ColorScheme(
  background: Color(0xFF4F46E5),
  surface: Color(0xFF6366F1),
  primary: Color(0xFF22D3EE),
  secondary: Color(0xFF818CF8),
  accent: Color(0xFFF472B6),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFC7D2FE),
  gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF22D3EE)],
);

// 14. Bauhaus Style (Баухаус)
const _bauhausStyleColorScheme = ColorScheme(
  background: Color(0xFFFFF5E6),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFE53935),
  secondary: Color(0xFF1E88E5),
  accent: Color(0xFFFDD835),
  textPrimary: Color(0xFF212121),
  textSecondary: Color(0xFF757575),
  gradient: [Color(0xFFFFF5E6), Color(0xFFFFF0D4)],
);

// 15. Cyber Punk (киберпанк)
const _cyberPunkColorScheme = ColorScheme(
  background: Color(0xFF0D0D0D),
  surface: Color(0xFF1A1A2E),
  primary: Color(0xFF00FF9D),
  secondary: Color(0xFF00D9FF),
  accent: Color(0xFFFF007F),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFB0B0B0),
  gradient: [Color(0xFF0D0D0D), Color(0xFF1A1A2E), Color(0xFF2D0A4C)],
);

// 16. Eco Green (эко, зелёный)
const _ecoGreenColorScheme = ColorScheme(
  background: Color(0xFFF4F9F4),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF2E7D32),
  secondary: Color(0xFF43A047),
  accent: Color(0xFF81C784),
  textPrimary: Color(0xFF1B5E20),
  textSecondary: Color(0xFF558B2F),
  gradient: [Color(0xFFF4F9F4), Color(0xFFE8F5E9)],
);

// 17. Luxury Fashion (люкс, мода)
const _luxuryFashionColorScheme = ColorScheme(
  background: Color(0xFF1A1A1A),
  surface: Color(0xFF2D2D2D),
  primary: Color(0xFFE91E63),
  secondary: Color(0xFFF06292),
  accent: Color(0xFFF48FB1),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFBDBDBD),
  gradient: [Color(0xFF1A1A1A), Color(0xFF2D2D2D), Color(0xFF3E2723)],
);

// 18. Space Exploration (космос)
const _spaceExplorationColorScheme = ColorScheme(
  background: Color(0xFF0A0E27),
  surface: Color(0xFF1A1F3A),
  primary: Color(0xFF7C3AED),
  secondary: Color(0xFF06B6D4),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0A0E27), Color(0xFF1A1F3A), Color(0xFF3B0764)],
);

// 19. Food & Beverage (еда и напитки)
const _foodBeverageColorScheme = ColorScheme(
  background: Color(0xFFFFF8F0),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFF97316),
  secondary: Color(0xFFFB923C),
  accent: Color(0xFFFDE047),
  textPrimary: Color(0xFF431407),
  textSecondary: Color(0xFF9A3412),
  gradient: [Color(0xFFFFF8F0), Color(0xFFFFF3E8)],
);

// 20. Architecture Portfolio (архитектура)
const _architecturePortfolioColorScheme = ColorScheme(
  background: Color(0xFFF5F5F0),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF374151),
  secondary: Color(0xFF4B5563),
  accent: Color(0xFF6B7280),
  textPrimary: Color(0xFF111827),
  textSecondary: Color(0xFF6B7280),
  gradient: [Color(0xFFF5F5F0), Color(0xFFE5E5E0)],
);

// 21. Sports Motivation (спорт, мотивация)
const _sportsMotivationColorScheme = ColorScheme(
  background: Color(0xFF0F172A),
  surface: Color(0xFF1E293B),
  primary: Color(0xFFEF4444),
  secondary: Color(0xFFF97316),
  accent: Color(0xFFFBBF24),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFF94A3B8),
  gradient: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF7F1D1D)],
);

// 22. Travel Adventure (путешествия)
const _travelAdventureColorScheme = ColorScheme(
  background: Color(0xFFE8F4F8),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF0891B2),
  secondary: Color(0xFF06B6D4),
  accent: Color(0xFF22D3EE),
  textPrimary: Color(0xFF164E63),
  textSecondary: Color(0xFF155E75),
  gradient: [Color(0xFFE8F4F8), Color(0xFFD9F1F5)],
);

// 23. Art Gallery (галерея)
const _artGalleryColorScheme = ColorScheme(
  background: Color(0xFFFDFBF7),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFFD4AF37),
  secondary: Color(0xFF8B7355),
  accent: Color(0xFFC19A6B),
  textPrimary: Color(0xFF2D2D2D),
  textSecondary: Color(0xFF6B6B6B),
  gradient: [Color(0xFFFDFBF7), Color(0xFFF5F0E8)],
);

// 24. Science & Research (наука)
const _scienceResearchColorScheme = ColorScheme(
  background: Color(0xFFE8EAF6),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E88E5),
  secondary: Color(0xFF42A5F5),
  accent: Color(0xFF90CAF9),
  textPrimary: Color(0xFF0D47A1),
  textSecondary: Color(0xFF1565C0),
  gradient: [Color(0xFFE8EAF6), Color(0xFFE3F2FD)],
);

// 25. Startup Pitch (стартап)
const _startupPitchColorScheme = ColorScheme(
  background: Color(0xFFFFFFFF),
  surface: Color(0xFFF8FAFC),
  primary: Color(0xFF10B981),
  secondary: Color(0xFF34D399),
  accent: Color(0xFF6EE7B7),
  textPrimary: Color(0xFF064E3B),
  textSecondary: Color(0xFF047857),
  gradient: [Color(0xFFFFFFFF), Color(0xFFF0FDF4)],
);

// 26. Legal & Law (юридический)
const _legalLawColorScheme = ColorScheme(
  background: Color(0xFFF5F2EB),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E3A5F),
  secondary: Color(0xFF2C4C6E),
  accent: Color(0xFFD4AF37),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF334155),
  gradient: [Color(0xFFF5F2EB), Color(0xFFEDE8E3)],
);

// 27. Music Festival (музыкальный фестиваль)
const _musicFestivalColorScheme = ColorScheme(
  background: Color(0xFF1A0B2E),
  surface: Color(0xFF2D1B4E),
  primary: Color(0xFFD946EF),
  secondary: Color(0xFFF43F5E),
  accent: Color(0xFFFBBF24),
  textPrimary: Color(0xFFFFFFFF),
  textSecondary: Color(0xFFE2E8F0),
  gradient: [Color(0xFF1A0B2E), Color(0xFF2D1B4E), Color(0xFF701A75)],
);

// 28. Real Estate (недвижимость)
const _realEstateColorScheme = ColorScheme(
  background: Color(0xFFF8FAFC),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF1E40AF),
  secondary: Color(0xFF3B82F6),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFF0F172A),
  textSecondary: Color(0xFF475569),
  gradient: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
);

// 29. Fitness & Wellness (фитнес)
const _fitnessWellnessColorScheme = ColorScheme(
  background: Color(0xFFF0FDF4),
  surface: Color(0xFFFFFFFF),
  primary: Color(0xFF059669),
  secondary: Color(0xFF10B981),
  accent: Color(0xFFF59E0B),
  textPrimary: Color(0xFF064E3B),
  textSecondary: Color(0xFF047857),
  gradient: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
);

// 30. Charity & Non-profit (благотворительность)
const _charityColorScheme = ColorScheme(
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
// СПИСОК ВСЕХ 30 ШАБЛОНОВ
// ═══════════════════════════════════════════════════════════════════════════════

const List<DesignTemplate> allDesignTemplates = [
  // БЕСПЛАТНЫЕ (10)
  DesignTemplate(
    id: 'women_business',
    name: 'Women Business',
    description: 'Элегантный профессиональный шаблон для женщин в бизнесе',
    category: 'business',
    previewUrl: '',
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
    description: 'Минималистичный технологичный шаблон для IT-презентаций',
    category: 'technology',
    previewUrl: '',
    isPremium: false,
    colorScheme: _techMinimalColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 5,
    icon: Icons.computer_rounded,
  ),
  DesignTemplate(
    id: 'party_event',
    name: 'Party Event',
    description: 'Яркий праздничный шаблон для мероприятий',
    category: 'events',
    previewUrl: '',
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
    description: 'Чистый академический шаблон для образования',
    category: 'education',
    previewUrl: '',
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
    description: 'Свежий природный шаблон с зелёными оттенками',
    category: 'nature',
    previewUrl: '',
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
    description: 'Тёмный элегантный шаблон для премиум-презентаций',
    category: 'business',
    previewUrl: '',
    isPremium: false,
    colorScheme: _darkEleganceColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _darkEleganceLayouts,
    slideCount: 5,
    icon: Icons.stars_rounded,
  ),
  DesignTemplate(
    id: 'pastel_dream',
    name: 'Pastel Dream',
    description: 'Мягкий пастельный шаблон для творческих проектов',
    category: 'creative',
    previewUrl: '',
    isPremium: false,
    colorScheme: _pastelDreamColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _pastelDreamLayouts,
    slideCount: 5,
    icon: Icons.palette_rounded,
  ),
  DesignTemplate(
    id: 'urban_street',
    name: 'Urban Street',
    description: 'Смелый урбанистический шаблон для молодёжных проектов',
    category: 'creative',
    previewUrl: '',
    isPremium: false,
    colorScheme: _urbanStreetColorScheme,
    fontPair: _urbanStreetFontPair,
    layouts: _urbanStreetLayouts,
    slideCount: 5,
    icon: Icons.style_rounded,
  ),
  DesignTemplate(
    id: 'medical_clean',
    name: 'Medical Clean',
    description: 'Чистый медицинский шаблон для презентаций',
    category: 'medical',
    previewUrl: '',
    isPremium: false,
    colorScheme: _medicalCleanColorScheme,
    fontPair: _medicalCleanFontPair,
    layouts: _medicalCleanLayouts,
    slideCount: 5,
    icon: Icons.medical_services_rounded,
  ),
  DesignTemplate(
    id: 'creative_agency',
    name: 'Creative Agency',
    description: 'Креативный агентский шаблон для дизайн-проектов',
    category: 'business',
    previewUrl: '',
    isPremium: false,
    colorScheme: _creativeAgencyColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _creativeAgencyLayouts,
    slideCount: 5,
    icon: Icons.brush_rounded,
  ),

  // ПЛАТНЫЕ PREMIUM (20)
  DesignTemplate(
    id: 'live_webinar',
    name: 'Live Webinar',
    description: 'Современный шаблон для онлайн-мероприятий (Premium)',
    category: 'technology',
    previewUrl: '',
    isPremium: true,
    colorScheme: _liveWebinarColorScheme,
    fontPair: _liveWebinarFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.videocam_rounded,
  ),
  DesignTemplate(
    id: 'corporate_luxury',
    name: 'Corporate Luxury',
    description: 'Премиальный корпоративный шаблон (Premium)',
    category: 'business',
    previewUrl: '',
    isPremium: true,
    colorScheme: _corporateLuxuryColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _darkEleganceLayouts,
    slideCount: 6,
    icon: Icons.workspace_premium_rounded,
  ),
  DesignTemplate(
    id: 'modern_gradient',
    name: 'Modern Gradient',
    description: 'Современный градиентный дизайн (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _modernGradientColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.gradient_rounded,
  ),
  DesignTemplate(
    id: 'bauhaus_style',
    name: 'Bauhaus Style',
    description: 'Стиль Баухаус для креативных презентаций (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _bauhausStyleColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _creativeAgencyLayouts,
    slideCount: 6,
    icon: Icons.art_track_rounded,
  ),
  DesignTemplate(
    id: 'cyber_punk',
    name: 'Cyber Punk',
    description: 'Киберпанк стиль для технологических презентаций (Premium)',
    category: 'technology',
    previewUrl: '',
    isPremium: true,
    colorScheme: _cyberPunkColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.science_rounded,
  ),
  DesignTemplate(
    id: 'eco_green',
    name: 'Eco Green',
    description: 'Экологический шаблон для устойчивого развития (Premium)',
    category: 'nature',
    previewUrl: '',
    isPremium: true,
    colorScheme: _ecoGreenColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _natureFreshLayouts,
    slideCount: 6,
    icon: Icons.eco_rounded,
  ),
  DesignTemplate(
    id: 'luxury_fashion',
    name: 'Luxury Fashion',
    description: 'Модный люксовый шаблон для брендов (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _luxuryFashionColorScheme,
    fontPair: _darkEleganceFontPair,
    layouts: _darkEleganceLayouts,
    slideCount: 6,
    icon: Icons.style_rounded,
  ),
  DesignTemplate(
    id: 'space_exploration',
    name: 'Space Exploration',
    description: 'Космическая тема для научных презентаций (Premium)',
    category: 'technology',
    previewUrl: '',
    isPremium: true,
    colorScheme: _spaceExplorationColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.rocket_launch_rounded,
  ),
  DesignTemplate(
    id: 'food_beverage',
    name: 'Food & Beverage',
    description: 'Аппетитный шаблон для ресторанов и кафе (Premium)',
    category: 'business',
    previewUrl: '',
    isPremium: true,
    colorScheme: _foodBeverageColorScheme,
    fontPair: _creativeAgencyFontPair,
    layouts: _creativeAgencyLayouts,
    slideCount: 6,
    icon: Icons.restaurant_rounded,
  ),
  DesignTemplate(
    id: 'architecture_portfolio',
    name: 'Architecture',
    description: 'Минималистичный шаблон для архитекторов (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _architecturePortfolioColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _cleanAcademicLayouts,
    slideCount: 6,
    icon: Icons.architecture_rounded,
  ),
  DesignTemplate(
    id: 'sports_motivation',
    name: 'Sports Motivation',
    description: 'Энергичный шаблон для спортивных презентаций (Premium)',
    category: 'events',
    previewUrl: '',
    isPremium: true,
    colorScheme: _sportsMotivationColorScheme,
    fontPair: _urbanStreetFontPair,
    layouts: _urbanStreetLayouts,
    slideCount: 6,
    icon: Icons.sports_soccer_rounded,
  ),
  DesignTemplate(
    id: 'travel_adventure',
    name: 'Travel Adventure',
    description: 'Вдохновляющий шаблон для туристических проектов (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _travelAdventureColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _natureFreshLayouts,
    slideCount: 6,
    icon: Icons.flight_rounded,
  ),
  DesignTemplate(
    id: 'art_gallery',
    name: 'Art Gallery',
    description: 'Художественный шаблон для галерей и выставок (Premium)',
    category: 'creative',
    previewUrl: '',
    isPremium: true,
    colorScheme: _artGalleryColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _pastelDreamLayouts,
    slideCount: 6,
    icon: Icons.museum_rounded,
  ),
  DesignTemplate(
    id: 'science_research',
    name: 'Science & Research',
    description: 'Научный шаблон для исследований и открытий (Premium)',
    category: 'education',
    previewUrl: '',
    isPremium: true,
    colorScheme: _scienceResearchColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _cleanAcademicLayouts,
    slideCount: 6,
    icon: Icons.biotech_rounded,
  ),
  DesignTemplate(
    id: 'startup_pitch',
    name: 'Startup Pitch',
    description: 'Современный шаблон для питча инвесторам (Premium)',
    category: 'business',
    previewUrl: '',
    isPremium: true,
    colorScheme: _startupPitchColorScheme,
    fontPair: _techMinimalFontPair,
    layouts: _techMinimalLayouts,
    slideCount: 6,
    icon: Icons.rocket_launch_rounded,
  ),
  DesignTemplate(
    id: 'legal_law',
    name: 'Legal & Law',
    description: 'Строгий юридический шаблон (Premium)',
    category: 'business',
    previewUrl: '',
    isPremium: true,
    colorScheme: _legalLawColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _cleanAcademicLayouts,
    slideCount: 6,
    icon: Icons.gavel_rounded,
  ),
  DesignTemplate(
    id: 'music_festival',
    name: 'Music Festival',
    description: 'Яркий шаблон для музыкальных фестивалей (Premium)',
    category: 'events',
    previewUrl: '',
    isPremium: true,
    colorScheme: _musicFestivalColorScheme,
    fontPair: _partyEventFontPair,
    layouts: _partyEventLayouts,
    slideCount: 6,
    icon: Icons.music_note_rounded,
  ),
  DesignTemplate(
    id: 'real_estate',
    name: 'Real Estate',
    description: 'Профессиональный шаблон для недвижимости (Premium)',
    category: 'business',
    previewUrl: '',
    isPremium: true,
    colorScheme: _realEstateColorScheme,
    fontPair: _cleanAcademicFontPair,
    layouts: _cleanAcademicLayouts,
    slideCount: 6,
    icon: Icons.home_work_rounded,
  ),
  DesignTemplate(
    id: 'fitness_wellness',
    name: 'Fitness & Wellness',
    description: 'Здоровый шаблон для фитнес-проектов (Premium)',
    category: 'health',
    previewUrl: '',
    isPremium: true,
    colorScheme: _fitnessWellnessColorScheme,
    fontPair: _natureFreshFontPair,
    layouts: _natureFreshLayouts,
    slideCount: 6,
    icon: Icons.fitness_center_rounded,
  ),
  DesignTemplate(
    id: 'charity_nonprofit',
    name: 'Charity & Non-profit',
    description: 'Вдохновляющий шаблон для благотворительности (Premium)',
    category: 'events',
    previewUrl: '',
    isPremium: true,
    colorScheme: _charityColorScheme,
    fontPair: _pastelDreamFontPair,
    layouts: _pastelDreamLayouts,
    slideCount: 6,
    icon: Icons.favorite_rounded,
  ),
];