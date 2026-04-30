import 'package:flutter/material.dart';

class WhiteLabelConfig {
  final String companyName;
  final String? logoUrl;
  final Color primaryColor;
  final Color? secondaryColor;
  final String? customDomain;
  final bool removeWatermark;
  final bool customEmails;
  final String plan;

  const WhiteLabelConfig({
    required this.companyName,
    this.logoUrl,
    required this.primaryColor,
    this.secondaryColor,
    this.customDomain,
    this.removeWatermark = true,
    this.customEmails = true,
    required this.plan,
  });
}

class WhiteLabelService {
  static ThemeData applyWhiteLabel(
    ThemeData baseTheme,
    WhiteLabelConfig config,
  ) {
    final secondary = config.secondaryColor ?? config.primaryColor;

    return baseTheme.copyWith(
      primaryColor: config.primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: config.primaryColor,
        secondary: secondary,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: config.primaryColor,
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          color: _getContrastColor(config.primaryColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return config.primaryColor.withOpacity(0.5);
            }
            if (states.contains(MaterialState.pressed)) {
              return config.primaryColor.withOpacity(0.8);
            }
            return config.primaryColor;
          }),
        ),
      ),
    );
  }

  /// Контрастный цвет текста
  static Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  static Widget buildLogo(WhiteLabelConfig config, {double size = 32}) {
    final url = config.logoUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildDefaultLogo(config, size),
      );
    }

    return _buildDefaultLogo(config, size);
  }

  static Widget _buildDefaultLogo(
      WhiteLabelConfig config, double size) {
    final name = config.companyName.trim();

    final letter =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.primaryColor,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget buildFooter(WhiteLabelConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '© ${DateTime.now().year} ${config.companyName}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (!config.removeWatermark)
            const Text(
              'Powered by Презентатор ИИ',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  static final Map<String, WhiteLabelConfig> plans =
      Map.unmodifiable({
    'starter': WhiteLabelConfig(
      companyName: 'Стартовый',
      primaryColor: const Color(0xFF4F46E5),
      plan: 'starter',
      removeWatermark: false,
      customEmails: false,
    ),
    'professional': WhiteLabelConfig(
      companyName: 'Профессиональный',
      primaryColor: const Color(0xFF0D9488),
      plan: 'professional',
      removeWatermark: true,
      customEmails: true,
    ),
    'enterprise': WhiteLabelConfig(
      companyName: 'Корпоративный',
      primaryColor: const Color(0xFF1E3A5F),
      plan: 'enterprise',
      removeWatermark: true,
      customEmails: true,
    ),
  });
}