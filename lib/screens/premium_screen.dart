import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
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
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<UserProvider>(context).isPremium;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // ── Crown ──────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_T.goldLight, _T.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: _T.gold.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────────
            const Text('Разблокируй всё',
              style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w800, fontSize: 26, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            const Text('Безлимитные презентации, все функции и фоны',
              style: TextStyle(color: _T.txtSecondary, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center),
            const SizedBox(height: 28),

            // ── Comparison Table ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: _T.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _T.border),
              ),
              child: Column(children: [
                // Header
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

            // ── Plans ──────────────────────────────────────────
            _PlanCard(
              name: 'Месяц',
              price: '\$4.99',
              period: '/мес',
              popular: false,
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _PlanCard(
              name: 'Полгода',
              price: '\$3.99',
              period: '/мес',
              popular: true,
              badge: 'ЛУЧШИЙ ВЫБОР',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _PlanCard(
              name: 'Год',
              price: '\$2.99',
              period: '/мес',
              popular: false,
              badge: 'ЭКОНОМИЯ 40%',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ── Trial ──────────────────────────────────────────
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {},
                child: Container(
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

            // ── Secure ─────────────────────────────────────────
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
  final VoidCallback onTap;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.popular,
    this.badge,
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
              color: popular ? _T.accent.withOpacity(0.5) : _T.border,
              width: popular ? 1.5 : 1,
            ),
            boxShadow: popular ? [BoxShadow(color: _T.accent.withOpacity(0.1), blurRadius: 8)] : null,
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
                const Text('Полный доступ', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
              ]),
            ),
            Text(price, style: const TextStyle(color: _T.accentLight, fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(width: 2),
            Text(period, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: popular ? _T.accent : _T.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: popular ? _T.accent : _T.border),
              ),
              child: Icon(
                popular ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: popular ? Colors.white : _T.txtSecondary,
                size: 14,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}