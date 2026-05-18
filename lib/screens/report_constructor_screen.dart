import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../services/generation_counter.dart';
import '../providers/user_provider.dart';
import 'editor_screen.dart';
import 'teacher_screen.dart';

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
      
      final canGenerate = await GenerationCounter.canGenerate(isLoggedIn, isPremium);
      if (!canGenerate) {
        if (mounted) {
          _showLimitAndRedirect();
        }
        setState(() => _isGenerating = false);
        return;
      }
      
      // TODO: Вызов API для генерации отчёта
      final presentation = await _generateReportViaAPI(
        company: company,
        period: period,
        standard: _selectedStandard,
        reportType: _selectedReportType,
      );
      
      if (!isLoggedIn) {
        await GenerationCounter.increment();
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
    // Временная заглушка — пока бэкенд не готов
    await Future.delayed(const Duration(seconds: 1));
    
    final standardName = _standards.firstWhere((s) => s['code'] == standard)['name'] ?? standard;
    final reportName = _reportTypes.firstWhere((t) => t['id'] == reportType)['name'] ?? reportType;
    
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
          title: 'Ключевые показатели',
          content: [
            '📊 Выручка: _________',
            '💰 Прибыль: _________',
            '📈 Рентабельность: _________',
            '💵 Денежный поток: _________',
          ],
        ),
        Slide(
          title: 'Анализ',
          content: [
            '• Отклонения от плана:',
            '• Тренды и динамика:',
            '• Ключевые риски:',
          ],
        ),
        Slide(
          title: 'Заключение',
          content: [
            'Основные выводы:',
            'Рекомендации:',
            'План действий:',
          ],
        ),
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
              // Возврат на страницу бизнеса
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
                  SizedBox(width: 40, height: 40, child: CircularProgressIndicator(color: