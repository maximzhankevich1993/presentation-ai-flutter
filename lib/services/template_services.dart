import '../models/template.dart';
import 'api_service.dart';

class TemplateService {
  static List<Template> _cachedFreeTemplates = [];
  static List<Template> _cachedPremiumTemplates = [];
  
  static Future<List<Template>> loadFreeTemplates() async {
    if (_cachedFreeTemplates.isNotEmpty) {
      return _cachedFreeTemplates;
    }
    
    try {
      final response = await ApiService.getFreeTemplates();
      if (response['success'] == true) {
        final List<dynamic> templatesJson = response['templates'];
        _cachedFreeTemplates = templatesJson.map((j) => Template.fromJson(j)).toList();
        return _cachedFreeTemplates;
      }
      return [];
    } catch (e) {
      print('Error loading free templates: $e');
      return [];
    }
  }
  
  static Future<List<Template>> loadPremiumTemplates() async {
    if (_cachedPremiumTemplates.isNotEmpty) {
      return _cachedPremiumTemplates;
    }
    
    try {
      final response = await ApiService.getPremiumTemplates();
      if (response['success'] == true) {
        final List<dynamic> templatesJson = response['templates'];
        _cachedPremiumTemplates = templatesJson.map((j) => Template.fromJson(j)).toList();
        return _cachedPremiumTemplates;
      }
      return [];
    } catch (e) {
      print('Error loading premium templates: $e');
      return [];
    }
  }
  
  static Future<List<Template>> loadAllTemplates({bool includePremium = false}) async {
    final free = await loadFreeTemplates();
    if (!includePremium) return free;
    final premium = await loadPremiumTemplates();
    return [...free, ...premium];
  }
}