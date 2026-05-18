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
  
  // Поля для ручного ввода цифр
  final _revenueController = TextEditingController();
  final _profitController = TextEditingController();
  final _assetsController = TextEditingController();
  final _employeesController = TextEditingController();
  
  String _selectedStandard = 'ifrs';
  String _selectedReportType = 'financial';
  bool _isGenerating = false;
  bool _useRealData = false; // Переключатель: AI цифры или реальные
  bool _showManualInput = false;
  
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
    _revenueController.dispose();
    _profitController.dispose();
    _assetsController.dispose();
    _employeesController.dispose();
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
    
    // Получаем цифры для отчёта
    String revenue, profit, assets, employees;
    
    if (_useRealData && _showManualInput) {
      // Вариант 2: пользователь ввёл свои цифры
      revenue = _revenueController.text.trim().isEmpty ? '___' : _revenueController.text.trim();
      profit = _profitController.text.trim().isEmpty ? '___' : _profitController.text.trim();
      assets = _assetsController.text.trim().isEmpty ? '___' : _assetsController.text.trim();
      employees = _employeesController.text.trim().isEmpty ? '___' : _employeesController.text.trim();
    } else {
      // Вариант 1: AI генерирует реалистичные цифры
      revenue = _generateRandomNumber(10, 500);
      profit = _generateRandomNumber(1, 50);
      assets = _generateRandomNumber(20, 300);
      employees = _generateRandomNumber(10, 500);
    }
    
    return Presentation(
      id: DateTime.now().toString(),
      title: '$reportName: $company',
      slides: [
        Slide(
          title: 'Титульный лист',
          content: [
            reportName,
            company,
            'Период: $period',
            'Стандарт: $standardName',
          ],
        ),
        Slide(
          title: 'Ключевые финансовые показатели',
          content: [
            '📊 Выручка: $revenue млн ₽',
            '💰 Чистая прибыль: $profit млн ₽',
            '🏦 Активы: $assets млн ₽',
            '👥 Среднесписочная численность: $employees чел.',
          ],
        ),
        Slide(
          title: 'Анализ показателей',
          content: _generateAnalysis(revenue, profit, assets),
        ),
        Slide(
          title: 'Финансовые коэффициенты',
          content: [
            '📈 Рентабельность продаж: ${_calculateProfitMargin(revenue, profit)}%',
            '💵 Рентабельность активов: ${_calculateROA(profit, assets)}%',
            '⚡ Производительность труда: ${_calculateProductivity(revenue, employees)} млн ₽/чел.',
          ],
        ),
        Slide(
          title: 'Выводы и рекомендации',
          content: _generateConclusions(revenue, profit, _useRealData),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }
  
  String _generateRandomNumber(int min, int max) {
    final random = DateTime.now().millisecondsSinceEpoch % (max - min + 1) + min;
    return random.toString();
  }
  
  List<String> _generateAnalysis(String revenue, String profit, String assets) {
    final revNum = int.tryParse(revenue) ?? 0;
    final profitNum = int.tryParse(profit) ?? 0;
    final margin = revNum > 0 ? (profitNum / revNum * 100).toStringAsFixed(1) : '0';
    
    if (revNum > 100) {
      return [
        '• Выручка компании демонстрирует уверенный рост',
        '• Рентабельность составляет $margin%, что выше среднего по отрасли',
        '• Активы компании эффективно генерируют прибыль',
      ];
    } else {
      return [
        '• Компания находится на этапе активного роста',
        '• Рентабельность: $margin%',
        '• Рекомендуется оптимизация операционных расходов',
      ];
    }
  }
  
  String _calculateProfitMargin(String revenue, String profit) {
    final rev = int.tryParse(revenue) ?? 0;
    final prof = int.tryParse(profit) ?? 0;
    if (rev == 0) return '0';
    return ((prof / rev) * 100).toStringAsFixed(1);
  }
  
  String _calculateROA(String profit, String assets) {
    final prof = int.tryParse(profit) ?? 0;
    final ass = int.tryParse(assets) ?? 0;
    if (ass == 0) return '0';
    return ((prof / ass) * 100).toStringAsFixed(1);
  }
  
  String _calculateProductivity(String revenue, String employees) {
    final rev = int.tryParse(revenue) ?? 0;
    final emp = int.tryParse(employees) ?? 0;
    if (emp == 0) return '0';
    return (rev / emp).toStringAsFixed(1);
  }
  
  List<String> _generateConclusions(String revenue, String profit, bool useRealData) {
    if (useRealData) {
      return [
        '• На основе предоставленных данных财务状况 компании стабильны',
        '• Рекомендуется продолжить текущую стратегию развития',
        '• Для более детального анализа необходимо рассмотреть динамику показателей',
      ];
    } else {
      return [
        '• Данные показатели являются демонстрационными',
        '• Для получения реального отчёта заполните свои финансовые показатели',
        '• AI-генерация создаёт реалистичные цифры на основе среднерыночных',
      ];
    }
  }
  
  void _showLimitAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Лимит исчерпан',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Вы использовали все 3 бесплатных отчёта.\n\n'
          'Выберите тариф "Бизнес" или "Корпоративный", чтобы продолжить.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CorporateScreen(countryCode: 'US'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserProvider>().isLoggedIn;
    
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: Color(0xFF1DB954), strokeWidth: 2.5)),
                  SizedBox(height: 16),
                  Text('Создаём отчёт...', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Конструктор отчётов',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Создайте финансовый отчёт по международным стандартам',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Название компании
                  _buildTextField(
                    controller: _companyController,
                    hint: 'Название компании',
                    icon: Icons.business_rounded,
                  ),
                  const SizedBox(height: 12),
                  
                  // Отчётный период
                  _buildTextField(
                    controller: _periodController,
                    hint: 'Отчётный период (например, 2024 год)',
                    icon: Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 16),
                  
                  // Переключатель: AI цифры или ручной ввод
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.data_usage_rounded, color: Color(0xFF1DB954), size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Источник данных:',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('AI (демо)', style: TextStyle(fontSize: 12))),
                              ButtonSegment(value: true, label: Text('Ввести свои', style: TextStyle(fontSize: 12))),
                            ],
                            selected: {_useRealData},
                            onSelectionChanged: (Set<bool> selection) {
                              setState(() {
                                _useRealData = selection.first;
                                _showManualInput = _useRealData;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFF1DB954);
                                }
                                return const Color(0xFF2A2A2A);
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ручной ввод цифр (показывается только если выбрано)
                  if (_showManualInput) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: Column(
                        children: [
                          _buildNumberField('Выручка (млн ₽)', _revenueController),
                          const SizedBox(height: 8),
                          _buildNumberField('Чистая прибыль (млн ₽)', _profitController),
                          const SizedBox(height: 8),
                          _buildNumberField('Активы (млн ₽)', _assetsController),
                          const SizedBox(height: 8),
                          _buildNumberField('Количество сотрудников', _employeesController),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Тип отчёта
                  const Text(
                    'ТИП ОТЧЁТА',
                    style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  _buildReportTypeSelector(),
                  const SizedBox(height: 16),
                  
                  // Стандарт
                  const Text(
                    'СТАНДАРТ ОТЧЁТНОСТИ',
                    style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  _buildStandardDropdown(),
                  const SizedBox(height: 24),
                  
                  // Индикатор остатка (только для гостей)
                  if (!isLoggedIn) ...[
                    FutureBuilder<int>(
                      future: GenerationCounter.getRemainingReportsForGuest(),
                      builder: (context, snapshot) {
                        final remaining = snapshot.data ?? 3;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Color(0xFF1DB954), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Осталось $remaining из 3 бесплатных отчётов',
                                  style: const TextStyle(color: Color(0xFF1DB954), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  
                  // Кнопка создания
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _generateReport,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Создать отчёт',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Информация о стандартах
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'О стандартах отчетности',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        ..._standards.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1DB954),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['name']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      s['description']!,
                                      style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
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
  
  Widget _buildNumberField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1DB954)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                    Icon(
                      type['icon'] as IconData,
                      color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                      size: 16,
                    ),
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