import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'canvas_editor_screen.dart';
import 'premium_screen.dart';

class CorporateScreen extends StatefulWidget {
  final String countryCode;
  const CorporateScreen({super.key, required this.countryCode});

  @override
  State<CorporateScreen> createState() => _CorporateScreenState();
}

class _CorporateScreenState extends State<CorporateScreen> {
  String _selectedTariff = 'business';
  bool _isLoading = false;

  // Бесплатные шаблоны/отчёты
  final List<Map<String, dynamic>> _freeReports = [
    {
      'id': 'business_plan',
      'title': 'Бизнес-план',
      'description': 'Структура и финансовые показатели',
      'color': '#1DB954',
      'icon': Icons.business_center_rounded,
      'template': '📊 Бизнес-план\n\n• Краткое описание\n• Цели и задачи\n• Финансовый план',
    },
    {
      'id': 'swot_analysis',
      'title': 'SWOT-анализ',
      'description': 'Сильные и слабые стороны компании',
      'color': '#667eea',
      'icon': Icons.analytics_rounded,
      'template': '📈 SWOT-анализ\n\nСильные стороны:\n• \n\nСлабые стороны:\n• \n\nВозможности:\n• \n\nУгрозы:\n•',
    },
    {
      'id': 'product_presentation',
      'title': 'Презентация продукта',
      'description': 'Запуск нового продукта или услуги',
      'color': '#f093fb',
      'icon': Icons.videocam_rounded,
      'template': '🎯 Презентация продукта\n\nО продукте:\n• \n\nПреимущества:\n• \n\nДля кого:\n•',
    },
  ];

  // Премиум шаблоны/отчёты (только для подписчиков)
  final List<Map<String, dynamic>> _premiumReports = [
    {
      'id': 'annual_report',
      'title': 'Годовой отчёт',
      'description': 'Полный анализ деятельности компании',
      'color': '#11998e',
      'icon': Icons.analytics_rounded,
      'template': '📅 Годовой отчёт\n\nКлючевые показатели:\n• Выручка:\n• Прибыль:\n• ROI:\n\nДинамика:\n•',
    },
    {
      'id': 'financial_report',
      'title': 'Финансовая отчётность',
      'description': 'Баланс, прибыль, денежные потоки',
      'color': '#1DB954',
      'icon': Icons.attach_money_rounded,
      'template': '💰 Финансовая отчётность\n\nБухгалтерский баланс:\n• Активы:\n• Пассивы:\n\nОтчёт о прибылях и убытках:\n• Выручка:\n• Себестоимость:\n• Чистая прибыль:',
    },
    {
      'id': 'kpi_dashboard',
      'title': 'KPI Dashboard',
      'description': 'Ключевые показатели эффективности',
      'color': '#FF416C',
      'icon': Icons.dashboard_rounded,
      'template': '📊 KPI Dashboard\n\nМетрики:\n• Конверсия:\n• LTV:\n• CAC:\n• NPS:',
    },
    {
      'id': 'investment_pitch',
      'title': 'Инвестиционная презентация',
      'description': 'Для инвесторов и партнёров',
      'color': '#8E2DE2',
      'icon': Icons.rocket_launch_rounded,
      'template': '🚀 Инвестиционная презентация\n\nПроблема:\n• \n\nРешение:\n• \n\nРынок:\n• \n\nФинансы:\n•',
    },
  ];

  void _openReport(Map<String, dynamic> report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CanvasEditorScreen(
          title: report['title'],
          initialContent: report['template'],
        ),
      ),
    );
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Premium доступ',
          style: TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Этот отчёт доступен только по подписке Premium.\nОформите подписку, чтобы получить доступ ко всем отчётам и шаблонам.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть', style: TextStyle(color: Color(0xFF9A9A9A))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: const Text('Оформить', style: TextStyle(color: Color(0xFF1DB954), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final isPremium = up.isPremium;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
            ),
          ),
        ),
        title: const Text(
          'Бизнесу',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF1DB954),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.business_center_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Корпоративный тариф',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Для компаний от 10 человек',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Тарифы
                      const Text(
                        'ВЫБЕРИТЕ ПЛАН',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTariffCard(
                              title: 'Бизнес',
                              price: '499',
                              period: 'месяц',
                              originalPrice: '999',
                              description: 'Для малого бизнеса',
                              features: const [
                                'До 10 пользователей',
                                '∞ генераций',
                                'Бренд-кит',
                                'Приоритетная поддержка',
                                'API доступ',
                                'Бесплатные отчёты',
                              ],
                              isPopular: true,
                              onTap: () => _selectTariff('business'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTariffCard(
                              title: 'Корпоративный',
                              price: '1499',
                              period: 'месяц',
                              originalPrice: '2499',
                              description: 'Для крупных компаний',
                              features: const [
                                'Неограниченно пользователей',
                                '∞ генераций',
                                'Бренд-кит',
                                'VIP поддержка 24/7',
                                'API + Webhook',
                                'Все отчёты и шаблоны',
                              ],
                              isPopular: false,
                              onTap: () => _selectTariff('corporate'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Бесплатные отчёты
                      const Text(
                        'БЕСПЛАТНЫЕ ОТЧЁТЫ',
                        style: TextStyle(
                          color: Color(0xFF4A4A4A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._freeReports.map((report) => _buildReportCard(report, isPremium: false)),

                      // Премиум отчёты (только для подписчиков)
                      if (isPremium) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'PREMIUM ОТЧЁТЫ',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._premiumReports.map((report) => _buildReportCard(report, isPremium: true)),
                      ] else ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.lock_rounded, color: Color(0xFFFFD700), size: 48),
                              const SizedBox(height: 12),
                              const Text(
                                'Premium отчёты',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Оформите подписку Premium, чтобы получить доступ к расширенным отчётам и шаблонам',
                                style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFFD60A)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Получить Premium',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _contactSales(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2A2A2A)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Связаться с отделом продаж',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Color(0xFF1DB954), size: 16),
                              ],
                            ),
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

  Widget _buildTariffCard({
    required String title,
    required String price,
    required String period,
    required String originalPrice,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTariff == title.toLowerCase();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1DB95420) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF1DB954).withOpacity(0.15), blurRadius: 12)] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isPopular ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        title == 'Бизнес' ? Icons.business_center_rounded : Icons.apartment_rounded,
                        color: isPopular ? Colors.white : const Color(0xFF1DB954),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          Text(description, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
                        ],
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Популярный', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$price ₽', style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(width: 4),
                    Text('/$period', style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                    const SizedBox(width: 12),
                    Text('$originalPrice ₽', style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 14, decoration: TextDecoration.lineThrough)),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFF2A2A2A), height: 1),
                const SizedBox(height: 16),
                const Text('Включено:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12, runSpacing: 10,
                  children: features.map((feature) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                      const SizedBox(width: 6),
                      Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  )).toList(),
                ),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]) : null,
                        color: isSelected ? null : const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF2A2A2A)),
                      ),
                      child: Center(
                        child: Text(
                          isSelected ? 'Выбран' : 'Выбрать тариф',
                          style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1DB954), fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
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

  Widget _buildReportCard(Map<String, dynamic> report, {required bool isPremium}) {
    final color = Color(int.parse(report['color'].replaceFirst('#', '0xFF')));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: isPremium ? () => _openReport(report) : _showPremiumRequired,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(report['icon'], color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report['description'],
                        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFD60A)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward_rounded, color: color, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectTariff(String tariff) {
    setState(() => _selectedTariff = tariff);
    String message = tariff == 'business' ? 'Вы выбрали тариф "Бизнес"' : 'Вы выбрали тариф "Корпоративный"';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF1DB954),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

  void _contactSales() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.email_rounded, color: Color(0xFF1DB954), size: 26)),
              const SizedBox(height: 16),
              const Text('Отдел продаж', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Напишите нам на почту для\nподбора корпоративного тарифа', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))), child: const Row(children: [Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18), SizedBox(width: 10), Text('corp@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))])),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF252525), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Закрыть', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}