import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class BrandKit {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final String fontHeading;
  final String fontBody;
  final String styleName;
  final List<String> colorPalette;

  const BrandKit({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.fontHeading,
    required this.fontBody,
    required this.styleName,
    required this.colorPalette,
  });
}

class BrandKitService {
  static final Random _random = Random();

  /// Анализирует логотип и создаёт бренд-кит
  static Future<BrandKit> generateFromImage(ui.Image logoImage) async {
    // В реальной версии: анализ доминирующих цветов из изображения
    // Сейчас: генерируем на основе случайного выбора с хорошим вкусом
    
    final palettes = [
      {
        'primary': const Color(0xFF4F46E5),
        'secondary': const Color(0xFF7C3AED),
        'accent': const Color(0xFFF59E0B),
        'background': const Color(0xFFFAFAFA),
        'style': 'Современный Tech',
        'heading': 'Poppins',
        'body': 'Inter',
      },
      {
        'primary': const Color(0xFF0D9488),
        'secondary': const Color(0xFF14B8A6),
        'accent': const Color(0xFFF97316),
        'background': const Color(0xFFFFFFFF),
        'style': 'Свежий Minimal',
        'heading': 'Inter',
        'body': 'Inter',
      },
      {
        'primary': const Color(0xFFDC2626),
        'secondary': const Color(0xFF991B1B),
        'accent': const Color(0xFFFCD34D),
        'background': const Color(0xFFFEF2F2),
        'style': 'Смелый Impact',
        'heading': 'Poppins',
        'body': 'Inter',
      },
      {
        'primary': const Color(0xFF1E3A5F),
        'secondary': const Color(0xFF2E5A88),
        'accent': const Color(0xFFD4AF37),
        'background': const Color(0xFFF8F9FA),
        'style': 'Классический Premium',
        'heading': 'Georgia',
        'body': 'Inter',
      },
    ];

    final palette = palettes[_random.nextInt(palettes.length)];

    return BrandKit(
      primaryColor: palette['primary'] as Color,
      secondaryColor: palette['secondary'] as Color,
      accentColor: palette['accent'] as Color,
      backgroundColor: palette['background'] as Color,
      fontHeading: palette['heading'] as String,
      fontBody: palette['body'] as String,
      styleName: palette['style'] as String,
      colorPalette: [
        palette['primary'] as Color,
        palette['secondary'] as Color,
        palette['accent'] as Color,
        palette['background'] as Color,
      ].map((c) => '#${c.value.toRadixString(16).substring(2).toUpperCase()}').toList(),
    );
  }

  /// Применяет бренд-кит к теме приложения
  static ThemeData applyBrandKit(BrandKit kit, bool isDark) {
    return ThemeData(
      primaryColor: kit.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kit.primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF1E1E2A) : kit.backgroundColor,
      fontFamily: kit.fontBody,
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          fontFamily: kit.fontHeading,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kit.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}