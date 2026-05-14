import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/template.dart';
import 'api_service.dart';

class TemplateService {
  static const String _freeTemplatesPath = 'assets/templates/free_templates.json';
  static const String _premiumTemplatesPath = 'assets/templates/premium_templates.json';
  
  static List<Template> _cachedFreeTemplates = [];
  static List<Template> _cachedPremiumTemplates = [];
  
  // Загрузка бесплатных шаблонов из assets
  static Future<List<Template>> loadFreeTemplates() async {
    if (_cachedFreeTemplates.isNotEmpty) {
      return _cachedFreeTemplates;
    }
    
    try {
      final String jsonString = await rootBundle.loadString(_freeTemplatesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedFreeTemplates = jsonList.map((j) => Template.fromJson(j)).toList();
      return _cachedFreeTemplates;
    } catch (e) {
      print('Error loading free templates: $e');
      return _getFallbackFreeTemplates();
    }
  }
  
  // Загрузка премиум шаблонов с сервера
  static Future<List<Template>> loadPremiumTemplates() async {
    if (_cachedPremiumTemplates.isNotEmpty) {
      return _cachedPremiumTemplates;
    }
    
    try {
      // TODO: заменить на реальный API запрос
      // final response = await ApiService.getPremiumTemplates();
      // _cachedPremiumTemplates = response.map((j) => Template.fromJson(j)).toList();
      
      // Пока используем заглушку
      final String jsonString = await rootBundle.loadString(_premiumTemplatesPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedPremiumTemplates = jsonList.map((j) => Template.fromJson(j)).toList();
      return _cachedPremiumTemplates;
    } catch (e) {
      print('Error loading premium templates: $e');
      return [];
    }
  }
  
  // Загрузка всех шаблонов
  static Future<List<Template>> loadAllTemplates({bool includePremium = false}) async {
    final free = await loadFreeTemplates();
    if (!includePremium) return free;
    
    final premium = await loadPremiumTemplates();
    return [...free, ...premium];
  }
  
  // Fallback шаблоны на случай ошибки загрузки
  static List<Template> _getFallbackFreeTemplates() {
    return [
      Template(
        id: 'empty',
        title: 'Пустой',
        description: 'Начните с чистого листа',
        category: 'Все',
        color1: '#1A1A1A',
        color2: '#2A2A2A',
        slideCount: 1,
        isPremium: false,
        isPopular: false,
        icon: 'crop_original_rounded',
        slides: [
          {'title': 'Новая презентация', 'content': ['Начните добавлять контент']}
        ],
      ),
      Template(
        id: 'business_plan',
        title: 'Бизнес-план',
        description: 'Структура и финансовые показатели',
        category: 'Бизнес',
        color1: '#1DB954',
        color2: '#1ED760',
        slideCount: 8,
        isPremium: false,
        isPopular: true,
        icon: 'business_center_rounded',
        slides: [
          {'title': 'Бизнес-план', 'content': ['Краткое описание', 'Цели и задачи']},
          {'title': 'Анализ рынка', 'content': ['Конкуренты', 'Целевая аудитория']},
          {'title': 'Финансовый план', 'content': ['Прогноз доходов', 'Инвестиции']},
        ],
      ),
    ];
  }
}