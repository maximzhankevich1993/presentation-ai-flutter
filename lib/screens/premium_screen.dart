import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase    = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard    = Color(0xFF1E1E1E);
  static const bgHover   = Color(0xFF252525);
  static const border    = Color(0xFF2A2A2A);
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);
  static const accent       = Color(0xFF1DB954);
  static const accentLight  = Color(0xFF1ED760);
  static const accentDim    = Color(0xFF1DB95420);
  static const gold         = Color(0xFFFFD700);
  static const goldLight    = Color(0xFFFFD60A);
  static const danger       = Color(0xFFFF3B30);
}

const Map<String, double> _usdPrices = {
  'month': 4.99,
  'half': 29.99,
  'year': 49.99,
};

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _rate = 1.0;
  bool _loadingRates = true;
  String? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _detectCurrency();
  }

  Future<void> _detectCurrency() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final country = data['country_code'] ?? 'US';

        final localCurrencies = {
          'BY': {'code': 'BYN', 'symbol': 'Br', 'rate': 3.25},
          'RU': {'code': 'RUB', 'symbol': '₽', 'rate': 95.0},
          'KZ': {'code': 'KZT', 'symbol': '₸', 'rate': 460.0},
          'UA': {'code': 'UAH', 'symbol': '₴', 'rate': 41.0},
          'EU': {'code': 'EUR', 'symbol': '€', 'rate': 0.92},
          'GB': {'code': 'GBP', 'symbol': '£', 'rate': 0.79},
        };

        if (localCurrencies.containsKey(country)) {
          final c = localCurrencies[country]!;
          setState(() {
            _currency = c['code'] as String;
            _currencySymbol = c['symbol'] as String;
            _rate = (c['rate'] as num).toDouble();
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingRates = false);
  }

  String _formatPrice(double usdPrice) {
    final converted = (usdPrice * _rate);
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') {
      return '$_currencySymbol${converted.toStringAsFixed(2)}';
    }
    return '${converted.ceil()} $_currencySymbol';
  }

  String _periodPrice(double usdPrice, int months) {
    final monthly = usdPrice / months;
    final converted = (monthly * _rate);
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') {
      return '$_currencySymbol${converted.toStringAsFixed(2)}/мес';
    }
    return '${converted.ceil()} $_currencySymbol/мес';
  }

  void _selectPlan(String plan) {
    setState(() => _selectedPlan = plan);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Выбран план: $plan. Оплата будет доступна в ближайшее время.'),
        backgroundColor: _T.accent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: _T.txtSecondary, size: 17),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('Premium',
          style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        actions: [
          if (isPremium)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Активен', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Crown
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_T.goldLight, _T.gold], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),

              const Text('Разблокируй всё',
                style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w800, fontSize: 26, letterSpacing: -0.5),
                textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                _loadingRates ? 'Загрузка...' : 'Цены в $_currency',
                style: const TextStyle(color: _T.txtSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),

              // Comparison Table
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _T.bgSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _T.border),
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _T.border.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(children: [
                      const Expanded(flex: 3, child: Text('Функция', style: TextStyle(color: _T.txtSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                      const Expanded(flex: 2, child: Text('Бесплатно', textAlign: TextAlign.center, style: TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.star_rounded, color: _T.gold, size: 13),
                        const SizedBox(width: 4),
                        const Text('Premium', style: TextStyle(color: _T.gold, fontSize: 11, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                  ),
                  _ComparisonRow('Презентаций', '5', '∞'),
                  _ComparisonRow('Слайдов', '10', '50'),
                  _ComparisonRow('Фоны', '8', '16'),
                  _ComparisonRow('Шрифты', 'Inter', '3 стиля'),
                  _ComparisonRow('Анимации', '2', '6'),
                  _ComparisonRow('PDF', '❌', '✅'),
                  _ComparisonRow('AI-улучшение', '❌', '✅'),
                  _ComparisonRow('Свои картинки', '❌', '✅'),
                  _ComparisonRow('Водяной знак', 'Есть', 'Нет'),
                ]),
              ),
              const SizedBox(height: 24),

              // Plans
              _PlanCard(
                name: 'Месяц',
                price: _formatPrice(_usdPrices['month']!),
                period: '/мес',
                popular: false,
                selected: _selectedPlan == 'month',
                onTap: () => _selectPlan('month'),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                name: 'Полгода',
                price: _formatPrice(_usdPrices['half']!),
                period: _periodPrice(_usdPrices['half']!, 6),
                popular: true,
                badge: 'ЛУЧШИЙ ВЫБОР',
                selected: _selectedPlan == 'half',
                onTap: () => _selectPlan('half'),
              ),
              const SizedBox(height: 10),
              _PlanCard(
                name: 'Год',
                price: _formatPrice(_usdPrices['year']!),
                period: _periodPrice(_usdPrices['year']!, 12),
                popular: false,
                badge: 'ЭКОНОМИЯ 33%',
                selected: _selectedPlan == 'year',
                onTap: () => _selectPlan('year'),
              ),

              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _selectPlan('trial'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_T.goldLight, _T.gold]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: _T.gold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('3 дня бесплатно', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 11),
                const SizedBox(width: 4),
                const Text('Безопасная оплата', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
                const SizedBox(width: 12),
                const Icon(Icons.autorenew_rounded, color: _T.txtMuted, size: 11),
                const SizedBox(width: 4),
                const Text('Отмена в любое время', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
              ]),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// COMPARISON ROW
// ═══════════════════════════════════════════════════════════════
class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;

  const _ComparisonRow(this.feature, this.free, this.premium);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Expanded(flex: 3, child: Text(feature, style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(flex: 2, child: Text(free, textAlign: TextAlign.center, style: const TextStyle(color: _T.txtSecondary, fontSize: 13))),
        Expanded(flex: 2, child: Text(premium, textAlign: TextAlign.center, style: const TextStyle(color: _T.accentLight, fontSize: 13, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PLAN CARD
// ═══════════════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String period;
  final bool popular;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.popular,
    this.badge,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: popular ? _T.accentDim : _T.bgSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _T.accent : (popular ? _T.accent.withOpacity(0.5) : _T.border),
              width: selected ? 2 : (popular ? 1.5 : 1),
            ),
            boxShadow: (popular || selected) ? [BoxShadow(color: _T.accent.withOpacity(0.1), blurRadius: 8)] : null,
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                  ),
                Text(name, style: const TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(period, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
              ]),
            ),
            Text(price, style: const TextStyle(color: _T.accentLight, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: selected ? _T.accent : (popular ? _T.accent : _T.bgCard),
                shape: BoxShape.circle,
                border: Border.all(color: selected ? _T.accent : (popular ? _T.accent : _T.border)),
              ),
              child: Icon(
                selected ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: (selected || popular) ? Colors.white : _T.txtSecondary,
                size: 14,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}