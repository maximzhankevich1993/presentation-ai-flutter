import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lesson_constructor_screen.dart';

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
  
  // Валюты
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
        
        print('📍 TeacherScreen - Страна: $countryCode');
        
        const euroCountries = {
          'IT', 'FR', 'DE', 'ES', 'NL', 'BE', 'AT', 'PT', 'FI',
          'IE', 'GR', 'SK', 'SI', 'EE', 'LV', 'LT', 'LU', 'MT', 'CY',
        };
        
        // BYN для Беларуси
        if (countryCode == 'BY') {
          setState(() {
            _currency = 'BYN';
            _currencySymbol = 'Br';
            _rate = 3.25;
          });
        }
        // RUB для России
        else if (countryCode == 'RU') {
          setState(() {
            _currency = 'RUB';
            _currencySymbol = '₽';
            _rate = 95.0;
          });
        }
        // KZT для Казахстана
        else if (countryCode == 'KZ') {
          setState(() {
            _currency = 'KZT';
            _currencySymbol = '₸';
            _rate = 460.0;
          });
        }
        // UAH для Украины
        else if (countryCode == 'UA') {
          setState(() {
            _currency = 'UAH';
            _currencySymbol = '₴';
            _rate = 41.0;
          });
        }
        // GBP для Великобритании
        else if (countryCode == 'GB') {
          setState(() {
            _currency = 'GBP';
            _currencySymbol = '£';
            _rate = 0.79;
          });
        }
        // EUR для Европы
        else if (euroCountries.contains(countryCode)) {
          setState(() {
            _currency = 'EUR';
            _currencySymbol = '€';
            _rate = 0.92;
          });
        }
        // USD для остальных
        else {
          setState(() {
            _currency = 'USD';
            _currencySymbol = '\$';
            _rate = 1.0;
          });
        }
      }
    } catch (e) {
      print('Ошибка определения валюты: $e');
      setState(() {
        _currency = 'USD';
        _currencySymbol = '\$';
        _rate = 1.0;
      });
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

  void _openConstructor() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LessonConstructorScreen()),
    );
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
                          gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.school_rounded, color: Colors.white, size: 26)),
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
                        title: 'Учитель',
                        usd: 0,
                        period: 'бесплатно',
                        description: 'Для преподавателей',
                        features: const ['10 генераций в месяц', '15 слайдов', 'Конструктор уроков'],
                        isPopular: true,
                        onTap: () => setState(() => _selectedTariff = 'teacher'),
                      ),
                      const SizedBox(height: 14),

                      _buildTariffCard(
                        title: 'Школа',
                        usd: 15.99,
                        period: '/мес',
                        description: 'Для школ и классов',
                        features: const ['До 30 учителей', '∞ генераций', 'Конструктор уроков PRO'],
                        isPopular: false,
                        onTap: () => setState(() => _selectedTariff = 'school'),
                      ),
                      const SizedBox(height: 14),

                      _buildTariffCard(
                        title: 'Университет',
                        usd: 49.99,
                        period: '/мес',
                        description: 'Для вузов и колледжей',
                        features: const ['Неограниченно преподавателей', '∞ генераций', 'Конструктор уроков PRO'],
                        isPopular: false,
                        onTap: () => setState(() => _selectedTariff = 'university'),
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
                            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A2A))),
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
            border: Border.all(color: isSelected ? const Color(0xFF1DB954).withOpacity(0.5) : const Color(0xFF2A2A2A), width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: isPopular ? const Color(0xFF1DB954) : const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)),
                    child: Icon(title == 'Учитель' ? Icons.person_outline_rounded : Icons.school_rounded, color: isPopular ? Colors.white : const Color(0xFF1DB954), size: 22),
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
                  if (isPopular) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF1ED760)]), borderRadius: BorderRadius.circular(12)), child: const Text('Популярный', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
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
                  if (isSelected) Container(width: 24, height: 24, decoration: BoxDecoration(color: const Color(0xFF1DB954), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 16),
              const Text('Включено:', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12, runSpacing: 10,
                children: features.map((feature) => Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF1DB954), size: 14),
                  const SizedBox(width: 6),
                  Text(feature, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ])).toList(),
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
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF1DB954).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.email_rounded, color: Color(0xFF1DB954), size: 26)),
              const SizedBox(height: 16),
              const Text('Образовательный отдел', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Напишите нам на почту для подбора образовательного тарифа', style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))), child: const Row(children: [Icon(Icons.email_outlined, color: Color(0xFF1DB954), size: 18), SizedBox(width: 10), Text('edu@presentator.ai', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))])),
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