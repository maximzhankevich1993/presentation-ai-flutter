import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../providers/logo_provider.dart';
import '../providers/history_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_strings.dart';
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
import 'template_selector_screen.dart';

// ═══════════════════════════════════════════════════════════════
// CRYPTO PAYMENT URL
// ═══════════════════════════════════════════════════════════════
const String CRYPTO_PAYMENT_URL = 'https://pay.cryptocloud.plus/pos/L1dhlsPbHiuNO7Fv';

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

  String _countryCode = 'US';

  final List<String> _examples = ['AI', 'Business', 'Ecology', 'Space', 'IT', 'Marketing'];
  
  int _vipOccupiedSpots = 0;
  int _vipTotalSpots = 50;
  
  int _remainingGenerations = 5;

  // Ключи для локального хранения счётчика генераций (для гостей)
  static const String _genCountKey = 'guest_gen_count';
  static const String _genDateKey = 'guest_gen_date';

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
    _detectCountry();
    _loadVipStats();
    _loadUserData();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // LOCAL GENERATION COUNTER (для гостей)
  // ─────────────────────────────────────────────────────────────
  Future<int> _getGuestGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(_genDateKey);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    if (savedDate != today) {
      await prefs.setInt(_genCountKey, 0);
      await prefs.setString(_genDateKey, today);
      return 0;
    }
    return prefs.getInt(_genCountKey) ?? 0;
  }

  Future<void> _incrementGuestGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await _getGuestGenerationCount();
    await prefs.setInt(_genCountKey, current + 1);
  }

  Future<bool> _canGenerate() async {
    final up = Provider.of<UserProvider>(context, listen: false);
    
    if (up.isPremium || up.isVip) return true;
    
    if (up.isLoggedIn) {
      await up.loadUser();
      return up.freeGenerationsLeft > 0;
    }
    
    final count = await _getGuestGenerationCount();
    return count < 5;
  }

  void _openCryptoPayment(double amount) {
    final url = amount > 0 ? '$CRYPTO_PAYMENT_URL?amount=$amount' : CRYPTO_PAYMENT_URL;
    html.window.open(url, '_blank');
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('💸 ${AppStrings.current.afterPaymentMessage}'),
      backgroundColor: _T.accent.withOpacity(0.9),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 5),
    ));
  }

  void _showUpgradeOffer() async {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (up.isPremium || up.isVip) return;
    
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _T.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.bolt, color: _T.accent, size: 24),
            const SizedBox(width: 8),
            Text(AppStrings.current.upgradeToUnlimited, style: const TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.current.usedThreeOfFive, style: const TextStyle(color: _T.txtSecondary, fontSize: 14)),
            const SizedBox(height: 12),
            Text('✓ ${AppStrings.current.unlimitedPresentations}', style: const TextStyle(color: _T.accent, fontSize: 13)),
            Text('✓ ${AppStrings.current.fiftySlides}', style: const TextStyle(color: _T.accent, fontSize: 13)),
            Text('✓ ${AppStrings.current.brandKit}', style: const TextStyle(color: _T.accent, fontSize: 13)),
            Text('✓ ${AppStrings.current.pdfNoWatermark}', style: const TextStyle(color: _T.accent, fontSize: 13)),
            const SizedBox(height: 16),
            Text(AppStrings.current.only499PerMonth, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.current.continueFree, style: const TextStyle(color: _T.txtSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
              _openCryptoPayment(4.99);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppStrings.current.upgradeNow, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLimitDialog() {
    final up = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = up.isLoggedIn;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: _T.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: _T.gold, size: 24),
            const SizedBox(width: 8),
            Text(AppStrings.current.limitReachedTitle, style: const TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          isLoggedIn
              ? AppStrings.current.limitReachedLoggedIn
              : AppStrings.current.limitReachedGuest,
          style: const TextStyle(color: _T.txtSecondary, fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.current.later, style: const TextStyle(color: _T.txtSecondary)),
          ),
          if (!isLoggedIn)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _push(const LoginScreen());
              },
              child: Text(AppStrings.current.logIn, style: const TextStyle(color: _T.accent)),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _openCryptoPayment(4.99);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _T.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(AppStrings.current.payWithUSDT, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();
    
    if (userProvider.isLoggedIn) {
      setState(() {
        _remainingGenerations = userProvider.freeGenerationsLeft;
      });
    } else {
      final count = await _getGuestGenerationCount();
      setState(() {
        _remainingGenerations = 5 - count;
      });
    }
  }
  
  void _refreshUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _remainingGenerations = userProvider.isLoggedIn 
          ? userProvider.freeGenerationsLeft 
          : (5 - (_remainingGenerations > 5 ? 5 : 5 - _remainingGenerations));
    });
    _loadUserData();
  }

  Future<void> _detectCountry() async {
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _countryCode = data['country_code'] ?? 'US';
        });
      }
    } catch (e) {
      _countryCode = 'US';
    }
  }

  Future<void> _loadVipStats() async {
    try {
      if (mounted) {
        setState(() {
          _vipOccupiedSpots = 0;
          _vipTotalSpots = 50;
        });
      }
    } catch (_) {}
  }

  String _formatPrice(double usd) {
    if (usd == 0) return AppStrings.current.free;
    return '\$${usd.toStringAsFixed(2)}';
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  Future<void> _generate({String? overrideTopic}) async {
    final topic = (overrideTopic ?? _topicController.text).trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.current.enterTopic),
        backgroundColor: _T.gold.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ));
      return;
    }

    final canGenerate = await _canGenerate();
    if (!canGenerate) {
      _showLimitDialog();
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (!userProvider.isLoggedIn && !userProvider.isPremium && !userProvider.isVip) {
      final oldCount = await _getGuestGenerationCount();
      await _incrementGuestGenerationCount();
      final newCount = oldCount + 1;
      if (oldCount == 2 && newCount == 3) {
        _showUpgradeOffer();
      }
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
    ).then((_) async {
      await _loadUserData();
      if (userProvider.shouldShowUpgradeOffer) {
        _showUpgradeOffer();
        userProvider.resetUpgradeOfferFlag();
      }
    });
  }

  void _showTextInput() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final canGenerate = await _canGenerate();
    if (!canGenerate) {
      _showLimitDialog();
      return;
    }

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
              Text(AppStrings.current.uploadText, style: const TextStyle(color: _T.txtPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(AppStrings.current.pasteText, style: const TextStyle(color: _T.txtSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                maxLines: 6,
                style: const TextStyle(fontSize: 13, color: _T.txtPrimary),
                decoration: InputDecoration(
                  hintText: AppStrings.current.yourText,
                  hintStyle: const TextStyle(color: _T.txtMuted),
                  filled: true,
                  fillColor: _T.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _T.accent)),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
                    child: Center(child: Text(AppStrings.current.cancel, style: const TextStyle(color: _T.txtSecondary, fontWeight: FontWeight.w600))),
                  ),
                )),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(
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
                    child: Center(child: Text(AppStrings.current.create, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
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
        content: Text(AppStrings.current.logoPremiumOnly),
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
            Text(AppStrings.current.logoUploaded, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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
            Text(AppStrings.current.generationHistory, style: const TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (records.isEmpty)
              Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text(AppStrings.current.noGenerations, style: const TextStyle(color: _T.txtMuted, fontSize: 13))))
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
                      subtitle: Text('${rec.slideCount} ${AppStrings.current.slidesLower}', style: const TextStyle(color: _T.txtMuted, fontSize: 11)),
                      trailing: GestureDetector(
                        onTap: () { 
                          Navigator.pop(ctx); 
                          _generate(overrideTopic: rec.topic); 
                        },
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: Text(AppStrings.current.repeat, style: const TextStyle(color: _T.accent, fontSize: 11, fontWeight: FontWeight.w600))),
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
    
    return GestureDetector(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final logo = Provider.of<BrandKitProvider>(context).logoUrl;
    final left = _remainingGenerations;
    final isLoggedIn = up.isLoggedIn;
    final isPremium = up.isPremium;
    final isVip = up.isVip;
    final canGenerate = left > 0 || isPremium || isVip;

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
            Text(AppStrings.current.appTitle, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.3)),
          ],
        ),
        actions: [
          _buildVipIcon(),
          if (logo != null) _AppBarBtn(Icons.image_rounded, _T.accentLight, () {}, tooltip: AppStrings.current.logoUploaded),
          _AppBarBtn(Icons.history_rounded, _T.txtSecondary, _showHistory, tooltip: AppStrings.current.history),
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
            tooltip: isLoggedIn ? AppStrings.current.profile : AppStrings.current.logIn,
          ),
          _AppBarBtn(Icons.settings_outlined, _T.txtSecondary, () => _push(const SettingsScreen()), tooltip: AppStrings.current.settings),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.current.createPresentation, style: const TextStyle(color: _T.txtPrimary, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                const SizedBox(height: 6),
                Text(AppStrings.current.withAI, style: const TextStyle(color: _T.txtSecondary, fontSize: 14)),
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
                    decoration: InputDecoration(
                      hintText: AppStrings.current.topicHint,
                      hintStyle: const TextStyle(color: _T.txtMuted, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
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
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(AppStrings.current.slidesCount, style: const TextStyle(color: _T.txtMuted, fontSize: 11)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: Text('$_maxSlides', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12))),
                      ]),
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
                  child: GestureDetector(
                    onTap: canGenerate ? _generate : null,
                    child: Container(
                      width: double.infinity, height: 48,
                      decoration: BoxDecoration(
                        gradient: canGenerate 
                            ? const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight])
                            : const LinearGradient(colors: [_T.bgCard, _T.bgCard]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: canGenerate ? [BoxShadow(color: _T.accent.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))] : null,
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.auto_awesome, color: canGenerate ? Colors.white : _T.txtMuted, size: 16),
                        const SizedBox(width: 8),
                        Text(canGenerate ? AppStrings.current.createButton : AppStrings.current.limitReached, style: TextStyle(color: canGenerate ? Colors.white : _T.txtMuted, fontWeight: FontWeight.w800, fontSize: 15)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 6, runSpacing: 6, alignment: WrapAlignment.center,
                  children: _examples.map((example) {
                    final selected = _topicController.text == example;
                    return GestureDetector(
                      onTap: canGenerate ? () => setState(() => _topicController.text = example) : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(color: selected ? _T.accentDim : _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? _T.accent.withOpacity(0.5) : _T.border)),
                        child: Text(example, style: TextStyle(fontSize: 12, color: selected ? _T.accent : canGenerate ? _T.txtSecondary : _T.txtMuted, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _ExtraBtn(Icons.article_outlined, AppStrings.current.fromText, () async { if (await _canGenerate()) _showTextInput(); else _showLimitDialog(); }),
                  const SizedBox(width: 10),
                  _ExtraBtn(Icons.image_outlined, AppStrings.current.uploadLogo, _uploadLogo),
                  const SizedBox(width: 10),
                  _ExtraBtn(Icons.style_rounded, AppStrings.current.templates, () => _push(const TemplateSelectorScreen())),
                ]),

                if (logo != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(logo, width: 40, height: 40, fit: BoxFit.cover)),
                      const SizedBox(width: 12),
                      Text(AppStrings.current.logoUploaded, style: const TextStyle(color: _T.accentLight, fontSize: 12, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      GestureDetector(onTap: () => Provider.of<BrandKitProvider>(context, listen: false).clear(), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 16)),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: left <= 0 && !isPremium && !isVip ? _T.accentDim : _T.bgSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: left <= 0 && !isPremium && !isVip ? _T.accent.withOpacity(0.3) : _T.border),
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(left <= 0 && !isPremium && !isVip ? Icons.warning_amber_rounded : Icons.bolt, color: _T.accent, size: 14),
                      const SizedBox(width: 4),
                      Text(left <= 0 && !isPremium && !isVip ? AppStrings.current.generationsFinished : AppStrings.current.generationsLeft, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
                      if (left > 0 || isPremium || isVip) 
                        Text(isPremium || isVip ? AppStrings.current.unlimited : '$left ${AppStrings.current.ofFive}', style: const TextStyle(color: _T.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                    if (left <= 0 && !isPremium && !isVip) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _openCryptoPayment(4.99),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(AppStrings.current.buyPlanUSDT, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                    if (left > 0 && !isPremium && !isVip) ...[
                      const SizedBox(height: 8),
                      SizedBox(width: 160, height: 4, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: left / 5.0, backgroundColor: _T.border, valueColor: const AlwaysStoppedAnimation<Color>(_T.accent)))),
                    ],
                    if (isPremium || isVip) ...[
                      const SizedBox(height: 4),
                      Text(AppStrings.current.premiumUnlimited, style: const TextStyle(color: _T.accent, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ]),
                ),
                const SizedBox(height: 28),

                Text(AppStrings.current.choosePlan, style: const TextStyle(color: _T.txtPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(AppStrings.current.pricesInUSD, style: const TextStyle(color: _T.txtSecondary, fontSize: 12)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _TariffCard(
                    title: AppStrings.current.free, 
                    usd: 0, 
                    formatPrice: _formatPrice, 
                    period: '', 
                    features: [
                      '5 ${AppStrings.current.generationsPerMonth}',
                      '10 ${AppStrings.current.slidesLower}',
                      '8 ${AppStrings.current.backgroundsLower}',
                      AppStrings.current.basicExport
                    ], 
                    popular: false, 
                    onTap: () {})),
                  const SizedBox(width: 12),
                  Expanded(child: _TariffCard(
                    title: AppStrings.current.month, 
                    usd: 4.99, 
                    formatPrice: _formatPrice, 
                    period: '/${AppStrings.current.monthLower}', 
                    features: [
                      AppStrings.current.unlimited,
                      '50 ${AppStrings.current.slidesLower}',
                      '16 ${AppStrings.current.backgroundsLower}',
                      AppStrings.current.pdfNoWatermark,
                      AppStrings.current.aiImprove,
                      AppStrings.current.payWithUSDTShort
                    ], 
                    popular: true, 
                    onTap: () => _openCryptoPayment(4.99))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _TariffCard(
                    title: AppStrings.current.halfYear, 
                    usd: 29.99, 
                    formatPrice: _formatPrice, 
                    period: '\$5.00/${AppStrings.current.monthLower}', 
                    features: [
                      AppStrings.current.allFromMonth,
                      AppStrings.current.save17,
                      AppStrings.current.prioritySupport,
                      AppStrings.current.payWithUSDTShort
                    ], 
                    popular: false, 
                    onTap: () => _openCryptoPayment(29.99))),
                  const SizedBox(width: 12),
                  Expanded(child: _TariffCard(
                    title: AppStrings.current.year, 
                    usd: 49.99, 
                    formatPrice: _formatPrice, 
                    period: '\$4.17/${AppStrings.current.monthLower}', 
                    features: [
                      AppStrings.current.allFromHalfYear,
                      AppStrings.current.save33,
                      AppStrings.current.brandKit,
                      AppStrings.current.payWithUSDTShort
                    ], 
                    popular: false, 
                    badge: AppStrings.current.bestValue.toUpperCase(), 
                    onTap: () => _openCryptoPayment(49.99))),
                ]),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _T.border)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(Icons.school_outlined, AppStrings.current.forTeachers, () => _push(TeacherScreen(countryCode: _countryCode))),
                      _NavItem(Icons.business_center_outlined, AppStrings.current.forBusiness, () => _push(CorporateScreen(countryCode: _countryCode))),
                      _NavItem(Icons.group_outlined, AppStrings.current.team, () => _push(WorkspaceScreen(countryCode: _countryCode))),
                      _NavItem(Icons.quiz_outlined, AppStrings.current.tests, () => _push(const QuizScreen())),
                      _NavItem(Icons.card_giftcard_outlined, AppStrings.current.friends, () => _push(const ReferralScreen())),
                      _NavItem(Icons.person_outline, AppStrings.current.profile, () => _push(const ProfileScreen())),
                    ],
                  ),
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
    return GestureDetector(
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
                child: Text(badge ?? (popular ? AppStrings.current.popular.toUpperCase() : ''), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SMALL WIDGETS (без изменений, только тексты через AppStrings)
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Tooltip(
      message: widget.tooltip,
      child: Container(
        width: 34, height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: _hovered ? _T.bgHover : Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(10)),
        child: Icon(widget.icon, color: widget.color, size: 17),
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _T.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: _T.txtSecondary), const SizedBox(width: 7), Text(label, style: const TextStyle(fontSize: 12, color: _T.txtSecondary, fontWeight: FontWeight.w500))]),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 20, color: _T.txtSecondary), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 9, color: _T.txtSecondary, fontWeight: FontWeight.w500))]),
    ),
  );
}