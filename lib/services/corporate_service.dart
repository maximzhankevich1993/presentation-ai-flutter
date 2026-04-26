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
  /// База бизнес-среды по странам
  static final Map<String, CountryBusiness> _countries = {
    'US': CountryBusiness(
      countryCode: 'US', countryName: 'США', currency: 'USD', currencySymbol: '\$',
      integrations: ['Salesforce', 'HubSpot', 'Slack', 'Zoom', 'Google Workspace', 'MS 365'],
      documentTypes: ['Sales Deck', 'Pitch Deck', 'Quarterly Report', 'OKR Review', 'SOP'],
      compliance: ['SOC 2', 'GDPR (EU customers)', 'CCPA'],
      taxSystem: 'Federal + State Tax', reportStandard: 'GAAP',
    ),
    'GB': CountryBusiness(
      countryCode: 'GB', countryName: 'Великобритания', currency: 'GBP', currencySymbol: '£',
      integrations: ['Salesforce', 'HubSpot', 'Slack', 'MS Teams', 'Xero', 'Sage'],
      documentTypes: ['Sales Deck', 'Annual Report', 'H&S Briefing', 'Board Meeting'],
      compliance: ['UK GDPR', 'Companies Act', 'H&S Regulations'],
      taxSystem: 'Corporation Tax + VAT', reportStandard: 'UK GAAP / IFRS',
    ),
    'DE': CountryBusiness(
      countryCode: 'DE', countryName: 'Германия', currency: 'EUR', currencySymbol: '€',
      integrations: ['SAP', 'Salesforce', 'MS Teams', 'DATEV', 'Personio'],
      documentTypes: ['Verkaufspräsentation', 'Geschäftsbericht', 'Sicherheitsunterweisung', 'Betriebsanleitung'],
      compliance: ['GDPR', 'ISO 9001', 'Arbeitsschutzgesetz'],
      taxSystem: 'Körperschaftsteuer + USt', reportStandard: 'HGB / IFRS',
    ),
    'FR': CountryBusiness(
      countryCode: 'FR', countryName: 'Франция', currency: 'EUR', currencySymbol: '€',
      integrations: ['Salesforce', 'Cegid', 'Sage', 'Slack', 'MS Teams'],
      documentTypes: ['Présentation commerciale', 'Rapport annuel', 'Fiche de sécurité', 'Procédure'],
      compliance: ['RGPD', 'ISO 9001', 'Code du travail'],
      taxSystem: 'Impôt sur les sociétés + TVA', reportStandard: 'PCG / IFRS',
    ),
    'RU': CountryBusiness(
      countryCode: 'RU', countryName: 'Россия', currency: 'RUB', currencySymbol: '₽',
      integrations: ['Битрикс24', 'amoCRM', '1С:Документооборот', 'СБИС', 'Яндекс.Документы'],
      documentTypes: ['Коммерческое предложение', 'Счёт-фактура', 'Отчёт о продажах', 'Инструктаж по ТБ', 'Приказ'],
      compliance: ['152-ФЗ', 'ГОСТ Р', 'ТК РФ'],
      taxSystem: 'НДС + Налог на прибыль', reportStandard: 'РСБУ',
    ),
    'BY': CountryBusiness(
      countryCode: 'BY', countryName: 'Беларусь', currency: 'BYN', currencySymbol: 'Br',
      integrations: ['1С:Предприятие', 'Битрикс24', 'ЭДО', 'bepaid'],
      documentTypes: ['Коммерческое предложение', 'Накладная', 'Отчёт', 'Должностная инструкция'],
      compliance: ['Закон о персональных данных', 'ТК РБ'],
      taxSystem: 'НДС + Налог на прибыль', reportStandard: 'МСФО / НСБУ',
    ),
    'KZ': CountryBusiness(
      countryCode: 'KZ', countryName: 'Казахстан', currency: 'KZT', currencySymbol: '₸',
      integrations: ['1С:Казахстан', 'Битрикс24', 'ЭСФ', 'Кабинет НП'],
      documentTypes: ['Коммерческое предложение', 'ЭСФ', 'Отчёт', 'Приказ', 'Акт'],
      compliance: ['Закон о персональных данных', 'ТК РК', 'ISO'],
      taxSystem: 'НДС + КПН', reportStandard: 'МСФО / НСБУ',
    ),
    'IN': CountryBusiness(
      countryCode: 'IN', countryName: 'Индия', currency: 'INR', currencySymbol: '₹',
      integrations: ['Zoho CRM', 'Tally', 'Slack', 'Google Workspace'],
      documentTypes: ['Sales Deck', 'Invoice', 'GST Report', 'SOP'],
      compliance: ['IT Act', 'GST', 'Companies Act'],
      taxSystem: 'GST + Corporate Tax', reportStandard: 'Ind AS / IFRS',
    ),
    'BR': CountryBusiness(
      countryCode: 'BR', countryName: 'Бразилия', currency: 'BRL', currencySymbol: 'R\$',
      integrations: ['RD Station', 'Totvs', 'Slack', 'Google Workspace'],
      documentTypes: ['Proposta Comercial', 'Nota Fiscal', 'Relatório', 'Procedimento Operacional'],
      compliance: ['LGPD', 'NR (Normas Regulamentadoras)'],
      taxSystem: 'ICMS + PIS/COFINS', reportStandard: 'BR GAAP / IFRS',
    ),
    'JP': CountryBusiness(
      countryCode: 'JP', countryName: 'Япония', currency: 'JPY', currencySymbol: '¥',
      integrations: ['Salesforce', 'Slack', 'Chatwork', 'Google Workspace'],
      documentTypes: ['営業資料', '報告書', '安全指示書', '手順書'],
      compliance: ['個人情報保護法', 'JIS', '労働安全衛生法'],
      taxSystem: '法人税 + 消費税', reportStandard: 'J-GAAP / IFRS',
    ),
    'CN': CountryBusiness(
      countryCode: 'CN', countryName: 'Китай', currency: 'CNY', currencySymbol: '¥',
      integrations: ['WeCom', 'DingTalk', 'Feishu', 'Alibaba Cloud'],
      documentTypes: ['销售方案', '报告', '安全生产', '操作规程'],
      compliance: ['个人信息保护法', 'GB标准'],
      taxSystem: '企业所得税 + 增值税', reportStandard: 'CAS / IFRS',
    ),
  };

  /// Базовые тарифы (в USD, конвертируются локально)
  static final Map<String, CorporatePlan> _basePlans = {
    'business': CorporatePlan(
      id: 'business', name: 'Business', price: '\$9.99', audience: 'ИП, малый бизнес', users: 1,
      features: ['Бренд-кит из логотипа', '50 слайдов', 'Экспорт PDF', 'Аналитика', 'Smart Data'],
      integrations: [], supportLevel: 'Email (24ч)',
    ),
    'corporate': CorporatePlan(
      id: 'corporate', name: 'Corporate', price: '\$49.99', audience: 'Средний бизнес', users: 10,
      features: ['Всё из Business', 'White-label', 'Команда', 'CRM-интеграция', 'API', 'SLA (4ч)'],
      integrations: [], supportLevel: 'Приоритет (4ч)',
    ),
    'enterprise': CorporatePlan(
      id: 'enterprise', name: 'Enterprise', price: '\$199', audience: 'Крупный бизнес', users: 50,
      features: ['Всё из Corporate', 'SSO', 'On-premise', 'Персональный менеджер', 'SLA (1ч)'],
      integrations: [], supportLevel: 'Выделенный (1ч)', onPremise: true,
    ),
  };

  /// Получить бизнес-среду по стране
  static CountryBusiness? getCountry(String countryCode) {
    return _countries[countryCode.toUpperCase()];
  }

  /// Получить тарифы, адаптированные под страну
  static Map<String, CorporatePlan> getPlansForCountry(String countryCode) {
    final country = getCountry(countryCode);
    final plans = Map<String, CorporatePlan>.from(_basePlans);

    if (country != null) {
      // Адаптируем цены под регион
      final priceMultiplier = _getPriceMultiplier(countryCode);
      for (final plan in plans.values) {
        final basePrice = double.parse(plan.price.replaceAll('\$', ''));
        final localPrice = (basePrice * priceMultiplier).toStringAsFixed(0);
        plans[plan.id] = CorporatePlan(
          id: plan.id, name: plan.name,
          price: '${country.currencySymbol}$localPrice',
          audience: plan.audience, users: plan.users,
          features: plan.features,
          integrations: country.integrations,
          supportLevel: plan.supportLevel,
          onPremise: plan.onPremise,
        );
      }
    }

    return plans;
  }

  /// Получить типы документов для страны
  static List<String> getDocumentTypes(String countryCode) {
    return getCountry(countryCode)?.documentTypes ?? ['Sales Deck', 'Report', 'SOP'];
  }

  /// Получить требования комплаенса
  static List<String> getCompliance(String countryCode) {
    return getCountry(countryCode)?.compliance ?? ['GDPR'];
  }

  /// Множитель цены для региона
  static double _getPriceMultiplier(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'RU': case 'BY': case 'KZ': return 0.5;  // СНГ — в 2 раза дешевле
      case 'IN': return 0.3;  // Индия — самая низкая цена
      case 'BR': return 0.6;
      default: return 1.0;
    }
  }

  /// Генерация бизнес-документа по типу и стране
  static Map<String, dynamic> generateDocument({
    required String documentType,
    required String companyName,
    required String countryCode,
    String? topic,
  }) {
    final country = getCountry(countryCode);
    final taxSystem = country?.taxSystem ?? 'Standard';
    final compliance = country?.compliance ?? [];

    return {
      'document_type': documentType,
      'company': companyName,
      'country': country?.countryName ?? countryCode,
      'currency': country?.currency ?? 'USD',
      'tax_system': taxSystem,
      'compliance_notes': compliance,
      'generated_at': DateTime.now().toIso8601String(),
      'slides': _generateSlides(documentType, companyName, countryCode),
    };
  }

  static List<Map<String, String>> _generateSlides(String type, String company, String country) {
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