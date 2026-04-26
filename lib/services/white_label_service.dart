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
  /// Применяет White-label конфигурацию к теме
  static ThemeData applyWhiteLabel(ThemeData baseTheme, WhiteLabelConfig config) {
    return baseTheme.copyWith(
      primaryColor: config.primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: config.primaryColor,
        secondary: config.secondaryColor ?? config.primaryColor,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
        ),
      ),
    );
  }

  /// Возвращает кастомизированный логотип
  static Widget buildLogo(WhiteLabelConfig config, {double size = 32}) {
    if (config.logoUrl != null && config.logoUrl!.isNotEmpty) {
      return Image.network(
        config.logoUrl!,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildDefaultLogo(config, size),
      );
    }
    return _buildDefaultLogo(config, size);
  }

  static Widget _buildDefaultLogo(WhiteLabelConfig config, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.primaryColor,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          config.companyName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Возвращает кастомизированный футер
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

  /// Тарифы White-label
  static final Map<String, WhiteLabelConfig> plans = {
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
  };
}