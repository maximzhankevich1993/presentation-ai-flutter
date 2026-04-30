import 'dart:math';
import 'package:flutter/material.dart';

class CorporatePlan {
  final String id;
  final String name;
  final String price;
  final String audience;
  final int users;
  final List<String> features;
  final List<String> integrations;
  final String supportLevel;
  final bool onPremise;

  const CorporatePlan({
    required this.id,
    required this.name,
    required this.price,
    required this.audience,
    required this.users,
    required this.features,
    required this.integrations,
    required this.supportLevel,
    this.onPremise = false,
  });
}

class CountryBusiness {
  final String countryCode;
  final String countryName;
  final String currency;
  final String currencySymbol;
  final List<String> integrations;
  final List<String> documentTypes;
  final List<String> compliance;
  final String taxSystem;
  final String reportStandard;

  const CountryBusiness({
    required this.countryCode,
    required this.countryName,
    required this.currency,
    required this.currencySymbol,
    required this.integrations,
    required this.documentTypes,
    required this.compliance,
    required this.taxSystem,
    required this.reportStandard,
  });
}

class CorporateService {
  static final Map<String, CountryBusiness> _countries = {
    // без изменений (сокращено в выводе)
  };

  static final Map<String, CorporatePlan> _basePlans = {
    // без изменений (сокращено в выводе)
  };

  static CountryBusiness? getCountry(String countryCode) {
    return _countries[countryCode.toUpperCase()];
  }

  static Map<String, CorporatePlan> getPlansForCountry(String countryCode) {
    final country = getCountry(countryCode);

    // создаём новый map (без мутаций исходного)
    final plans = <String, CorporatePlan>{};

    if (country == null) {
      return _basePlans;
    }

    final priceMultiplier = _getPriceMultiplier(countryCode);

    for (final plan in _basePlans.values) {
      final basePrice = _safeParsePrice(plan.price);
      final localPrice = (basePrice * priceMultiplier).round();

      plans[plan.id] = CorporatePlan(
        id: plan.id,
        name: plan.name,
        price: '${country.currencySymbol}$localPrice',
        audience: plan.audience,
        users: plan.users,
        features: plan.features,
        integrations: country.integrations,
        supportLevel: plan.supportLevel,
        onPremise: plan.onPremise,
      );
    }

    return plans;
  }

  /// безопасный парсер цены
  static double _safeParsePrice(String price) {
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static List<String> getDocumentTypes(String countryCode) {
    return getCountry(countryCode)?.documentTypes ??
        ['Sales Deck', 'Report', 'SOP'];
  }

  static List<String> getCompliance(String countryCode) {
    return getCountry(countryCode)?.compliance ?? ['GDPR'];
  }

  static double _getPriceMultiplier(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'RU':
      case 'BY':
      case 'KZ':
        return 0.5;
      case 'IN':
        return 0.3;
      case 'BR':
        return 0.6;
      default:
        return 1.0;
    }
  }

  static Map<String, dynamic> generateDocument({
    required String documentType,
    required String companyName,
    required String countryCode,
    String? topic,
  }) {
    final country = getCountry(countryCode);

    return {
      'document_type': documentType,
      'company': companyName,
      'country': country?.countryName ?? countryCode,
      'currency': country?.currency ?? 'USD',
      'tax_system': country?.taxSystem ?? 'Standard',
      'compliance_notes': country?.compliance ?? [],
      'generated_at': DateTime.now().toIso8601String(),
      'slides': _generateSlides(documentType, companyName),
    };
  }

  static List<Map<String, String>> _generateSlides(
    String type,
    String company,
  ) {
    switch (type) {
      case 'Коммерческое предложение':
        return [
          {'title': 'Коммерческое предложение', 'content': '$company представляет'},
          {'title': 'О компании', 'content': 'Краткая информация о $company'},
          {'title': 'Продукт/Услуга', 'content': 'Описание предложения'},
          {'title': 'Преимущества', 'content': 'Почему выбирают нас'},
          {'title': 'Стоимость', 'content': 'Условия и цены'},
          {'title': 'Контакты', 'content': 'Свяжитесь с нами'},
        ];

      case 'Sales Deck':
        return [
          {'title': 'Sales Deck', 'content': '$company presents'},
          {'title': 'About Us', 'content': 'Company overview'},
          {'title': 'Market Opportunity', 'content': 'Why now?'},
          {'title': 'Our Solution', 'content': 'What we offer'},
          {'title': 'Pricing', 'content': 'Plans and options'},
          {'title': 'Next Steps', 'content': 'Contact us'},
        ];

      default:
        return [
          {'title': type, 'content': 'Generated for $company'},
          {'title': 'Overview', 'content': 'Key points'},
          {'title': 'Details', 'content': 'Specific information'},
          {'title': 'Summary', 'content': 'Conclusions'},
        ];
    }
  }
}