import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

// ─── Модель одной записи истории ─────────────────────────────────────────────
class GenerationRecord {
  final String topic;
  final int slideCount;
  final DateTime createdAt;

  const GenerationRecord({
    required this.topic,
    required this.slideCount,
    required this.createdAt,
  });
}

// ─── ChangeNotifier для истории генераций ────────────────────────────────────
// Зарегистрируйте его в MultiProvider на уровне MaterialApp:
//   ChangeNotifierProvider(create: (_) => HistoryProvider()),
class HistoryProvider extends ChangeNotifier {
  final List<GenerationRecord> _records = [];

  List<GenerationRecord> get records => List.unmodifiable(_records);

  void add(String topic, {int slideCount = 5}) {
    _records.insert(
      0,
      GenerationRecord(
        topic: topic,
        slideCount: slideCount,
        createdAt: DateTime.now(),
      ),
    );
    if (_records.length > 20) _records.removeLast();
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _topicController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  int _maxSlides = 5;
  bool _isFocused = false;

  final List<String> _examples = ['ИИ', 'Бизнес', 'Экология', 'Космос', 'IT'];

  // FIX: безопасный substring — не падает если строка короче max
  static String _safeSubstring(String s, int max) =>
      s.substring(0, s.length.clamp(0, max));

  // FIX: countryCode из локали устройства вместо хардкода 'RU'
  String get _countryCode =>
      PlatformDispatcher.instance.locale.countryCode ?? 'RU';

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
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ─── Навигация ────────────────────────────────────────────────
  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _showPremium()   => _push(const PremiumScreen());
  void _showSettings()  => _push(const SettingsScreen());
  void _showProfile()   => _push(const ProfileScreen());
  void _showWorkspace() => _push(const WorkspaceScreen());
  void _showTeacher()   => _push(TeacherScreen(countryCode: _countryCode));
  void _showCorporate() => _push(CorporateScreen(countryCode: _countryCode));
  void _showReferral()  => _push(const ReferralScreen());
  void _showVip()       => _push(const VipScreen());
  void _showLogin()     => _push(const LoginScreen());
  void _showQuiz()      => _push(const QuizScreen());

  // ─── Генерация ────────────────────────────────────────────────
  Future<void> _generate({String? overrideTopic}) async {
    final topic = (overrideTopic ?? _topicController.text).trim();
    if (topic.isEmpty) return;

    final up = Provider.of<UserProvider>(context, listen: false);

    if (!up.canGenerate) {
      _showPremium();
      return;
    }

    // Сохраняем в историю
    Provider.of<HistoryProvider>(context, listen: false)
        .add(topic, slideCount: _maxSlides);

    _push(LoadingScreen(topic: topic));
  }

  // ─── Диалог: из текста ────────────────────────────────────────
  void _showTextInput() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Загрузите текст',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          content: TextField(
            controller: ctrl,
            maxLines: 6,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Введите текст диплома, статьи...',
              hintStyle:
                  TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: const Color(0xFF282828),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(color: Color(0xFFB3B3B3))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  // FIX: _safeSubstring вместо text.substring(0, 50)
                  _generate(overrideTopic: _safeSubstring(text, 50));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954)),
              child: const Text('Создать',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // ─── Диалог: загрузка логотипа ────────────────────────────────
  void _showLogoUpload() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Загрузите логотип',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: const Text(
          'Выберите файл логотипа (PNG, JPG)\n\nБренд-кит будет создан автоматически.',
          style: TextStyle(color: Color(0xFFB3B3B3), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: Color(0xFFB3B3B3))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Бренд-кит создан!'),
                backgroundColor: Color(0xFF1DB954),
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DB954)),
            child: const Text('Загрузить',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ─── История генераций (bottom sheet) ─────────────────────────
  void _showHistory() {
    final records =
        Provider.of<HistoryProvider>(context, listen: false).records;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.history,
                      color: Color(0xFF1DB954), size: 18),
                  SizedBox(width: 8.w),
                  const Text('История',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 12.h),
              if (records.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'Пока нет генераций',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 13),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 320.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: records.length,
                    separatorBuilder: (_, __) => Divider(
                        color: Colors.white.withOpacity(0.06),
                        height: 1),
                    itemBuilder: (_, i) {
                      final r = records[i];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        leading: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954)
                                .withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Icon(
                              Icons.slideshow_outlined,
                              color: Color(0xFF1DB954),
                              size: 18),
                        ),
                        title: Text(
                          r.topic,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${r.slideCount} слайдов • ${_formatTime(r.createdAt)}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _generate(overrideTopic: r.topic);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DB954)
                                  .withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Text('Повторить',
                                style: TextStyle(
                                    color: Color(0xFF1DB954),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 8.h),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин назад';
    if (diff.inDays < 1) return '${diff.inHours} ч назад';
    return '${diff.inDays} д назад';
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final up = Provider.of<UserProvider>(context);
    final left = up.freeGenerationsLeft;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16.h),
              _buildVipBanner(),
              SizedBox(height: 32.h),
              _buildHero(),
              SizedBox(height: 28.h),
              _buildInputSection(),
              SizedBox(height: 16.h),
              _buildExampleChips(),
              SizedBox(height: 16.h),
              _buildExtraActions(),
              SizedBox(height: 20.h),
              _buildCounter(left),
              SizedBox(height: 28.h),
              _buildBottomNav(),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF121212),
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.black, size: 16),
          ),
          SizedBox(width: 8.w),
          const Text(
            'Презентатор ИИ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        _appBarBtn(
            Icons.diamond, const Color(0xFFFFD60A), _showVip),
        _appBarBtn(
            Icons.history, const Color(0xFFB3B3B3), _showHistory),
        _appBarBtn(Icons.person_outline,
            const Color(0xFFB3B3B3), _showLogin),
        _appBarBtn(Icons.settings_outlined,
            const Color(0xFFB3B3B3), _showSettings),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _appBarBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VIP Banner
  // ─────────────────────────────────────────────────────────────
  Widget _buildVipBanner() {
    return GestureDetector(
      onTap: _showVip,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD60A).withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: const Color(0xFFFFD60A).withOpacity(0.35),
              width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium,
                color: Color(0xFFFFD60A), size: 15),
            SizedBox(width: 6.w),
            const Text(
              'Первые 50 — Premium навсегда!',
              style: TextStyle(
                  color: Color(0xFFFFD60A),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Hero
  // ─────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      children: [
        Text(
          'Создай презентацию',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'с помощью ИИ за 1 минуту',
          style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFB3B3B3),
              letterSpacing: 0.1),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Input + Slider + Button
  // ─────────────────────────────────────────────────────────────
  Widget _buildInputSection() {
    return SizedBox(
      width: 300.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Поле ввода
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused
                    ? const Color(0xFF1DB954).withOpacity(0.6)
                    : Colors.white.withOpacity(0.08),
                width: _isFocused ? 1.5 : 1,
              ),
            ),
            child: TextField(
              controller: _topicController,
              focusNode: _focusNode,
              style:
                  const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'О чём презентация?',
                hintStyle: TextStyle(
                    color:
                        const Color(0xFFB3B3B3).withOpacity(0.5),
                    fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 14.h),
                prefixIcon: Icon(
                  Icons.search,
                  color: _isFocused
                      ? const Color(0xFF1DB954).withOpacity(0.7)
                      : const Color(0xFFB3B3B3).withOpacity(0.3),
                  size: 18,
                ),
              ),
              onSubmitted: (_) => _generate(),
            ),
          ),
          SizedBox(height: 12.h),

          // Слайдер количества слайдов
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.06), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Количество слайдов',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_maxSlides',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1DB954)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF1DB954),
                    inactiveTrackColor:
                        Colors.white.withOpacity(0.08),
                    thumbColor: const Color(0xFF1DB954),
                    overlayColor:
                        const Color(0xFF1DB954).withOpacity(0.12),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    value: _maxSlides.toDouble(),
                    min: 3,
                    max: 10,
                    divisions: 7,
                    onChanged: (v) =>
                        setState(() => _maxSlides = v.round()),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('3',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.3))),
                    Text('10',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.3))),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Кнопка «Создать»
          ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: _generate,
              child: Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DB954).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.black, size: 16),
                    SizedBox(width: 8.w),
                    const Text(
                      'Создать',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Example chips
  // ─────────────────────────────────────────────────────────────
  Widget _buildExampleChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: _examples.map((e) {
        final selected = _topicController.text == e;
        return GestureDetector(
          onTap: () => setState(() => _topicController.text = e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
                horizontal: 14.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF1DB954).withOpacity(0.15)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1DB954).withOpacity(0.5)
                    : Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
            child: Text(
              e,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? const Color(0xFF1DB954)
                    : const Color(0xFFB3B3B3),
                fontWeight: selected
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Extra actions
  // ─────────────────────────────────────────────────────────────
  Widget _buildExtraActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _extraBtn(
            Icons.article_outlined, 'Из текста', _showTextInput),
        SizedBox(width: 10.w),
        _extraBtn(
            Icons.image_outlined, 'Из логотипа', _showLogoUpload),
      ],
    );
  }

  Widget _extraBtn(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 18.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.06), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFB3B3B3)),
            SizedBox(width: 7.w),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB3B3B3),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Generation counter
  // ─────────────────────────────────────────────────────────────
  Widget _buildCounter(int left) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt,
                  color: Color(0xFF1DB954), size: 14),
              SizedBox(width: 4.w),
              const Text('Осталось генераций: ',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFB3B3B3))),
              Text(
                '$left из 5',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1DB954)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 160.w,
            height: 4.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: left / 5.0,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF1DB954)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom navigation
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = [
      {
        'icon': Icons.school_outlined,
        'label': 'Учителям',
        'fn': _showTeacher
      },
      {
        'icon': Icons.business_center_outlined,
        'label': 'Бизнесу',
        'fn': _showCorporate
      },
      {
        'icon': Icons.group_outlined,
        'label': 'Команда',
        'fn': _showWorkspace
      },
      {
        'icon': Icons.quiz_outlined,
        'label': 'Тесты',
        'fn': _showQuiz
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'label': 'Друзья',
        'fn': _showReferral
      },
      {
        'icon': Icons.person_outline,
        'label': 'Профиль',
        'fn': _showProfile
      },
    ];

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withOpacity(0.06), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navItems
            .map((item) => _navItem(
                  item['icon'] as IconData,
                  item['label'] as String,
                  item['fn'] as VoidCallback,
                ))
            .toList(),
      ),
    );
  }

  Widget _navItem(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFFB3B3B3)),
            SizedBox(height: 4.h),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFB3B3B3),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}