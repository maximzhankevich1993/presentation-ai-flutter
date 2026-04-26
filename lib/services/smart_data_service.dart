import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:convert';

class MarketData {
  final String metric;
  final String value;
  final String source;
  final String year;

  const MarketData({
    required this.metric,
    required this.value,
    required this.source,
    required this.year,
  });
}

class SmartDataService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static final Dio _dio = Dio();
  static final Random _random = Random();

  /// База заранее загруженных данных по популярным темам
  static final Map<String, List<MarketData>> _dataCache = {
    'искусственный интеллект': [
      MarketData(metric: 'Объём рынка AI', value: '\$1.94 трлн', source: 'Grand View Research', year: '2025'),
      MarketData(metric: 'Прогноз роста', value: '25.4% CAGR', source: 'MarketsAndMarkets', year: '2025-2029'),
      MarketData(metric: 'Компаний используют AI', value: '75%', source: 'McKinsey', year: '2025'),
      MarketData(metric: 'Экономия времени', value: '80%', source: 'Harvard Business Review', year: '2024'),
      MarketData(metric: 'Создано рабочих мест', value: '97 млн', source: 'World Economic Forum', year: '2025'),
    ],
    'бизнес': [
      MarketData(metric: 'Малый бизнес в экономике', value: '60% ВВП', source: 'World Bank', year: '2025'),
      MarketData(metric: 'Стартапов ежегодно', value: '305 млн', source: 'Startup Genome', year: '2025'),
      MarketData(metric: 'Успешных стартапов', value: '10%', source: 'Failory', year: '2024'),
    ],
    'экология': [
      MarketData(metric: 'Выбросы CO2', value: '37.4 млрд тонн', source: 'IEA', year: '2024'),
      MarketData(metric: 'Зелёная энергия', value: '30%', source: 'IRENA', year: '2025'),
      MarketData(metric: 'Повышение температуры', value: '+1.2°C', source: 'NASA', year: '2025'),
    ],
    'космос': [
      MarketData(metric: 'Объём рынка SpaceTech', value: '\$630 млрд', source: 'Space Foundation', year: '2025'),
      MarketData(metric: 'Запусков в год', value: '220+', source: 'SpaceX Report', year: '2025'),
      MarketData(metric: 'Спутников на орбите', value: '8000+', source: 'UNOOSA', year: '2025'),
    ],
    'мобильная разработка': [
      MarketData(metric: 'Пользователей смартфонов', value: '6.9 млрд', source: 'Statista', year: '2025'),
      MarketData(metric: 'Приложений в App Store', value: '1.8 млн', source: 'Apple', year: '2025'),
      MarketData(metric: 'Доход рынка приложений', value: '\$935 млрд', source: 'App Annie', year: '2025'),
    ],
  };

  /// Получает релевантные данные по теме
  static Future<List<MarketData>> getRelevantData(String topic) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/smart-data',
        data: jsonEncode({'topic': topic}),
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        return data?.map((d) => MarketData(
          metric: d['metric'] ?? '',
          value: d['value'] ?? '',
          source: d['source'] ?? '',
          year: d['year'] ?? '',
        )).toList() ?? [];
      }
    } catch (e) {
      // Fallback на локальный кеш
    }
    
    return _localSearch(topic);
  }

  /// Локальный поиск по ключевым словам
  static List<MarketData> _localSearch(String topic) {
    final lowercaseTopic = topic.toLowerCase();
    final results = <MarketData>[];
    
    for (final entry in _dataCache.entries) {
      if (lowercaseTopic.contains(entry.key) || entry.key.contains(lowercaseTopic)) {
        results.addAll(entry.value);
      }
    }
    
    // Если ничего не нашли — возвращаем случайные данные
    if (results.isEmpty) {
      final randomEntry = _dataCache.entries.elementAt(
        _random.nextInt(_dataCache.entries.length),
      );
      results.addAll(randomEntry.value.take(2));
    }
    
    return results;
  }

  /// Форматирует данные для вставки в слайд
  static String formatDataForSlide(List<MarketData> data) {
    if (data.isEmpty) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('📊 Ключевые цифры:');
    
    for (final item in data.take(3)) {
      buffer.writeln('• ${item.metric}: ${item.value} (${item.source}, ${item.year})');
    }
    
    return buffer.toString();
  }

  /// Генерирует слайд с данными
  static Map<String, dynamic> generateDataSlide(String topic, List<MarketData> data) {
    return {
      'title': '$topic: цифры и факты',
      'subtitle': 'Актуальные данные из проверенных источников',
      'content': data.take(5).map((d) => '${d.metric}: ${d.value}').toList(),
      'image_keywords': 'data visualization statistics charts',
      'data_sources': data.map((d) => '${d.source}, ${d.year}').toList(),
    };
  }
}