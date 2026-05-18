import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/generation_counter.dart';
import '../providers/user_provider.dart';
import 'lesson_constructor_screen.dart';
import 'login_screen.dart';
import 'register_payment_screen.dart';

class TeacherScreen extends StatefulWidget {
  final String countryCode;
  const TeacherScreen({super.key, required this.countryCode});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String _selectedTariff = 'teacher';
  bool _isLoading = false;
  bool _loadingRates = true;
  
  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _rate = 1.0;

  @override
  void initState() {
    super.initState();
    _detectCurrency();
  }

  Future<void> _detectCurrency() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final countryCode = (data['country_code'] as String? ?? 'US').toUpperCase();
        
        const euroCountries = {
          'IT', 'FR', 'DE', 'ES', 'NL', 'BE', 'AT', 'PT', 'FI',
          'IE', 'GR', 'SK', 'SI', 'EE', 'LV', 'LT', 'LU', 'MT', 'CY',
        };
        
        if (countryCode == 'BY') {
          setState(() { _currency = 'BYN'; _currencySymbol = 'Br'; _rate = 3.25; });
        }
        else if (countryCode == 'RU') {
          setState(() { _currency = 'RUB'; _currencySymbol = '₽'; _rate = 95.0; });
        }
        else if (countryCode == 'KZ') {
          setState(() { _currency = 'KZT'; _currencySymbol = '₸'; _rate = 460.0; });
        }
        else if (countryCode == 'UA') {
          setState(() { _currency = 'UAH'; _currencySymbol = '₴'; _rate = 41.0; });
        }
        else if (countryCode == 'GB') {
          setState(() { _currency = 'GBP'; _currencySymbol = '£'; _rate = 0.79; });
        }
        else if (euroCountries.contains(countryCode)) {
          setState(() { _currency = 'EUR'; _currencySymbol = '€'; _rate = 0.92; });
        }
        else {
          setState(() { _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0; });
        }
      }
    } catch (e) {
      setState(() { _currency = 'USD'; _currencySymbol = '\$'; _rate = 1.0; });
    }
    if (mounted) setState(() => _loadingRates = false);
  }

  String _formatPrice(double usd) {
    if (usd == 0) return 'Бесплатно';
    final value = usd * _rate;
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') {
      return '$_currencySymbol${value.toStringAsFixed(2)}';
    }
    return '${value.ceil()} $_currencySymbol';
  }

  Future<void> _openConstructor() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;
    final isPremium = userProvider.isPremium;
    
    final canGenerate = await GenerationCounter.canGenerate(isLoggedIn, isPremium);
    
    if (!canGenerate) {
      _showUpgradeDialog();
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonConstructorScreen()),
    );
  }
  
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Лимит исчерпан', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        content: const Text(
          'Вы использовали все 5 бесплатных генераций.\n\nВыберите тариф, чтобы продолжить.',
          style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже', style: TextStyle(color: Color(0xFF9A9A9A)))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Выбрать тариф'),
          ),
        ],
      ),
    );
  }
  
  void _showPaymentDialog(String planId, double price, String period) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isLoggedIn) {
      _showPaymentSheet(planId, price, period);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Premium доступ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          content: const Text('Для оформления подписки необходимо создать аккаунт.\n\nЭто займёт меньше минуты.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена', style: TextStyle(color: Color(0xFF9A9A9A)))),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPaymentScreen(planId: planId, price: price, period: period)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1DB954)),
              child: const Text('Создать аккаунт и оплатить'),
            ),
          ],
        ),
      );
    }
  }
  
  void _showPaymentSheet(String planId, double price, String period) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Оплата подписки',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Text(
              '${_getPlanName(planId)} — ${_formatPrice(price)} $period',
              style: const TextStyle(color: Color(0xFF1DB954), fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                    ),
                    child: const Text('Отмена', style: TextStyle(color: Color(0xFF9A9A9A))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showPaymentDemo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                    ),
                    child: const Text('Оплатить', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPaymentDemo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text('Тестовый режим', style: TextStyle(color: Colors.white)),
        content: const Text('Платёжный модуль в разработке.\n\nPremium доступ будет активирован после оплаты.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть', style: TextStyle(color: Color(0xFF1DB954))),
          ),
        ],
      ),
    );
  }
  
  String _getPlanName(String planId) {
    switch (planId) {
      case 'monthly': return 'Месячная подписка';
      case 'semiannual': return 'Полугодовая подписка';
      case 'annual': return 'Годовая подписка';
      default: return 'Premium подписка';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Учителям', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openConstructor,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text('Конструктор уроков', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading || _loadingRates
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954)))
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
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
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                            ),
                            const SizedBox(height: 16),
                            const Text('Образовательный тариф', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text('Для преподавателей и учеников', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('ВЫБЕРИТЕ ПЛАН', style: TextStyle(color: Color(0xFF4A4A4A), fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _buildTariffCard(
                        title: 'Бесплатный',
                        usd: 0,
                        period: '',
                        description: 'Для тестирования',
                        features: const ['5 генераций', 'Конструктор уроков', 'Базовые шаблоны'],
                        isPopular: true,
                        onTap: _openConstructor,
                      ),
                      const SizedBox(height: 14),
                      _buildTariffCard(
                        title: 'Premium месяц',
                        usd: 9.99,
                        period: '/мес',
                        description: 'Безлимитный доступ',
                        features: const ['∞ генераций', 'Конструктор уроков PRO', 'Все шаблоны', 'Экспорт PDF'],
                        isPopular: false,
                        onTap: () => _showPaymentDialog('monthly', 9.99, '/мес'),
                      ),
                      const SizedBox(height: 14),
                      _buildTariffCard(
                        title: 'Premium полгода',
                        usd: 49.99,
                        period: '/6 мес',
                        description: 'Экономия 20%',
                        features: const ['∞ генераций', 'Конструктор уроков PRO', 'Все шаблоны', 'Экспорт PDF', 'Приоритетная поддержка'],
                        isPopular: false,
                        onTap: () => _showPaymentDialog('semiannual', 49.99, '/6 мес'),
                      ),
                      const SizedBox(height: 14),
                      _buildTariffCard(
                        title: 'Premium год',
                        usd: 89.99,
                        period: '/год',
                        description: 'Экономия 40%',
                        features: const ['∞ генераций', 'Конструктор уроков PRO', 'Все шаблоны', 'Экспорт PDF', 'Приоритетная поддержка', 'VIP статус'],
                        isPopular: false,
                        onTap: () => _showPaymentDialog('annual', 89.99, '/год'),
                      ),
                      const SizedBox(height: 32),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _openConstructor,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_calendar_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text('Открыть конструктор уроков', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _contactSales,
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
                                Text('Связаться с отделом образования', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTariffCard({
    required String title,
    required double usd,
    required String period,
    required String description,
    required List<String> features,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _selectedTariff == title.toLowerCase();
    final priceLabel = _formatPrice(usd);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1DB95420) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A),
              width: isSelected ? 1.5 : 1,
            ),
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
                      title.contains('Premium') ? Icons.stars_rounded : Icons.person_outline_rounded,
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
                children: [
                  Text(priceLabel, style: const TextStyle(color: Color(0xFF1DB954), fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  if (period.isNotEmpty && usd > 0) ...[
                    const SizedBox(width: 4),
                    Text(period, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
                  ],
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 16),
              const Text('Включено:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: features.map((feature) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                    const SizedBox(width: 6),
                    Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.email_rounded, color: Color(0xFF1DB954), size: 26),
              ),
              const SizedBox(height: 16),
              const Text('Образовательный отдел', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Напишите нам на почту для подбора образовательного тарифа',
                style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18),
                    SizedBox(width: 10),
                    Text('edu@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Закрыть', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}