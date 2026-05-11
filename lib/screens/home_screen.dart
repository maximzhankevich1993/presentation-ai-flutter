import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'loading_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'workspace_screen.dart';
import 'teacher_screen.dart';
import 'corporate_screen.dart';
import 'referral_screen.dart';
import 'vip_screen.dart';
import 'login_screen.dart';
import 'quiz_screen.dart';

class _T {
  static const bgBase = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard = Color(0xFF1E1E1E);
  static const bgHover = Color(0xFF252525);
  static const border = Color(0xFF2A2A2A);
  static const txtPrimary = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted = Color(0xFF4A4A4A);
  static const accent = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim = Color(0xFF1DB95420);
  static const danger = Color(0xFFFF3B30);
  static const gold = Color(0xFFFFD700);
  static const goldLight = Color(0xFFFFD60A);
}

class LogoProvider extends ChangeNotifier {
  String? _logoUrl;
  String? get logoUrl => _logoUrl;
  void setLogo(String url) { _logoUrl = url; notifyListeners(); }
  void clear() { _logoUrl = null; notifyListeners(); }
}

class HistoryProvider extends ChangeNotifier {
  final List<GenerationRecord> _records = [];
  List<GenerationRecord> get records => List.unmodifiable(_records);
  void add(String topic, {int slideCount = 5}) {
    _records.insert(0, GenerationRecord(topic: topic, slideCount: slideCount, createdAt: DateTime.now()));
    if (_records.length > 20) _records.removeLast();
    notifyListeners();
  }
}

class GenerationRecord {
  final String topic;
  final int slideCount;
  final DateTime createdAt;
  const GenerationRecord({required this.topic, required this.slideCount, required this.createdAt});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _maxSlides = 5;
  bool _isFocused = false;

  String _currency = 'USD';
  String _currencySymbol = '\$';
  double _rate = 1.0;
  bool _loadingRates = true;

  final List<String> _examples = ['ИИ', 'Бизнес', 'Экология', 'Космос', 'IT', 'Маркетинг'];
  String get _countryCode => PlatformDispatcher.instance.locale.countryCode ?? 'RU';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _detectCurrency();
  }

  Future<void> _detectCurrency() async {
    try {
      final r = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final d = json.decode(r.body);
        final c = d['country_code'] ?? 'US';
        final m = {
          'BY': {'code': 'BYN', 'symbol': 'Br', 'rate': 3.25},
          'RU': {'code': 'RUB', 'symbol': '₽', 'rate': 95.0},
          'KZ': {'code': 'KZT', 'symbol': '₸', 'rate': 460.0},
          'UA': {'code': 'UAH', 'symbol': '₴', 'rate': 41.0},
          'EU': {'code': 'EUR', 'symbol': '€', 'rate': 0.92},
          'GB': {'code': 'GBP', 'symbol': '£', 'rate': 0.79},
        };
        if (m.containsKey(c)) { final x = m[c]!; setState(() { _currency = x['code'] as String; _currencySymbol = x['symbol'] as String; _rate = (x['rate'] as num).toDouble(); }); }
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingRates = false);
  }

  String _formatPrice(double usd) {
    final v = usd * _rate;
    if (_currency == 'USD' || _currency == 'EUR' || _currency == 'GBP') return '$_currencySymbol${v.toStringAsFixed(2)}';
    return '${v.ceil()} $_currencySymbol';
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _push(Widget s) => Navigator.push(context, MaterialPageRoute(builder: (_) => s));

  void _generate({String? overrideTopic}) {
    final t = (overrideTopic ?? _topicController.text).trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Введите тему'), backgroundColor: _T.gold.withOpacity(0.9), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.fromLTRB(16, 0, 16, 24)));
      return;
    }
    try { Provider.of<HistoryProvider>(context, listen: false).add(t, slideCount: _maxSlides); } catch (_) {}
    Navigator.push(context, MaterialPageRoute(builder: (_) => LoadingScreen(topic: t)));
  }

  void _showTextInput() {
    final c = TextEditingController();
    showDialog(context: context, builder: (ctx) => Dialog(backgroundColor: _T.bgSurface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Загрузите текст', style: TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      const Text('Вставьте текст...', style: TextStyle(color: _T.txtSecondary, fontSize: 13)),
      const SizedBox(height: 20),
      TextField(controller: c, maxLines: 6, style: const TextStyle(fontSize: 13, color: _T.txtPrimary), decoration: InputDecoration(hintText: 'Ваш текст...', hintStyle: const TextStyle(color: _T.txtMuted), filled: true, fillColor: _T.bgCard, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.accent)))),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => Navigator.pop(ctx), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)), child: const Center(child: Text('Отмена', style: TextStyle(color: _T.txtSecondary, fontWeight: FontWeight.w600))))))),
        const SizedBox(width: 12),
        Expanded(child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () { Navigator.pop(ctx); final x = c.text.trim(); if (x.isNotEmpty) _generate(overrideTopic: x.length > 50 ? '${x.substring(0, 50)}...' : x); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))))))),
      ]),
    ]))));
  }

  void _uploadLogo() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (!up.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Загрузка логотипа — Premium'), backgroundColor: _T.gold.withOpacity(0.9), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.fromLTRB(16, 0, 16, 24)));
      return;
    }
    final inp = html.FileUploadInputElement()..accept = 'image/*';
    inp.click();
    inp.onChange.listen((e) {
      final f = inp.files?.first; if (f == null) return;
      final r = html.FileReader(); r.readAsDataUrl(f);
      r.onLoad.listen((_) { Provider.of<LogoProvider>(context, listen: false).setLogo(r.result as String); setState(() {}); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)), const SizedBox(width: 10), const Text('Логотип загружен!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))]), backgroundColor: _T.accent.withOpacity(0.9), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.fromLTRB(16, 0, 16, 24))); });
    });
  }

  void _showHistory() {
    final recs = Provider.of<HistoryProvider>(context, listen: false).records;
    showModalBottomSheet(context: context, backgroundColor: _T.bgSurface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)))),
      const Text('История', style: TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      if (recs.isEmpty) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Пока нет генераций', style: TextStyle(color: _T.txtMuted, fontSize: 13))))
      else ConstrainedBox(constraints: BoxConstraints(maxHeight: 320.h), child: ListView.separated(shrinkWrap: true, itemCount: recs.length, separatorBuilder: (_, __) => const Divider(color: _T.border, height: 1), itemBuilder: (_, i) { final r = recs[i]; return ListTile(contentPadding: EdgeInsets.zero, leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.slideshow_outlined, color: _T.accent, size: 18)), title: Text(r.topic, style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600)), subtitle: Text('${r.slideCount} слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 11)), trailing: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () { Navigator.pop(ctx); _generate(overrideTopic: r.topic); }, child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: const Text('Повторить', style: TextStyle(color: _T.accent, fontSize: 11, fontWeight: FontWeight.w600)))))); })),
    ])));
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final logo = Provider.of<LogoProvider>(context).logoUrl;
    final left = up.freeGenerationsLeft;

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
          const SizedBox(width: 8),
          const Text('Презентатор ИИ', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.3)),
        ]),
        centerTitle: true,
        actions: [
          if (logo != null) _AppBarBtn(Icons.image_rounded, _T.accentLight, () {}, tooltip: 'Логотип загружен'),
          _AppBarBtn(Icons.history_rounded, _T.txtSecondary, _showHistory, tooltip: 'История'),
          _AppBarBtn(Icons.person_outline_rounded, _T.txtSecondary, () => _push(const ProfileScreen()), tooltip: 'Профиль'),
          _AppBarBtn(Icons.settings_outlined, _T.txtSecondary, () => _push(const SettingsScreen()), tooltip: 'Настройки'),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Создай презентацию', style: TextStyle(color: _T.txtPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
              const SizedBox(height: 6),
              const Text('с помощью ИИ за 1 минуту', style: TextStyle(color: _T.txtSecondary, fontSize: 14)),
              const SizedBox(height: 28),
              // Input
              AnimatedContainer(duration: const Duration(milliseconds: 200), width: double.infinity, decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isFocused ? _T.accent.withOpacity(0.6) : _T.border, width: _isFocused ? 1.5 : 1)), child: TextField(controller: _topicController, focusNode: _focusNode, style: const TextStyle(fontSize: 14, color: _T.txtPrimary), textAlign: TextAlign.center, decoration: const InputDecoration(hintText: 'О чём презентация?', hintStyle: TextStyle(color: _T.txtMuted, fontSize: 14), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)), onSubmitted: (_) => _generate())),
              const SizedBox(height: 12),
              // Slider
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Количество слайдов', style: TextStyle(color: _T.txtMuted, fontSize: 11)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: Text('$_maxSlides', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12)))]),
                const SizedBox(height: 4),
                SliderTheme(data: SliderThemeData(activeTrackColor: _T.accent, inactiveTrackColor: _T.border, thumbColor: _T.accent, overlayColor: _T.accentDim, trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)), child: Slider(value: _maxSlides.toDouble(), min: 3, max: 10, divisions: 7, onChanged: (v) => setState(() => _maxSlides = v.round()))),
              ])),
              const SizedBox(height: 10),
              // Generate button
              ScaleTransition(
                scale: _pulseAnimation,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _generate,
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Chips
              Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: _examples.map((e) { final s = _topicController.text == e; return MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => setState(() => _topicController.text = e), child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: s ? _T.accentDim : _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: s ? _T.accent.withOpacity(0.5) : _T.border)), child: Text(e, style: TextStyle(fontSize: 12, color: s ? _T.accent : _T.txtSecondary, fontWeight: s ? FontWeight.w600 : FontWeight.w400))))); }).toList()),
              const SizedBox(height: 16),
              // Extra
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [_ExtraBtn(Icons.article_outlined, 'Из текста', _showTextInput), const SizedBox(width: 10), _ExtraBtn(Icons.image_outlined, 'Из логотипа', _uploadLogo)]),
              // Logo preview
              if (logo != null) ...[
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(logo!, width: 40, height: 40, fit: BoxFit.cover)), const SizedBox(width: 12), const Text('Логотип загружен', style: TextStyle(color: _T.accentLight, fontSize: 12, fontWeight: FontWeight.w500)), const Spacer(), MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => Provider.of<LogoProvider>(context, listen: false).clear(), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 16)))]))],
              const SizedBox(height: 20),
              // Counter
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.bolt, color: _T.accent, size: 14), const SizedBox(width: 4), const Text('Осталось генераций: ', style: TextStyle(color: _T.txtSecondary, fontSize: 11)), Text('$left из 5', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12))]), const SizedBox(height: 8), SizedBox(width: 160, height: 4, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: left / 5.0, backgroundColor: _T.border, valueColor: const AlwaysStoppedAnimation<Color>(_T.accent))))])),
              const SizedBox(height: 28),
              // Tariffs
              const Text('Выберите план', style: TextStyle(color: _T.txtPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(_loadingRates ? 'Загрузка...' : 'Цены в $_currency', style: const TextStyle(color: _T.txtSecondary, fontSize: 12)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _TariffCard(title: 'Бесплатно', price: '0', period: '', features: ['5 генераций', '10 слайдов', '8 фонов', 'Базовый экспорт'], popular: false, onTap: () {})),
                const SizedBox(width: 12),
                Expanded(child: _TariffCard(title: 'Месяц', price: _formatPrice(4.99), period: '/мес', features: ['∞ генераций', '50 слайдов', '16 фонов', 'PDF без знака', 'AI-улучшение'], popular: true, onTap: () => _push(const PremiumScreen()))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _TariffCard(title: 'Полгода', price: _formatPrice(29.99), period: '${_formatPrice(29.99 / 6)}/мес', features: ['Всё из Месяца', 'Экономия 17%', 'Приоритетная поддержка'], popular: false, onTap: () => _push(const PremiumScreen()))),
                const SizedBox(width: 12),
                Expanded(child: _TariffCard(title: 'Год', price: _formatPrice(49.99), period: '${_formatPrice(49.99 / 12)}/мес', features: ['Всё из Полугода', 'Экономия 33%', 'Бренд-кит'], popular: false, badge: 'ВЫГОДНО', onTap: () => _push(const PremiumScreen()))),
              ]),
              const SizedBox(height: 28),
              // Bottom nav
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.border)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _NavItem(Icons.school_outlined, 'Учителям', () => _push(TeacherScreen(countryCode: _countryCode))),
                _NavItem(Icons.business_center_outlined, 'Бизнесу', () => _push(CorporateScreen(countryCode: _countryCode))),
                _NavItem(Icons.group_outlined, 'Команда', () => _push(const WorkspaceScreen())),
                _NavItem(Icons.quiz_outlined, 'Тесты', () => _push(const QuizScreen())),
                _NavItem(Icons.card_giftcard_outlined, 'Друзья', () => _push(const ReferralScreen())),
                _NavItem(Icons.person_outline, 'Профиль', () => _push(const ProfileScreen())),
              ])),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  final String title, price, period;
  final List<String> features;
  final bool popular;
  final String? badge;
  final VoidCallback onTap;
  const _TariffCard({required this.title, required this.price, required this.period, required this.features, required this.popular, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: popular ? _T.accentDim : _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: popular ? _T.accent.withOpacity(0.5) : _T.border, width: popular ? 1.5 : 1), boxShadow: popular ? [BoxShadow(color: _T.accent.withOpacity(0.15), blurRadius: 12)] : null), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (popular || badge != null) Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: popular ? const LinearGradient(colors: [_T.accent, _T.accentLight]) : const LinearGradient(colors: [_T.goldLight, _T.gold]), borderRadius: BorderRadius.circular(5)), child: Text(badge ?? (popular ? 'ПОПУЛЯРНЫЙ' : ''), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
    Text(title, style: const TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
    const SizedBox(height: 4),
    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(price == '\$0.00' || price == '0 Br' || price == '0 ₽' || price == '0' ? 'Бесплатно' : price, style: const TextStyle(color: _T.accentLight, fontSize: 20, fontWeight: FontWeight.w900)),
      if (period.isNotEmpty) ...[const SizedBox(width: 2), Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(period, style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))],
    ]),
    const SizedBox(height: 10),
    ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [const Icon(Icons.check_rounded, color: _T.accent, size: 13), const SizedBox(width: 5), Expanded(child: Text(f, style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))]))),
  ]))));
}

class _AppBarBtn extends StatefulWidget {
  final IconData icon; final Color color; final VoidCallback onTap; final String tooltip;
  const _AppBarBtn(this.icon, this.color, this.onTap, {required this.tooltip});
  @override State<_AppBarBtn> createState() => _AppBarBtnState();
}
class _AppBarBtnState extends State<_AppBarBtn> {
  bool _h = false;
  @override Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false), child: Tooltip(message: widget.tooltip, child: GestureDetector(onTap: widget.onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 120), width: 34, height: 34, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: _h ? _T.bgHover : Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(10)), child: Icon(widget.icon, color: widget.color, size: 17)))));
}
class _ExtraBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ExtraBtn(this.icon, this.label, this.onTap);
  @override Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: _T.txtSecondary), const SizedBox(width: 7), Text(label, style: const TextStyle(fontSize: 12, color: _T.txtSecondary, fontWeight: FontWeight.w500))]))));
}
class _NavItem extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.onTap);
  @override Widget build(BuildContext context) => MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20, color: _T.txtSecondary), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 9, color: _T.txtSecondary, fontWeight: FontWeight.w500))]))));
}