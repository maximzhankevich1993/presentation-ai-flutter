import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/image_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
class _T {
  // Backgrounds — оригинальная тёмная тема #121212
  static const bgBase    = Color(0xFF121212);   // root canvas
  static const bgSurface = Color(0xFF1A1A1A);   // panels
  static const bgCard    = Color(0xFF1E1E1E);   // cards, inputs
  static const bgHover   = Color(0xFF252525);   // hover state

  // Borders
  static const border      = Color(0xFF2A2A2A);
  static const borderFocus = Color(0xFF3A3A3A);

  // Text
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);

  // Accent — оригинальный Spotify Green #1DB954
  static const accent      = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim   = Color(0xFF1DB95420);

  // Semantic
  static const danger  = Color(0xFFFF3B30);
  static const success = Color(0xFF1DB954);
  static const gold    = Color(0xFFFFD700);

  // Radii
  static const r4  = BorderRadius.all(Radius.circular(4));
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));

  // Transitions
  static const fast   = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow   = Duration(milliseconds: 320);
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  late Presentation _presentation;
  late List<TextEditingController> _titleCtrl;
  late List<List<TextEditingController>> _contentCtrl;
  late List<String?> _customImages;
  late List<String?> _customBgs;
  late List<double> _fontSizes;
  late List<String> _fonts;

  int _activeSlide = 0;
  int _selectedBgIndex = 0;
  String _globalFont = 'Inter';
  bool _navCollapsed = false;
  bool _propsPanelOpen = true;
  String _activePropTab = 'design';   // design | content | ai
  bool _isImproving = false;
  int _imageUploadsUsed = 0;

  final Map<int, String?> _autoImages = {};
  final _scrollCtrl = ScrollController();
  final _canvasKey = GlobalKey();

  // ── Slide backgrounds ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _backgrounds = [
    {'type': 'solid',    'color': Colors.white,                                                  'label': 'Чистый'},
    {'type': 'gradient', 'colors': [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],    'label': 'Cosmos'},
    {'type': 'gradient', 'colors': [Color(0xFF1a1a2e), Color(0xFF16213e)],                       'label': 'Midnight'},
    {'type': 'gradient', 'colors': [Color(0xFF7C5CFC), Color(0xFF3B82F6)],                       'label': 'Aurora'},
    {'type': 'gradient', 'colors': [Color(0xFFf093fb), Color(0xFFf5576c)],                       'label': 'Розовый'},
    {'type': 'gradient', 'colors': [Color(0xFF4facfe), Color(0xFF00f2fe)],                       'label': 'Голубой'},
    {'type': 'solid',    'color': Color(0xFF0F0F0F),                                             'label': 'Чёрный'},
    {'type': 'solid',    'color': Color(0xFFFFF8E7),                                             'label': 'Кремовый'},
    {'type': 'gradient', 'colors': [Color(0xFF11998e), Color(0xFF38ef7d)],                       'label': 'Mint'},
    {'type': 'gradient', 'colors': [Color(0xFFFF416C), Color(0xFFFF4B2B)],                       'label': 'Закат'},
    {'type': 'gradient', 'colors': [Color(0xFF434343), Color(0xFF000000)],                       'label': 'Уголь'},
    {'type': 'gradient', 'colors': [Color(0xFFFFE000), Color(0xFF799F0C)],                       'label': 'Лимон'},
  ];

  final List<Map<String, dynamic>> _premiumBgs = [
    {'type': 'gradient', 'colors': [Color(0xFF1DB954), Color(0xFF191414)], 'label': 'Spotify'},
    {'type': 'gradient', 'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)], 'label': 'Неон'},
    {'type': 'solid',    'color':  Color(0xFF1A1A2E),                      'label': 'Navy'},
    {'type': 'gradient', 'colors': [Color(0xFF00b4db), Color(0xFF0083B0)], 'label': 'Океан'},
  ];

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _customImages = List.filled(_presentation.slides.length, null);
    _customBgs    = List.filled(_presentation.slides.length, null);
    _fontSizes    = List.filled(_presentation.slides.length, 9.0);
    _fonts        = List.filled(_presentation.slides.length, 'Inter');
    _initControllers();
    _loadAutoImages();
    _countUploads();
  }

  void _initControllers() {
    _titleCtrl   = _presentation.slides.map((s) => TextEditingController(text: s.title)).toList();
    _contentCtrl = _presentation.slides.map((s) => s.content.map((c) => TextEditingController(text: c)).toList()).toList();
  }

  void _countUploads() =>
      _imageUploadsUsed = _customImages.where((i) => i != null).length;

  Future<void> _loadAutoImages() async {
    for (int i = 0; i < _presentation.slides.length; i++) {
      final q = _titleCtrl[i].text.isNotEmpty ? _titleCtrl[i].text : _presentation.title;
      _autoImages[i] = await ImageService.searchImage(q);
      if (mounted) setState(() {});
    }
  }

  // ── Slide CRUD ─────────────────────────────────────────────────────────────
  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title   = _titleCtrl[i].text;
      _presentation.slides[i].content = _contentCtrl[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      _toast('Максимум ${up.maxSlidesPerPresentation} слайдов');
      return;
    }
    setState(() {
      final idx = _activeSlide + 1;
      _presentation.slides.insert(idx, Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleCtrl.insert(idx, TextEditingController(text: 'Новый слайд'));
      _contentCtrl.insert(idx, [TextEditingController(text: 'Введите текст')]);
      _customImages.insert(idx, null);
      _customBgs.insert(idx, null);
      _fontSizes.insert(idx, 9.0);
      _fonts.insert(idx, _globalFont);
      _activeSlide = idx;
    });
  }

  void _deleteSlide(int i) {
    if (_presentation.slides.length <= 1) return;
    setState(() {
      _titleCtrl[i].dispose();
      for (var c in _contentCtrl[i]) c.dispose();
      _presentation.slides.removeAt(i);
      _titleCtrl.removeAt(i);
      _contentCtrl.removeAt(i);
      _customImages.removeAt(i);
      _customBgs.removeAt(i);
      _fontSizes.removeAt(i);
      _fonts.removeAt(i);
      _autoImages.remove(i);
      if (_activeSlide >= _presentation.slides.length) {
        _activeSlide = _presentation.slides.length - 1;
      }
    });
    _countUploads();
  }

  void _duplicateSlide(int i) {
    setState(() {
      final idx = i + 1;
      _presentation.slides.insert(idx, Slide(
        title: _presentation.slides[i].title,
        content: List.from(_presentation.slides[i].content),
      ));
      _titleCtrl.insert(idx, TextEditingController(text: _titleCtrl[i].text));
      _contentCtrl.insert(idx, _contentCtrl[i].map((c) => TextEditingController(text: c.text)).toList());
      _customImages.insert(idx, _customImages[i]);
      _customBgs.insert(idx, _customBgs[i]);
      _fontSizes.insert(idx, _fontSizes[i]);
      _fonts.insert(idx, _fonts[i]);
      _activeSlide = idx;
    });
    _countUploads();
  }

  void _moveSlide(int from, int to) {
    if (to < 0 || to >= _presentation.slides.length) return;
    setState(() {
      void swap<T>(List<T> list) {
        final tmp = list[from]; list[from] = list[to]; list[to] = tmp;
      }
      swap(_presentation.slides);
      swap(_titleCtrl);
      swap(_contentCtrl);
      swap(_customImages);
      swap(_customBgs);
      swap(_fontSizes);
      swap(_fonts);
      _activeSlide = to;
    });
  }

  void _addContentItem(int i) =>
      setState(() => _contentCtrl[i].add(TextEditingController(text: 'Новый пункт')));

  void _removeContentItem(int slide, int item) {
    if (_contentCtrl[slide].length <= 1) return;
    setState(() {
      _contentCtrl[slide][item].dispose();
      _contentCtrl[slide].removeAt(item);
    });
  }

  // ── AI ─────────────────────────────────────────────────────────────────────
  Future<void> _improveSlide(int index) async {
    setState(() => _isImproving = true);
    try {
      final t = await AiImproveService.improveText(_titleCtrl[index].text);
      final cs = <String>[];
      for (final c in _contentCtrl[index]) cs.add(await AiImproveService.improveText(c.text));
      if (!mounted) return;
      setState(() {
        _titleCtrl[index].text = t;
        for (int i = 0; i < cs.length && i < _contentCtrl[index].length; i++) {
          _contentCtrl[index][i].text = cs[i];
        }
      });
      _toast('Текст улучшен', success: true);
    } catch (e) {
      _toast('Ошибка: $e', error: true);
    } finally {
      if (mounted) setState(() => _isImproving = false);
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────
  Future<void> _uploadImage(int index) async {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    if (!p && _imageUploadsUsed >= 10 && _customImages[index] == null) {
      _toast('10 бесплатных загрузок исчерпано', warning: true);
      return;
    }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() {
        _customImages[index] = reader.result as String;
        if (!p) _imageUploadsUsed++;
      }));
    });
  }

  Future<void> _uploadBg(int index) async {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    final used = _customBgs.where((b) => b != null).length;
    if (!p && used >= 10 && _customBgs[index] == null) {
      _toast('10 фонов бесплатно', warning: true);
      return;
    }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() => _customBgs[index] = reader.result as String));
    });
  }

  // ── Decoration helpers ─────────────────────────────────────────────────────
  Decoration _slideDeco(int index) {
    if (_customBgs[index] != null) {
      return BoxDecoration(
        image: DecorationImage(image: NetworkImage(_customBgs[index]!), fit: BoxFit.cover),
        borderRadius: _T.r12,
      );
    }
    final bg = _backgrounds[_selectedBgIndex];
    if (bg['type'] == 'gradient') {
      final colors = bg['colors'] as List<Color>;
      return BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: _T.r12,
      );
    }
    return BoxDecoration(color: bg['color'] as Color, borderRadius: _T.r12);
  }

  bool _isDark(int index) {
    if (_customBgs[index] != null) return true;
    final bg = _backgrounds[_selectedBgIndex];
    if (bg['type'] == 'solid') return (bg['color'] as Color).computeLuminance() < 0.5;
    return true;
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  void _toast(String msg, {bool success = false, bool error = false, bool warning = false}) {
    Color bg = _T.bgCard;
    if (success) bg = _T.success.withOpacity(0.9);
    if (error)   bg = _T.danger.withOpacity(0.9);
    if (warning) bg = _T.gold.withOpacity(0.9);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Export ─────────────────────────────────────────────────────────────────
  void _export() {
    _saveAll();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    _showSheet(_ExportSheet(isPremium: isPremium, presentation: _presentation));
  }

  void _showSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => child,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bgBase,
      body: Column(children: [
        _TopBar(
          title: _presentation.title,
          slideCount: _presentation.slides.length,
          uploadsUsed: _imageUploadsUsed,
          onBack: () { _saveAll(); Navigator.pop(context); },
          onExport: _export,
        ),
        const Divider(color: _T.border, height: 1),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── LEFT: Slide Navigator ────────────────────────────────────────
            AnimatedContainer(
              duration: _T.normal,
              width: _navCollapsed ? 48 : 200,
              child: _SlideNavigator(
                slides: _presentation.slides,
                titleControllers: _titleCtrl,
                activeIndex: _activeSlide,
                collapsed: _navCollapsed,
                customBgs: _customBgs,
                backgrounds: _backgrounds,
                selectedBgIndex: _selectedBgIndex,
                onSelect: (i) => setState(() => _activeSlide = i),
                onAdd: _addSlide,
                onDelete: _deleteSlide,
                onDuplicate: _duplicateSlide,
                onMoveUp: (i) => _moveSlide(i, i - 1),
                onMoveDown: (i) => _moveSlide(i, i + 1),
                onToggleCollapse: () => setState(() => _navCollapsed = !_navCollapsed),
              ),
            ),
            const VerticalDivider(color: _T.border, width: 1),

            // ── CENTER: Canvas ───────────────────────────────────────────────
            Expanded(
              child: _Canvas(
                key: _canvasKey,
                index: _activeSlide,
                titleCtrl: _titleCtrl[_activeSlide],
                contentCtrl: _contentCtrl[_activeSlide],
                decoration: _slideDeco(_activeSlide),
                isDark: _isDark(_activeSlide),
                image: _customImages[_activeSlide] ?? _autoImages[_activeSlide],
                font: _fonts[_activeSlide] != 'Inter' ? _fonts[_activeSlide] : _globalFont,
                fontSize: _fontSizes[_activeSlide],
                slideCount: _presentation.slides.length,
                onAddItem: () => _addContentItem(_activeSlide),
                onRemoveItem: (i) => _removeContentItem(_activeSlide, i),
                onRemoveImage: () => setState(() { _customImages[_activeSlide] = null; _countUploads(); }),
                hasCustomImage: _customImages[_activeSlide] != null,
              ),
            ),
            const VerticalDivider(color: _T.border, width: 1),

            // ── RIGHT: Properties Panel ──────────────────────────────────────
            AnimatedContainer(
              duration: _T.normal,
              width: _propsPanelOpen ? 260 : 0,
              child: _propsPanelOpen
                  ? _PropertiesPanel(
                      index: _activeSlide,
                      isPremium: Provider.of<UserProvider>(context, listen: false).isPremium,
                      activeTab: _activePropTab,
                      globalFont: _globalFont,
                      selectedBgIndex: _selectedBgIndex,
                      backgrounds: _backgrounds,
                      premiumBgs: _premiumBgs,
                      customBg: _customBgs[_activeSlide],
                      fontSize: _fontSizes[_activeSlide],
                      isImproving: _isImproving,
                      onTabChange: (t) => setState(() => _activePropTab = t),
                      onBgSelect: (i) => setState(() {
                        _selectedBgIndex = i;
                        _customBgs = List.filled(_presentation.slides.length, null);
                      }),
                      onBgUpload: () => _uploadBg(_activeSlide),
                      onImageUpload: () => _uploadImage(_activeSlide),
                      onFontChange: (f) => setState(() {
                        _globalFont = f;
                        for (int i = 0; i < _fonts.length; i++) _fonts[i] = f;
                      }),
                      onFontSizeChange: (v) => setState(() => _fontSizes[_activeSlide] = v),
                      onImprove: () => _improveSlide(_activeSlide),
                      uploadsUsed: _imageUploadsUsed,
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
        ),

        // ── BOTTOM: Control Bar ──────────────────────────────────────────────
        const Divider(color: _T.border, height: 1),
        _ControlBar(
          activeSlide: _activeSlide,
          totalSlides: _presentation.slides.length,
          propsPanelOpen: _propsPanelOpen,
          onToggleProps: () => setState(() => _propsPanelOpen = !_propsPanelOpen),
          onPrev: () => setState(() { if (_activeSlide > 0) _activeSlide--; }),
          onNext: () => setState(() { if (_activeSlide < _presentation.slides.length - 1) _activeSlide++; }),
          onAdd: _addSlide,
          onDelete: () => _deleteSlide(_activeSlide),
          onDuplicate: () => _duplicateSlide(_activeSlide),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (var c in _titleCtrl) c.dispose();
    for (var l in _contentCtrl) for (var c in l) c.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String title;
  final int slideCount;
  final int uploadsUsed;
  final VoidCallback onBack;
  final VoidCallback onExport;

  const _TopBar({
    required this.title,
    required this.slideCount,
    required this.uploadsUsed,
    required this.onBack,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: _T.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        // Back
        _IconBtn(Icons.arrow_back_ios_rounded, onBack, tooltip: 'Назад', size: 17),
        const SizedBox(width: 8),

        // Logo mark
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),

        // Title
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              Text('$slideCount слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 10)),
            ],
          ),
        ),

        // Upload counter
        if (uploadsUsed > 0)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.12) : _T.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.3) : _T.accent.withOpacity(0.3)),
            ),
            child: Text('🖼 $uploadsUsed/10',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: uploadsUsed >= 10 ? _T.gold : _T.accentLight,
              ),
            ),
          ),

        // Export CTA
        GestureDetector(
          onTap: onExport,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: _T.accent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.ios_share_rounded, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text('Экспорт', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE NAVIGATOR (Left Panel)
// ═══════════════════════════════════════════════════════════════════════════════
class _SlideNavigator extends StatelessWidget {
  final List<Slide> slides;
  final List<TextEditingController> titleControllers;
  final int activeIndex;
  final bool collapsed;
  final List<String?> customBgs;
  final List<Map<String, dynamic>> backgrounds;
  final int selectedBgIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete;
  final ValueChanged<int> onDuplicate;
  final ValueChanged<int> onMoveUp;
  final ValueChanged<int> onMoveDown;
  final VoidCallback onToggleCollapse;

  const _SlideNavigator({
    required this.slides,
    required this.titleControllers,
    required this.activeIndex,
    required this.collapsed,
    required this.customBgs,
    required this.backgrounds,
    required this.selectedBgIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
    required this.onDuplicate,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
        // Header
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            if (!collapsed) ...[
              const Text('СЛАЙДЫ',
                style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              const Spacer(),
            ],
            _IconBtn(
              collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              onToggleCollapse,
              size: 16,
            ),
          ]),
        ),
        const Divider(color: _T.border, height: 1),

        // Slide list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            itemCount: slides.length,
            itemBuilder: (_, i) => _SlideThumbnail(
              index: i,
              title: titleControllers[i].text,
              isActive: i == activeIndex,
              collapsed: collapsed,
              bgColor: _getThumbnailColor(i),
              onTap: () => onSelect(i),
              onDelete: slides.length > 1 ? () => onDelete(i) : null,
              onDuplicate: () => onDuplicate(i),
              onMoveUp: i > 0 ? () => onMoveUp(i) : null,
              onMoveDown: i < slides.length - 1 ? () => onMoveDown(i) : null,
            ),
          ),
        ),
        const Divider(color: _T.border, height: 1),

        // Add slide
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _T.accentDim,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _T.accent.withOpacity(0.4)),
                ),
                child: const Icon(Icons.add_rounded, color: _T.accent, size: 14),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 8),
                const Text('Слайд', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  Color _getThumbnailColor(int i) {
    if (customBgs[i] != null) return Colors.grey.shade800;
    final bg = backgrounds[selectedBgIndex];
    if (bg['type'] == 'solid') return bg['color'] as Color;
    return (bg['colors'] as List<Color>).first;
  }
}

class _SlideThumbnail extends StatefulWidget {
  final int index;
  final String title;
  final bool isActive;
  final bool collapsed;
  final Color bgColor;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _SlideThumbnail({
    required this.index,
    required this.title,
    required this.isActive,
    required this.collapsed,
    required this.bgColor,
    required this.onTap,
    this.onDelete,
    required this.onDuplicate,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<_SlideThumbnail> createState() => _SlideThumbnailState();
}

class _SlideThumbnailState extends State<_SlideThumbnail> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _T.fast,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.isActive ? _T.accent.withOpacity(0.12) : _hovered ? _T.bgHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive ? _T.accent.withOpacity(0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: widget.collapsed
              ? _collapsedView()
              : _expandedView(),
        ),
      ),
    );
  }

  Widget _collapsedView() => Column(children: [
    Container(
      width: 30, height: 20,
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(3)),
      child: Center(
        child: Text('${widget.index + 1}',
          style: TextStyle(fontSize: 8, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.w700)),
      ),
    ),
  ]);

  Widget _expandedView() => Row(children: [
    // Mini preview
    Container(
      width: 52, height: 34,
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text('${widget.index + 1}',
          style: TextStyle(fontSize: 10, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white38, fontWeight: FontWeight.w700)),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        widget.title.isEmpty ? 'Слайд ${widget.index + 1}' : widget.title,
        style: TextStyle(
          color: widget.isActive ? _T.txtPrimary : _T.txtSecondary,
          fontSize: 11, fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
    // Context menu on hover
    if (_hovered)
      PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 14,
        color: _T.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _T.border)),
        icon: const Icon(Icons.more_vert_rounded, color: _T.txtSecondary, size: 14),
        onSelected: (v) {
          if (v == 'dup') widget.onDuplicate();
          if (v == 'del') widget.onDelete?.call();
          if (v == 'up') widget.onMoveUp?.call();
          if (v == 'down') widget.onMoveDown?.call();
        },
        itemBuilder: (_) => [
          if (widget.onMoveUp != null)
            const PopupMenuItem(value: 'up', height: 36, child: _MenuItem(Icons.arrow_upward_rounded, 'Вверх')),
          if (widget.onMoveDown != null)
            const PopupMenuItem(value: 'down', height: 36, child: _MenuItem(Icons.arrow_downward_rounded, 'Вниз')),
          const PopupMenuItem(value: 'dup', height: 36, child: _MenuItem(Icons.copy_rounded, 'Дублировать')),
          if (widget.onDelete != null)
            const PopupMenuItem(value: 'del', height: 36, child: _MenuItem(Icons.delete_outline_rounded, 'Удалить', danger: true)),
        ],
      ),
  ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuItem(this.icon, this.label, {this.danger = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: danger ? _T.danger : _T.txtSecondary),
    const SizedBox(width: 8),
    Text(label, style: TextStyle(color: danger ? _T.danger : _T.txtPrimary, fontSize: 12)),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CANVAS (Center)
// ═══════════════════════════════════════════════════════════════════════════════
class _Canvas extends StatelessWidget {
  final int index;
  final TextEditingController titleCtrl;
  final List<TextEditingController> contentCtrl;
  final Decoration decoration;
  final bool isDark;
  final String? image;
  final String font;
  final double fontSize;
  final int slideCount;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onRemoveImage;
  final bool hasCustomImage;

  const _Canvas({
    super.key,
    required this.index,
    required this.titleCtrl,
    required this.contentCtrl,
    required this.decoration,
    required this.isDark,
    required this.image,
    required this.font,
    required this.fontSize,
    required this.slideCount,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onRemoveImage,
    required this.hasCustomImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgBase,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(children: [
            // Slide counter
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('${index + 1} / $slideCount',
                style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500)),
            ),

            // Slide preview (16:9)
            LayoutBuilder(builder: (ctx, constraints) {
              final width = (MediaQuery.of(context).size.width - 460).clamp(360.0, 900.0);
              final height = width * 9 / 16;
              return Container(
                width: width,
                height: height,
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  // Slide number badge
                  Positioned(
                    top: 12, left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)),
                      child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  // Content area
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          // Title (editable)
                          EditableText(
                            controller: titleCtrl,
                            focusNode: FocusNode(),
                            style: TextStyle(
                              fontSize: fontSize * 2.2,
                              fontWeight: FontWeight.w800,
                              fontFamily: font,
                              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                            cursorColor: _T.accent,
                            backgroundCursorColor: _T.accent,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),

                          // Bullet points
                          ...contentCtrl.take(5).mapIndexed((i, c) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(
                                padding: EdgeInsets.only(top: fontSize * 0.38, right: 7),
                                child: Container(
                                  width: 5, height: 5,
                                  decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle),
                                ),
                              ),
                              Expanded(
                                child: EditableText(
                                  controller: c,
                                  focusNode: FocusNode(),
                                  style: TextStyle(
                                    fontSize: fontSize * 1.4,
                                    fontFamily: font,
                                    color: isDark ? Colors.white70 : const Color(0xFF444444),
                                    height: 1.4,
                                  ),
                                  cursorColor: _T.accent,
                                  backgroundCursorColor: _T.accent,
                                  maxLines: 3,
                                ),
                              ),
                            ]),
                          )),
                        ]),
                      ),

                      // Image
                      if (image != null) ...[
                        const SizedBox(width: 20),
                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              image!,
                              width: width * 0.28,
                              height: height * 0.55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                          if (hasCustomImage)
                            Positioned(
                              top: 4, right: 4,
                              child: GestureDetector(
                                onTap: onRemoveImage,
                                child: Container(
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                        ]),
                      ],
                    ]),
                  ),
                ]),
              );
            }),

            const SizedBox(height: 16),

            // Quick content editor below canvas
            LayoutBuilder(builder: (ctx, _) {
              final width = (MediaQuery.of(context).size.width - 460).clamp(360.0, 900.0);
              return Container(
                width: width,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _T.bgSurface,
                  borderRadius: _T.r12,
                  border: Border.all(color: _T.border),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('СОДЕРЖИМОЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: 10),

                  // Title field
                  _EditorField(
                    controller: titleCtrl,
                    hint: 'Заголовок слайда...',
                    isTitle: true,
                  ),
                  const SizedBox(height: 8),

                  // Content fields
                  ...contentCtrl.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8, top: 2),
                        child: Icon(Icons.drag_indicator_rounded, color: _T.txtMuted, size: 14),
                      ),
                      Expanded(child: _EditorField(controller: e.value, hint: 'Пункт ${e.key + 1}...')),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => onRemoveItem(e.key),
                        child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 14),
                      ),
                    ]),
                  )),

                  // Add point
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onAddItem,
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.add_rounded, color: _T.accent, size: 14),
                      SizedBox(width: 4),
                      Text('Добавить пункт', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ]),
              );
            }),
          ]),
        ),
      ),
    );
  }
}

class _EditorField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isTitle;

  const _EditorField({required this.controller, required this.hint, this.isTitle = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: _T.txtPrimary,
        fontSize: isTitle ? 15 : 13,
        fontWeight: isTitle ? FontWeight.w700 : FontWeight.w400,
      ),
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _T.txtMuted, fontSize: 13),
        filled: true,
        fillColor: _T.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.accent, width: 1.5)),
        isDense: true,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTIES PANEL (Right)
// ═══════════════════════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index;
  final bool isPremium;
  final String activeTab;
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> backgrounds;
  final List<Map<String, dynamic>> premiumBgs;
  final String? customBg;
  final double fontSize;
  final bool isImproving;
  final ValueChanged<String> onTabChange;
  final ValueChanged<int> onBgSelect;
  final VoidCallback onBgUpload;
  final VoidCallback onImageUpload;
  final ValueChanged<String> onFontChange;
  final ValueChanged<double> onFontSizeChange;
  final VoidCallback onImprove;
  final int uploadsUsed;

  const _PropertiesPanel({
    required this.index,
    required this.isPremium,
    required this.activeTab,
    required this.globalFont,
    required this.selectedBgIndex,
    required this.backgrounds,
    required this.premiumBgs,
    required this.customBg,
    required this.fontSize,
    required this.isImproving,
    required this.onTabChange,
    required this.onBgSelect,
    required this.onBgUpload,
    required this.onImageUpload,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onImprove,
    required this.uploadsUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
        // Tab bar
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            _Tab('design', 'Дизайн', Icons.palette_rounded, activeTab, onTabChange),
            _Tab('image',  'Медиа',  Icons.image_rounded,   activeTab, onTabChange),
            _Tab('ai',     'ИИ',     Icons.auto_awesome_rounded, activeTab, onTabChange),
          ]),
        ),
        const Divider(color: _T.border, height: 1),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: switch (activeTab) {
              'image'  => _ImageTab(onUpload: onImageUpload, uploadsUsed: uploadsUsed, isPremium: isPremium),
              'ai'     => _AiTab(isImproving: isImproving, onImprove: onImprove),
              _        => _DesignTab(
                  globalFont: globalFont,
                  selectedBgIndex: selectedBgIndex,
                  backgrounds: backgrounds,
                  premiumBgs: premiumBgs,
                  customBg: customBg,
                  fontSize: fontSize,
                  isPremium: isPremium,
                  onBgSelect: onBgSelect,
                  onBgUpload: onBgUpload,
                  onFontChange: onFontChange,
                  onFontSizeChange: onFontSizeChange,
                ),
            },
          ),
        ),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String id, label;
  final IconData icon;
  final String active;
  final ValueChanged<String> onTap;

  const _Tab(this.id, this.label, this.icon, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = id == active;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(id),
        child: AnimatedContainer(
          duration: _T.fast,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? _T.accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isActive ? _T.accent.withOpacity(0.3) : Colors.transparent),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 12, color: isActive ? _T.accentLight : _T.txtMuted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? _T.accentLight : _T.txtMuted)),
          ]),
        ),
      ),
    );
  }
}

// ── Design Tab ────────────────────────────────────────────────────────────────
class _DesignTab extends StatelessWidget {
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> backgrounds;
  final List<Map<String, dynamic>> premiumBgs;
  final String? customBg;
  final double fontSize;
  final bool isPremium;
  final ValueChanged<int> onBgSelect;
  final VoidCallback onBgUpload;
  final ValueChanged<String> onFontChange;
  final ValueChanged<double> onFontSizeChange;

  const _DesignTab({
    required this.globalFont,
    required this.selectedBgIndex,
    required this.backgrounds,
    required this.premiumBgs,
    required this.customBg,
    required this.fontSize,
    required this.isPremium,
    required this.onBgSelect,
    required this.onBgUpload,
    required this.onFontChange,
    required this.onFontSizeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── FONT ────────────────────────────────────────────────────────────────
      _SectionLabel('ШРИФТ'),
      const SizedBox(height: 8),
      ...([
        {'name': 'Inter',   'label': 'Inter',   'sub': 'Современный'},
        {'name': 'Georgia', 'label': 'Georgia', 'sub': 'Элегантный'},
        {'name': 'Courier', 'label': 'Courier', 'sub': 'Моноширинный'},
      ].map((f) => GestureDetector(
        onTap: () => onFontChange(f['name']!),
        child: AnimatedContainer(
          duration: _T.fast,
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: globalFont == f['name'] ? _T.accentDim : _T.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: globalFont == f['name'] ? _T.accent.withOpacity(0.4) : _T.border),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f['label']!, style: TextStyle(fontFamily: f['name'], color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(f['sub']!, style: const TextStyle(color: _T.txtMuted, fontSize: 10)),
            ])),
            if (globalFont == f['name'])
              const Icon(Icons.check_circle_rounded, color: _T.accent, size: 16),
          ]),
        ),
      ))),

      const SizedBox(height: 18),

      // ── FONT SIZE ────────────────────────────────────────────────────────────
      _SectionLabel('РАЗМЕР ТЕКСТА'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _T.accent,
              inactiveTrackColor: _T.border,
              thumbColor: _T.accent,
              overlayColor: _T.accentDim,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: fontSize,
              min: 6, max: 18, divisions: 12,
              onChanged: onFontSizeChange,
            ),
          ),
        ),
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(6), border: Border.all(color: _T.border)),
          child: Text('${fontSize.toInt()}', style: const TextStyle(color: _T.txtPrimary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ),
      ]),

      const SizedBox(height: 18),

      // ── BACKGROUND ──────────────────────────────────────────────────────────
      _SectionLabel('ФОН'),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.4,
        children: backgrounds.asMap().entries.map((e) {
          final i = e.key;
          final bg = e.value;
          final selected = i == selectedBgIndex && customBg == null;
          return GestureDetector(
            onTap: () => onBgSelect(i),
            child: AnimatedContainer(
              duration: _T.fast,
              decoration: BoxDecoration(
                gradient: bg['type'] == 'gradient'
                    ? LinearGradient(colors: bg['colors'] as List<Color>, begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: selected ? _T.accent : Colors.transparent, width: 2),
                boxShadow: selected ? [BoxShadow(color: _T.accent.withOpacity(0.35), blurRadius: 6)] : null,
              ),
              child: selected ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 12)) : null,
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 8),

      // Upload own bg
      GestureDetector(
        onTap: onBgUpload,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _T.border, style: BorderStyle.solid),
          ),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.upload_rounded, color: _T.txtSecondary, size: 13),
            SizedBox(width: 6),
            Text('Загрузить фон', style: TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),

      if (!isPremium) ...[
        const SizedBox(height: 12),
        _SectionLabel('PREMIUM'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.4,
          children: premiumBgs.map((bg) => Stack(children: [
            Container(
              decoration: BoxDecoration(
                gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
              child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white54, size: 13)),
            ),
          ])).toList(),
        ),
      ],
    ]);
  }
}

// ── Image Tab ─────────────────────────────────────────────────────────────────
class _ImageTab extends StatelessWidget {
  final VoidCallback onUpload;
  final int uploadsUsed;
  final bool isPremium;

  const _ImageTab({required this.onUpload, required this.uploadsUsed, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('СВОЁ ИЗОБРАЖЕНИЕ'),
      const SizedBox(height: 8),

      // Usage indicator
      if (!isPremium) ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Использовано', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
          Text('$uploadsUsed / 10', style: TextStyle(
            color: uploadsUsed >= 10 ? _T.danger : _T.accent,
            fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: uploadsUsed / 10,
          backgroundColor: _T.border,
          color: uploadsUsed >= 10 ? _T.danger : _T.accent,
          borderRadius: BorderRadius.circular(4),
          minHeight: 4,
        ),
        const SizedBox(height: 12),
      ],

      GestureDetector(
        onTap: onUpload,
        child: Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _T.border, style: BorderStyle.solid),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image_rounded, color: _T.accent, size: 17),
            ),
            const SizedBox(height: 8),
            const Text('Нажмите для загрузки', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
            const Text('PNG, JPG до 10 МБ', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
          ]),
        ),
      ),

      const SizedBox(height: 16),
      const Text('Изображения подбираются автоматически через Unsplash на основе заголовка слайда.',
        style: TextStyle(color: _T.txtMuted, fontSize: 11, height: 1.5)),
    ]);
  }
}

// ── AI Tab ────────────────────────────────────────────────────────────────────
class _AiTab extends StatelessWidget {
  final bool isImproving;
  final VoidCallback onImprove;

  const _AiTab({required this.isImproving, required this.onImprove});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ИИ ПОМОЩНИК'),
      const SizedBox(height: 12),

      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_T.accent.withOpacity(0.08), _T.accentLight.withOpacity(0.05)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.accent.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Улучшить текст', style: TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              Text('Текущий слайд', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 10),
          const Text('ИИ перепишет заголовок и пункты — сделает текст чище и убедительнее.',
            style: TextStyle(color: _T.txtSecondary, fontSize: 11, height: 1.5)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: isImproving ? null : onImprove,
              child: AnimatedContainer(
                duration: _T.fast,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isImproving ? null : const LinearGradient(
                    colors: [Color(0xFF169C46), _T.accent, _T.accentLight],
                    begin: Alignment.centerLeft, end: Alignment.centerRight,
                  ),
                  color: isImproving ? _T.bgHover : null,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: isImproving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: _T.accent, strokeWidth: 2))
                      : const Text('Улучшить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ),
            ),
          ),
        ]),
      ),

      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.border)),
        child: const Row(children: [
          Icon(Icons.tips_and_updates_rounded, color: _T.gold, size: 14),
          SizedBox(width: 8),
          Expanded(child: Text('Совет: Добавьте контекст в текст для более точного улучшения.',
            style: TextStyle(color: _T.txtSecondary, fontSize: 11, height: 1.4))),
        ]),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONTROL BAR (Bottom)
// ═══════════════════════════════════════════════════════════════════════════════
class _ControlBar extends StatelessWidget {
  final int activeSlide;
  final int totalSlides;
  final bool propsPanelOpen;
  final VoidCallback onToggleProps;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onAdd;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _ControlBar({
    required this.activeSlide,
    required this.totalSlides,
    required this.propsPanelOpen,
    required this.onToggleProps,
    required this.onPrev,
    required this.onNext,
    required this.onAdd,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: _T.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        // Undo/Redo (decorative — state management требует отдельного impl)
        _IconBtn(Icons.undo_rounded, () {}, size: 16, tooltip: 'Отменить'),
        _IconBtn(Icons.redo_rounded, () {}, size: 16, tooltip: 'Повторить'),

        const SizedBox(width: 8),
        Container(width: 1, height: 20, color: _T.border),
        const SizedBox(width: 8),

        // Slide actions
        _IconBtn(Icons.copy_rounded, onDuplicate, size: 15, tooltip: 'Дублировать'),
        _IconBtn(Icons.delete_outline_rounded, onDelete, size: 15, tooltip: 'Удалить', danger: true),

        const Spacer(),

        // Navigation
        _IconBtn(Icons.arrow_back_rounded, onPrev, size: 16, disabled: activeSlide == 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${activeSlide + 1} / $totalSlides',
            style: const TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        _IconBtn(Icons.arrow_forward_rounded, onNext, size: 16, disabled: activeSlide == totalSlides - 1),

        const Spacer(),

        // Toggle props panel
        _IconBtn(
          propsPanelOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined,
          onToggleProps,
          size: 16,
          tooltip: propsPanelOpen ? 'Скрыть панель' : 'Показать панель',
          active: propsPanelOpen,
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORT SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isPremium;
  final Presentation presentation;

  const _ExportSheet({required this.isPremium, required this.presentation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: _T.bgSurface,
        borderRadius: _T.r16,
        border: Border.all(color: _T.border),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2))),
        ),
        const Text('Экспорт', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 4),
        const Text('Скачайте вашу презентацию', style: TextStyle(color: _T.txtSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            _ExportOption(
              icon: Icons.slideshow_rounded,
              color: _T.accent,
              title: 'PowerPoint (PPTX)',
              subtitle: isPremium ? 'Без водяного знака' : 'С водяным знаком',
              badge: isPremium ? 'PRO' : null,
              onTap: () {
                Navigator.pop(context);
                ExportService.exportToPPTX(context: context, presentation: presentation, isPremium: isPremium);
              },
            ),
            const SizedBox(height: 8),
            _ExportOption(
              icon: Icons.picture_as_pdf_rounded,
              color: isPremium ? _T.danger : _T.txtMuted,
              title: 'PDF',
              subtitle: isPremium ? 'Высокое качество' : 'Только Premium',
              locked: !isPremium,
              onTap: isPremium
                  ? () {
                      Navigator.pop(context);
                      ExportService.exportToPDF(context: context, presentation: presentation, isPremium: true);
                    }
                  : null,
            ),
          ]),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final bool locked;
  final VoidCallback? onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.border),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
            ])),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            if (locked)
              const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 16),
            if (!locked && badge == null)
              const Icon(Icons.arrow_forward_ios_rounded, color: _T.txtMuted, size: 12),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8));
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final bool danger;
  final bool active;
  final bool disabled;

  const _IconBtn(this.icon, this.onTap, {
    this.size = 18,
    this.tooltip,
    this.danger = false,
    this.active = false,
    this.disabled = false,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.disabled ? _T.txtMuted
        : widget.danger ? _T.danger
        : widget.active ? _T.accent
        : _hovered ? _T.txtPrimary
        : _T.txtSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: GestureDetector(
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: _T.fast,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _hovered && !widget.disabled ? _T.bgHover : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(widget.icon, size: widget.size, color: color),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════════
extension _IterableMapIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}