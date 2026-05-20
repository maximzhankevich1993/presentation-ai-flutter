import 'package:flutter/material.dart';

/// Цветовая схема шаблона
class ColorScheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> gradient;

  const ColorScheme({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    this.gradient = const [],
  });

  Map<String, dynamic> toJson() => {
    'background': background.value,
    'surface': surface.value,
    'primary': primary.value,
    'secondary': secondary.value,
    'accent': accent.value,
    'textPrimary': textPrimary.value,
    'textSecondary': textSecondary.value,
    'gradient': gradient.map((c) => c.value).toList(),
  };
}

/// Шрифтовая пара
class FontPair {
  final String heading;
  final String body;
  final String accent;

  const FontPair({
    required this.heading,
    required this.body,
    required this.accent,
  });

  Map<String, dynamic> toJson() => {
    'heading': heading,
    'body': body,
    'accent': accent,
  };
}

/// Декоративный элемент (круги, линии, формы)
class DecorativeElement {
  final String type; // 'circle', 'line', 'dots', 'wave', 'blur', 'grid'
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final double opacity;

  const DecorativeElement({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.opacity = 0.3,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'color': color.value,
    'opacity': opacity,
  };
}

/// Макет слайда
class SlideLayout {
  final String id;
  final String name;
  final String type; // 'title', 'content', 'two_columns', 'image_text', 'quote', 'thanks', 'stats', 'timeline'
  final List<DecorativeElement> decorations;

  const SlideLayout({
    required this.id,
    required this.name,
    required this.type,
    this.decorations = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'decorations': decorations.map((d) => d.toJson()).toList(),
  };
}

/// Дизайнерский шаблон (полноценная тема)
class DesignTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String previewUrl;
  final bool isPremium;
  final ColorScheme colorScheme;
  final FontPair fontPair;
  final List<SlideLayout> layouts;
  final int slideCount;
  final IconData icon;

  const DesignTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.previewUrl,
    required this.isPremium,
    required this.colorScheme,
    required this.fontPair,
    required this.layouts,
    required this.slideCount,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'previewUrl': previewUrl,
    'isPremium': isPremium,
    'colorScheme': colorScheme.toJson(),
    'fontPair': fontPair.toJson(),
    'layouts': layouts.map((l) => l.toJson()).toList(),
    'slideCount': slideCount,
  };
}