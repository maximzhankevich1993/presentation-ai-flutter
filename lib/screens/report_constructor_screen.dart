import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'editor_screen.dart';
import 'premium_screen.dart';

class ReportConstructorScreen extends StatefulWidget {
  const ReportConstructorScreen({super.key});

  @override
  State<ReportConstructorScreen> createState() => _ReportConstructorScreenState();
}

class _ReportConstructorScreenState extends State<ReportConstructorScreen> {
  final _companyController = TextEditingController();
  final _periodController = TextEditingController();
  
  String _selectedStandard = 'ifrs';
  String _selectedReportType = 'financial';
  int _slideCount = 6; // НОВОЕ: количество слайдов
  bool _isGenerating = false;
  
  final List<Map<String, String>> _standards = [
    {'code': 'ifrs', 'name': 'IFRS', 'region': 'Международный', 'description': 'International Financial Reporting Standards'},
    {'code': 'gaap', 'name': 'US GAAP', 'region': 'США', 'description': 'Generally Accepted Accounting Principles'},
    {'code': 'rsbu', 'name': 'РСБУ', 'region': 'Россия', 'description': 'Российские стандарты бухгалтерского учёта'},
    {'code': 'gri', 'name': 'GRI', 'region': 'Международный', 'description': 'Global Reporting Initiative (ESG)'},
  ];
  
  final List<Map<String, dynamic>> _reportTypes = [
    {'id': 'financial', 'name': 'Финансовый отчёт', 'icon': Icons.attach_money_rounded},
    {'id': 'annual', 'name': 'Годовой отчёт', 'icon': Icons.calendar_today_rounded},
    {'id': 'esg', 'name': 'ESG отчёт', 'icon': Icons.eco_rounded},
    {'id': 'management', 'name': 'Управленческий отчёт', 'icon': Icons.analytics_rounded},
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _showLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD700), size: 24),
            SizedBox(width: 8),
            Text('Лимит генераций исчерпан', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'У вас закончились бесплатные генерации.\n\nОформите подписку, чтобы продолжить создавать отчёты без ограничений.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  Future<void> _generateReport() async {
    final company = _companyController.text.trim();
    final period = _periodController.text.trim();
    
    if (company.isEmpty || period.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.freeGenerationsLeft <= 0) {
      _showLimitDialog();
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      final reportData = await ApiService.generateReport(
        company: company,
        period: period,
        standard: _selectedStandard,
        reportType: _selectedReportType,
        slideCount: _slideCount, // НОВОЕ: передаём количество слайдов
      );
      
      await userProvider.loadUser();
      
      if (!mounted) return;
      
      final presentation = _convertToPresentation(reportData);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } on LimitReachedException catch (_) {
      if (mounted) {
        _showLimitDialog();
        await userProvider.loadUser();
      }
    } catch (e) {
      _showError('Ошибка создания отчёта: $e');
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
  
  Presentation _convertToPresentation(Map<String, dynamic> reportData) {
    final slides = <Slide>[];
    
    // Слайды отчёта
    final slidesData = reportData['slides'] as List? ?? [];
    for (final slideData in slidesData) {
      final content = slideData['content'] as List? ?? [];
      slides.add(Slide(
        title: slideData['title'] ?? 'Слайд',
        content: content.map((c) => c.toString()).toList(),
      ));
    }
    
    // Если нет слайдов — создаём структуру по умолчанию
    if (slides.isEmpty) {
      slides.add(Slide(
        title: reportData['title'] ?? 'Отчёт',
        content: [
          'Компания: ${_companyController.text}',
          'Период: ${_periodController.text}',
          'Стандарт: ${_getStandardName(_selectedStandard)}',
          'Тип: ${_getReportTypeName(_selectedReportType)}',
        ],
      ));
    }
    
    return Presentation(
      id: DateTime.now().toString(),
      title: reportData['title'] ?? '${_getReportTypeName(_selectedReportType)}: ${_companyController.text}',
      slides: slides,
      createdAt: DateTime.now(),
    );
  }
  
  String _getStandardName(String code) {
    final standard = _standards.firstWhere(
      (s) => s['code'] == code,
      orElse: () => {'name': code},
    );
    return standard['name'] ?? code;
  }
  
  String _getReportTypeName(String id) {
    final type = _reportTypes.firstWhere(
      (t) => t['id'] == id,
      orElse: () => {'name': id},
    );
    return type['name'] ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final remaining = userProvider.freeGenerationsLeft;
    final isPremium = userProvider.isPremium;
    final canGenerate = remaining > 0 || isPremium;
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Конструктор отчётов',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 16),
                            const Text('Конструктор отчётов', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Создайте профессиональный финансовый отчёт', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildTextField(controller: _companyController, hint: 'Название компании', icon: Icons.business_rounded),
                      const SizedBox(height: 12),
                      _buildTextField(controller: _periodController, hint: 'Отчётный период', icon: Icons.calendar_today_rounded),
                      const SizedBox(height: 16),
                      
                      const Text('ТИП ОТЧЁТА', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildReportTypeSelector(),
                      const SizedBox(height: 16),
                      
                      const Text('СТАНДАРТ ОТЧЁТНОСТИ', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _buildStandardDropdown(),
                      const SizedBox(height: 16),
                      
                      // НОВОЕ: Слайдер выбора количества слайдов
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Количество слайдов', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1DB954).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('$_slideCount', style: const TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.w700, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Slider(
                              value: _slideCount.toDouble(),
                              min: 3,
                              max: 15,
                              divisions: 12,
                              activeColor: const Color(0xFF1DB954),
                              inactiveColor: const Color(0xFF2A2A2A),
                              onChanged: (v) => setState(() => _slideCount = v.round()),
                            ),
                            const SizedBox(height: 4),
                            const Text('Рекомендуем: 6-10 слайдов для оптимального отчёта', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Индикатор оставшихся генераций
                      if (!isPremium && remaining <= 3)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: remaining <= 0 
                                ? const Color(0xFFFF3B30).withOpacity(0.1)
                                : const Color(0xFF1DB954).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: remaining <= 0 
                                  ? const Color(0xFFFF3B30).withOpacity(0.3)
                                  : const Color(0xFF1DB954).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                remaining <= 0 ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                                color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  remaining <= 0 
                                      ? 'Бесплатные генерации закончились. Оформите подписку, чтобы продолжить.'
                                      : 'Осталось $remaining из 5 бесплатных генераций',
                                  style: TextStyle(
                                    color: remaining <= 0 ? const Color(0xFFFF3B30) : const Color(0xFF1DB954),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (remaining <= 0)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Купить',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Кнопка создания
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: canGenerate ? _generateReport : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canGenerate ? const Color(0xFF1DB954) : const Color(0xFF4A4A4A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            canGenerate ? 'Создать отчёт' : 'Лимит исчерпан',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF4A4A4A)),
          prefixIcon: Icon(icon, color: const Color(0xFF1DB954), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
  
  Widget _buildReportTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: _reportTypes.map((type) {
          final isSelected = _selectedReportType == type['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedReportType = type['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1DB954) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type['icon'] as IconData, color: isSelected ? Colors.white : const Color(0xFF9A9A9A), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      type['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStandardDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedStandard,
        items: _standards.map((standard) {
          return DropdownMenuItem(
            value: standard['code'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(standard['name']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(standard['description']!, style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 11)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) => setState(() => _selectedStandard = v!),
        decoration: const InputDecoration(
          labelText: 'Стандарт отчетности',
          labelStyle: TextStyle(color: Color(0xFF4A4A4A)),
          border: InputBorder.none,
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}