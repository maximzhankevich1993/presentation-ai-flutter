import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/logo_provider.dart';
import '../providers/history_provider.dart';
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

// ═══════════════════════════════════════════════════════════════
// THEME
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase      = Color(0xFF121212);
  static const bgSurface   = Color(0xFF1A1A1A);
  static const bgCard      = Color(0xFF1E1E1E);
  static const bgHover     = Color(0xFF252525);
  static const border      = Color(0xFF2A2A2A);
  static const txtPrimary  = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted    = Color(0xFF4A4A4A);
  static const accent      = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim   = Color(0xFF1DB95420);
  static const danger      = Color(0xFFFF3B30);
  static const gold        = Color(0xFFFFD700);
  static const goldLight   = Color(0xFFFFD60A);
}

// ═══════════════════════════════════════════════════════════════
// HOME SCREEN
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _topicController = TextEditingController();
  final _focusNode = FocusNode();
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
  
  // VIP данные для продакшена (0 занято, 50 свободно)
  int _vipOccupiedSpots = 0;
  int _vipTotalSpots = 50;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
    _detectCurrency();
    _loadVipStats();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadVipStats() async {
    try {
      // TODO: Заменить на реальный API запрос, когда появится
      // final stats = await ApiService.getVipStats();
      // setState(() {
      //   _vipOccupiedSpots = stats['occupiedSpots'];
      //   _vipTotalSpots = stats['totalSpots'];
      // });
      
      // Для продакшена: 0 занято, 50 свободно
      if (mounted) {
        setState(() {
          _vipOccupiedSpots = 0;
          _vipTotalSpots = 50;
        });
      }
    } catch (_) {}
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
          'DE', 'FR', 'IT', 'ES', 'NL', 'BE', 'AT', 'PT', 'FI',
          'IE', 'GR', 'SK', 'SI', 'EE', 'LV', 'LT', 'LU', 'MT', 'CY',
        };
        final currencyMap = <String, Map<String, dynamic>>{
          'BY': {'code': 'BYN', 'symbol': 'Br',  'rate': 3.25},
          'RU': {'code': 'RUB', 'symbol': '₽',   'rate': 95.0},
          'KZ': {'code': 'KZT', 'symbol': '₸',   'rate': 460.0},
          'UA': {'code': 'UAH', 'symbol': '₴',   'rate': 41.0},
          'GB': {'code': 'GBP', 'symbol': '£',   'rate': 0.79},
        };
        if (currencyMap.containsKey(countryCode)) {
          final entry = currencyMap[countryCode]!;
          if (mounted) {
            setState(() {
              _currency       = entry['code'] as String;
              _currencySymbol = entry['symbol'] as String;
              _rate           = (entry['rate'] as num).toDouble();
            });
          }
        } else if (euroCountries.contains(countryCode)) {
          if (mounted) {
            setState(() {
              _currency       = 'EUR';
              _currencySymbol = '€';
              _rate           = 0.92;
            });
          }
        }
      }
    } catch (_) {}
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

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _generate({String? overrideTopic}) {
    final topic = (overrideTopic ?? _topicController.text).trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Введите тему'),
        backgroundColor: _T.gold.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ));
      return;
    }
    try {
      Provider.of<UserHistoryProvider>(context, listen: false)
          .add(topic, slideCount: _maxSlides);
    } catch (_) {}
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoadingScreen(topic: topic, slideCount: _maxSlides),
      ),
    );
  }

  void _showTextInput() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _T.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Загрузите текст', style: TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Вставьте текст...', style: TextStyle(color: _T.txtSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 13, color: _T.txtPrimary),
                decoration: InputDecoration(
                  hintText: 'Ваш текст...',
                  hintStyle: const TextStyle(color: _T.txtMuted),
                  filled: true,
                  fillColor: _T.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.accent)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
                      child: const Center(child: Text('Отмена', style: TextStyle(color: _T.txtSecondary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        _generate(overrideTopic: text.length > 50 ? '${text.substring(0, 50)}...' : text);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                    ),
                  ),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadLogo() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (!up.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Загрузка логотипа — Premium'),
        backgroundColor: _T.gold.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ));
      return;
    }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) {
        Provider.of<BrandKitProvider>(context, listen: false).setLogo(reader.result as String);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.check_rounded, color: Colors.white, size: 14)),
            const SizedBox(width: 10),
            const Text('Логотип загружен!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          backgroundColor: _T.accent.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        ));
      });
    });
  }

  void _showHistory() {
    final records = Provider.of<UserHistoryProvider>(context, listen: false).records;
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)))),
            const Text('История', style: TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (records.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Пока нет генераций', style: TextStyle(color: _T.txtMuted, fontSize: 13))))
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const Divider(color: _T.border, height: 1),
                  itemBuilder: (_, i) {
                    final rec = records[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.slideshow_outlined, color: _T.accent, size: 18)),
                      title: Text(rec.topic, style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${rec.slideCount} слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 11)),
                      trailing: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () { Navigator.pop(ctx); _generate(overrideTopic: rec.topic); },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: const Text('Повторить', style: TextStyle(color: _T.accent, fontSize: 11, fontWeight: FontWeight.w600))),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipIcon() {
    final bool isVipAvailable = _vipOccupiedSpots < _vipTotalSpots;
    if (!isVipAvailable) return const SizedBox.shrink();
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _push(const VipScreen()),
        child: Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFD60A)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                'VIP ${_vipTotalSpots - _vipOccupiedSpots}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final logo = Provider.of<BrandKitProvider>(context).logoUrl;
    final left = up.freeGenerationsLeft;
    final isLoggedIn = up.isLoggedIn;

    return Scaffold(
      backgroundColor: _T.bgBase,
      appBar: AppBar(
        backgroundColor: _T.bgBase,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 28, height: 28, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
            const SizedBox(width: 8),
            const Text('Презентатор ИИ', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.3)),
          ],
        ),
        actions: [
          _buildVipIcon(),
          if (logo != null) _AppBarBtn(Icons.image_rounded, _T.accentLight, () {}, tooltip: 'Логотип загружен'),
          _AppBarBtn(Icons.history_rounded, _T.txtSecondary, _showHistory, tooltip: 'История'),
          _AppBarBtn(
            Icons.person_outline_rounded,
            _T.txtSecondary,
            () {
              if (isLoggedIn) {
                _push(const ProfileScreen());
              } else {
                _push(const LoginScreen());
              }
            },
            tooltip: isLoggedIn ? 'Профиль' : 'Войти',
          ),
          _AppBarBtn(Icons.settings_outlined, _T.txtSecondary, () => _push(const SettingsScreen()), tooltip: 'Настройки'),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Создай презентацию', style: TextStyle(color: _T.txtPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                const SizedBox(height: 6),
                const Text('с помощью ИИ за 1 минуту', style: TextStyle(color: _T.txtSecondary, fontSize: 14)),
                const SizedBox(height: 28),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _isFocused ? _T.accent.withOpacity(0.6) : _T.border, width: _isFocused ? 1.5 : 1)),
                  child: TextField(
                    controller: _topicController,
                    focusNode: _focusNode,
                    style: const TextStyle(fontSize: 14, color: _T.txtPrimary),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: 'О чём презентация?', hintStyle: TextStyle(color: _T.txtMuted, fontSize: 14), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                    onSubmitted: (_) => _generate(),
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Количество слайдов', style: TextStyle(color: _T.txtMuted, fontSize: 11)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: Text('$_maxSlides', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12)))]),
                      const SizedBox(height: 4),
                      SliderTheme(
                        data: SliderThemeData(activeTrackColor: _T.accent, inactiveTrackColor: _T.border, thumbColor: _T.accent, overlayColor: _T.accentDim, trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7)),
                        child: Slider(value: _maxSlides.toDouble(), min: 3, max: 10, divisions: 7, onChanged: (v) => setState(() => _maxSlides = v.round())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                ScaleTransition(
                  scale: _pulseAnimation,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _generate,
                      child: Container(
                        width: double.infinity, height: 48,
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: Colors.white, size: 16), SizedBox(width: 8), Text('Создать', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15))]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
                  children: _examples.map((example) {
                    final selected = _topicController.text == example;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _topicController.text = example),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(color: selected ? _T.accentDim : _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? _T.accent.withOpacity(0.5) : _T.border)),
                          child: Text(example, style: TextStyle(fontSize: 12, color: selected ? _T.accent : _T.txtSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _ExtraBtn(Icons.article_outlined, 'Из текста', _showTextInput),
                  const SizedBox(width: 10),
                  _ExtraBtn(Icons.image_outlined, 'Из логотипа', _uploadLogo),
                ]),

                if (logo != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(logo, width: 40, height: 40, fit: BoxFit.cover)),
                      const SizedBox(width: 12),
                      const Text('Логотип загружен', style: TextStyle(color: _T.accentLight, fontSize: 12, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => Provider.of<BrandKitProvider>(context, listen: false).clear(), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 16))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.bolt, color: _T.accent, size: 14), const SizedBox(width: 4), const Text('Осталось генераций: ', style: TextStyle(color: _T.txtSecondary, fontSize: 11)), Text('$left из 5', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12))]),
                    const SizedBox(height: 8),
                    SizedBox(width: 160, height: 4, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: left / 5.0, backgroundColor: _T.border, valueColor: const AlwaysStoppedAnimation<Color>(_T.accent)))),
                  ]),
                ),
                const SizedBox(height: 28),

                const Text('Выберите план', style: TextStyle(color: _T.txtPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(_loadingRates ? 'Загрузка...' : 'Цены в $_currency', style: const TextStyle(color: _T.txtSecondary, fontSize: 12)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _TariffCard(title: 'Бесплатно', usd: 0, formatPrice: _formatPrice, period: '', features: ['5 генераций', '10 слайдов', '8 фонов', 'Базовый экспорт'], popular: false, onTap: () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _TariffCard(title: 'Месяц', usd: 4.99, formatPrice: _formatPrice, period: '/мес', features: ['∞ генераций', '50 слайдов', '16 фонов', 'PDF без знака', 'AI-улучшение'], popular: true, onTap: () => _push(const PremiumScreen()))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _TariffCard(title: 'Полгода', usd: 29.99, formatPrice: _formatPrice, period: '${_formatPrice(29.99 / 6)}/мес', features: ['Всё из Месяца', 'Экономия 17%', 'Приоритетная поддержка'], popular: false, onTap: () => _push(const PremiumScreen()))),
                  const SizedBox(width: 12),
                  Expanded(child: _TariffCard(title: 'Год', usd: 49.99, formatPrice: _formatPrice, period: '${_formatPrice(49.99 / 12)}/мес', features: ['Всё из Полугода', 'Экономия 33%', 'Бренд-кит'], popular: false, badge: 'ВЫГОДНО', onTap: () => _push(const PremiumScreen()))),
                ]),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.border)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _NavItem(Icons.school_outlined, 'Учителям', () => _push(TeacherScreen(countryCode: _countryCode))),
                    _NavItem(Icons.business_center_outlined, 'Бизнесу', () => _push(CorporateScreen(countryCode: _countryCode))),
                    _NavItem(Icons.group_outlined, 'Команда', () => _push(const WorkspaceScreen())),
                    _NavItem(Icons.quiz_outlined, 'Тесты', () => _push(const QuizScreen())),
                    _NavItem(Icons.card_giftcard_outlined, 'Друзья', () => _push(const ReferralScreen())),
                    _NavItem(Icons.person_outline, 'Профиль', () => _push(const ProfileScreen())),
                  ]),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TARIFF CARD
// ═══════════════════════════════════════════════════════════════
class _TariffCard extends StatelessWidget {
  final String title;
  final double usd;
  final String Function(double) formatPrice;
  final String period;
  final List<String> features;
  final bool popular;
  final String? badge;
  final VoidCallback onTap;

  const _TariffCard({required this.title, required this.usd, required this.formatPrice, required this.period, required this.features, required this.popular, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceLabel = formatPrice(usd);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: popular ? _T.accentDim : _T.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: popular ? _T.accent.withOpacity(0.5) : _T.border, width: popular ? 1.5 : 1),
            boxShadow: popular ? [BoxShadow(color: _T.accent.withOpacity(0.15), blurRadius: 12)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (popular || badge != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(gradient: popular ? const LinearGradient(colors: [_T.accent, _T.accentLight]) : const LinearGradient(colors: [_T.goldLight, _T.gold]), borderRadius: BorderRadius.circular(5)),
                  child: Text(badge ?? (popular ? 'ПОПУЛЯРНЫЙ' : ''), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                ),
              Text(title, style: const TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(priceLabel, style: const TextStyle(color: _T.accentLight, fontSize: 20, fontWeight: FontWeight.w900)),
                if (period.isNotEmpty && usd > 0) ...[const SizedBox(width: 2), Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(period, style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))],
              ]),
              const SizedBox(height: 10),
              ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [const Icon(Icons.check_rounded, color: _T.accent, size: 13), const SizedBox(width: 5), Expanded(child: Text(f, style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))]))),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════
class _AppBarBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  const _AppBarBtn(this.icon, this.color, this.onTap, {required this.tooltip});
  @override
  State<_AppBarBtn> createState() => _AppBarBtnState();
}

class _AppBarBtnState extends State<_AppBarBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hovered = true),
    onExit:  (_) => setState(() => _hovered = false),
    child: Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 34, height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(color: _hovered ? _T.bgHover : Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(10)),
          child: Icon(widget.icon, color: widget.color, size: 17),
        ),
      ),
    ),
  );
}

class _ExtraBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ExtraBtn(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: _T.txtSecondary), const SizedBox(width: 7), Text(label, style: const TextStyle(fontSize: 12, color: _T.txtSecondary, fontWeight: FontWeight.w500))]),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20, color: _T.txtSecondary), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 9, color: _T.txtSecondary, fontWeight: FontWeight.w500))]),
      ),
    ),
  );
}