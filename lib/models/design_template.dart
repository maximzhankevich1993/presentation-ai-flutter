import 'package:flutter/material.dart';

class TemplateColorScheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final List<Color> gradient;

  const TemplateColorScheme({
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

class SlideLayout {
  final String id;
  final String name;
  final String type; // title, content, two_columns, image_left, image_right, image_top, image_bottom, quote, thanks
  final String? imagePosition;
  final int columns;
  final String sampleTitle;
  final List<String> sampleContent;

  const SlideLayout({
    required this.id,
    required this.name,
    required this.type,
    this.imagePosition,
    this.columns = 1,
    required this.sampleTitle,
    required this.sampleContent,
  });
}

class DesignTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final String previewUrl;
  final bool isPremium;
  final TemplateColorScheme colorScheme;
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
}