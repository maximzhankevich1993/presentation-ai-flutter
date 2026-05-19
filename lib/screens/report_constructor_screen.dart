import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../services/generation_counter.dart';
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'corporate_screen.dart';

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

  Future<void> _generateReport() async {
    final company = _companyController.text.trim();
    final period = _periodController.text.trim();
    
    if (company.isEmpty || period.isEmpty) {
      _showError('Заполните все поля');
      return;
    }
    
    setState(() => _isGenerating = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isLoggedIn = userProvider.isLoggedIn;
      final isPremium = userProvider.isPremium;
      
      final canGenerate = await GenerationCounter.canGenerateReport(isLoggedIn, isPremium);
      if (!canGenerate) {
        if (mounted) {
          _showLimitAndRedirect();
        }
        setState(() => _isGenerating = false);
        return;
      }
      
      final presentation = await _generateReportViaAPI(
        company: company,
        period: period,
        standard: _selectedStandard,
        reportType: _selectedReportType,
      );
      
      if (!isLoggedIn) {
        await GenerationCounter.incrementReport();
      }
      
      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(presentation: presentation),
        ),
      );
    } catch (e) {
      _showError('Ошибка создания отчёта: $e');
      setState(() => _isGenerating = false);
    }
  }
  
  Future<Presentation> _generateReportViaAPI({
    required String company,
    required String period,
    required String standard,
    required String reportType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final standardName = _standards.firstWhere((s) => s['code'] == standard)['name'] ?? standard;
    final reportName = _reportTypes.firstWhere((t) => t['id'] == reportType)['name'] ?? reportType;
    
    return Presentation(
      id: DateTime.now().toString(),
      title: '$reportName: $company',
      slides: [
        Slide(title: 'Титульный лист', content: [reportName, company, 'Период: $period', 'Стандарт: $standardName']),
        Slide(title: 'Ключевые показатели', content: ['📊 Выручка: _________', '💰 Прибыль: _________', '📈 Рентабельность: _________', '💵 Денежный поток: _________']),
        Slide(title: 'Анализ', content: ['• Отклонения от плана:', '• Тренды и динамика:', '• Ключевые риски:']),
        Slide(title: 'Заключение', content: ['Основные выводы:', 'Рекомендации:', 'План действий:']),
      ],
      createdAt: DateTime.now(),
    );
  }
  
  void _showLimitAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит исчерпан', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text(
          'Вы использовали все 3 бесплатных отчёта.\n\nВыберите тариф "Бизнес" или "Корпоративный", чтобы продолжить.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CorporateScreen(countryCode: 'RU')),
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
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFFF3B30), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserProvider>().isLoggedIn;
    final isPremium = context.watch<UserProvider>().isPremium;
    final remaining = isPremium || isLoggedIn ? 999 : 3 - (_usedGenerations ?? 0);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Конструктор отчётов', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(width: 64, height: 64, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 32)),
                            const SizedBox(height: 16),
                            const Text('Конструктор отчётов', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            Text('Создайте финансовый отчёт по международным стандартам', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
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
                      const SizedBox(height: 24),
                      
                      if (!isLoggedIn && !isPremium && remaining < 3)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFF1DB954), size: 18),
                              const SizedBox(width: 10),
                              Expanded(child: Text('Осталось $remaining из 3 бесплатных отчётов', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13))),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _generateReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Создать отчёт', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
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
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
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
                    Text(type['name'] as String, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF9A9A9A), fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
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
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A2A))),
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
  
  int get _usedGenerations {
    // TODO: получить из GenerationCounter
    return 0;
  }
}