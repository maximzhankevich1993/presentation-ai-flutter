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

// ═══════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _T {
  static const bgBase    = Color(0xFF121212);
  static const bgSurface = Color(0xFF1A1A1A);
  static const bgCard    = Color(0xFF1E1E1E);
  static const bgHover   = Color(0xFF252525);
  static const border    = Color(0xFF2A2A2A);
  static const borderFocus = Color(0xFF3A3A3A);
  static const txtPrimary   = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted     = Color(0xFF4A4A4A);
  static const accent       = Color(0xFF1DB954);
  static const accentLight  = Color(0xFF1ED760);
  static const accentDim    = Color(0xFF1DB95420);
  static const danger       = Color(0xFFFF3B30);
  static const success      = Color(0xFF1DB954);
  static const gold         = Color(0xFFFFD700);
  static const r4  = BorderRadius.all(Radius.circular(4));
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const fast   = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow   = Duration(milliseconds: 320);
}

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with TickerProviderStateMixin {
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
  String _activePropTab = 'design';
  bool _isImproving = false;
  int _imageUploadsUsed = 0;

  // ⚠️ ВАЖНО: чёрный цвет по умолчанию
  Color _globalFontColor = Colors.black;
  late List<Color?> _slideFontColors;
  late List<String> _transitions;

  final Map<int, String?> _autoImages = {};
  final _scrollCtrl = ScrollController();
  final _canvasKey = GlobalKey();

  final List<Map<String, dynamic>> _freeBgs = [
    {'type': 'solid',    'color': Colors.white,                                               'label': 'Белый'},
    {'type': 'solid',    'color': const Color(0xFF0F0F0F),                                    'label': 'Чёрный'},
    {'type': 'solid',    'color': const Color(0xFFFFF8E7),                                    'label': 'Кремовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)],        'label': 'Midnight'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)],        'label': 'Фиолет'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],        'label': 'Голубой'},
    {'type': 'gradient', 'colors': [const Color(0xFFf093fb), const Color(0xFFf5576c)],        'label': 'Розовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF434343), const Color(0xFF000000)],        'label': 'Уголь'},
  ];

  final List<Map<String, dynamic>> _premiumBgs = [
    {'type': 'gradient', 'colors': [const Color(0xFF1DB954), const Color(0xFF191414)],                                   'label': 'Spotify'},
    {'type': 'gradient', 'colors': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],                                   'label': 'Неон'},
    {'type': 'gradient', 'colors': [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)],           'label': 'Cosmos'},
    {'type': 'gradient', 'colors': [const Color(0xFF11998e), const Color(0xFF38ef7d)],                                   'label': 'Mint'},
    {'type': 'gradient', 'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)],                                   'label': 'Закат'},
    {'type': 'gradient', 'colors': [const Color(0xFFFFE000), const Color(0xFF799F0C)],                                   'label': 'Лимон'},
    {'type': 'gradient', 'colors': [const Color(0xFF00b4db), const Color(0xFF0083B0)],                                   'label': 'Океан'},
    {'type': 'solid',    'color':  const Color(0xFF1A1A2E),                                                               'label': 'Navy'},
  ];

  static const List<Map<String, dynamic>> _allTransitions = [
    {'id': 'none',   'label': 'Нет',       'icon': Icons.block_rounded,         'premium': false},
    {'id': 'fade',   'label': 'Затухание', 'icon': Icons.blur_on_rounded,        'premium': false},
    {'id': 'slide',  'label': 'Слайд',     'icon': Icons.swap_horiz_rounded,     'premium': true},
    {'id': 'zoom',   'label': 'Зум',       'icon': Icons.zoom_in_rounded,        'premium': true},
    {'id': 'flip',   'label': 'Флип',      'icon': Icons.flip_rounded,           'premium': true},
    {'id': 'cube',   'label': 'Куб',       'icon': Icons.view_in_ar_rounded,     'premium': true},
  ];

  @override
  void initState() {
    super.initState();
    _presentation     = widget.presentation;
    _customImages     = List.filled(_presentation.slides.length, null);
    _customBgs        = List.filled(_presentation.slides.length, null);
    _fontSizes        = List.filled(_presentation.slides.length, 9.0);
    _fonts            = List.filled(_presentation.slides.length, 'Inter');
    _slideFontColors  = List.filled(_presentation.slides.length, null);
    _transitions      = List.filled(_presentation.slides.length, 'none');
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
      _slideFontColors.insert(idx, null);
      _transitions.insert(idx, 'none');
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
      _slideFontColors.removeAt(i);
      _transitions.removeAt(i);
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
      _slideFontColors.insert(idx, _slideFontColors[i]);
      _transitions.insert(idx, _transitions[i]);
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
      swap(_slideFontColors);
      swap(_transitions);
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

  Future<void> _uploadImage(int index) async {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    if (!p) {
      _toast('Замена картинок — только в Premium', warning: true);
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

  Decoration _slideDeco(int index) {
    if (_customBgs[index] != null) {
      return BoxDecoration(
        image: DecorationImage(image: NetworkImage(_customBgs[index]!), fit: BoxFit.cover),
        borderRadius: _T.r12,
      );
    }
    final bg = _freeBgs[_selectedBgIndex.clamp(0, _freeBgs.length - 1)];
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
    final bg = _freeBgs[_selectedBgIndex.clamp(0, _freeBgs.length - 1)];
    if (bg['type'] == 'solid') return (bg['color'] as Color).computeLuminance() < 0.5;
    return true;
  }

  void _toast(String msg, {bool success = false, bool error = false, bool warning = false}) {
    Color bg = _T.bgCard;
    if (success) bg = _T.success.withOpacity(0.9);
    if (error)   bg = _T.danger.withOpacity(0.9);
    if (warning) bg = _T.gold.withOpacity(0.9);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

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

  @override
  Widget build(BuildContext context) {
    // Авто-выбор цвета текста при смене фона
    final dark = _isDark(_activeSlide);
    if (_slideFontColors[_activeSlide] == null) {
      _globalFontColor = dark ? Colors.white : Colors.black;
    }

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
            AnimatedContainer(
              duration: _T.normal,
              width: _navCollapsed ? 48 : 200,
              child: _SlideNavigator(
                slides: _presentation.slides,
                titleControllers: _titleCtrl,
                activeIndex: _activeSlide,
                collapsed: _navCollapsed,
                customBgs: _customBgs,
                backgrounds: _freeBgs,
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
                fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor,
                slideCount: _presentation.slides.length,
                onAddItem: () => _addContentItem(_activeSlide),
                onRemoveItem: (i) => _removeContentItem(_activeSlide, i),
                onRemoveImage: () => setState(() { _customImages[_activeSlide] = null; _countUploads(); }),
                hasCustomImage: _customImages[_activeSlide] != null,
              ),
            ),
            const VerticalDivider(color: _T.border, width: 1),
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
                      freeBgs: _freeBgs,
                      premiumBgs: _premiumBgs,
                      customBg: _customBgs[_activeSlide],
                      fontSize: _fontSizes[_activeSlide],
                      fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor,
                      transition: _transitions[_activeSlide],
                      allTransitions: _allTransitions,
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
                      onFontColorChange: (c) => setState(() {
                        _slideFontColors[_activeSlide] = c;
                        _globalFontColor = c;
                      }),
                      onTransitionChange: (t) => setState(() => _transitions[_activeSlide] = t),
                      uploadsUsed: _imageUploadsUsed,
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
        ),
        const SizedBox(height: 100), // TODO: remove spacer
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

// ═══════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════
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
        _IconBtn(Icons.arrow_back_ios_rounded, onBack, tooltip: 'Назад', size: 17),
        const SizedBox(width: 8),
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
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
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SLIDE NAVIGATOR
// ═══════════════════════════════════════════════════════════════
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

  Color _getThumbnailColor(int i) {
    if (customBgs[i] != null) return Colors.grey.shade800;
    final bg = backgrounds[selectedBgIndex.clamp(0, backgrounds.length - 1)];
    if (bg['type'] == 'solid') return bg['color'] as Color;
    return (bg['colors'] as List<Color>).first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
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
      cursor: SystemMouseCursors.click,
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
          child: widget.collapsed ? _collapsedView() : _expandedView(),
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

// ═══════════════════════════════════════════════════════════════
// CANVAS
// ═══════════════════════════════════════════════════════════════
class _Canvas extends StatelessWidget {
  final int index;
  final TextEditingController titleCtrl;
  final List<TextEditingController> contentCtrl;
  final Decoration decoration;
  final bool isDark;
  final String? image;
  final String font;
  final double fontSize;
  final Color fontColor;
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
    required this.fontColor,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('${index + 1} / $slideCount',
                style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
            LayoutBuilder(builder: (ctx, constraints) {
              final width = (MediaQuery.of(context).size.width - 460).clamp(360.0, 900.0);
              final height = width * 9 / 16;
              return Container(
                width: width,
                height: height,
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  Positioned(
                    top: 12, left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)),
                      child: Text('${index + 1}',
                        style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          EditableText(
                            controller: titleCtrl,
                            focusNode: FocusNode(),
                            style: TextStyle(
                              fontSize: fontSize * 2.2,
                              fontWeight: FontWeight.w800,
                              fontFamily: font,
                              color: fontColor,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                            cursorColor: _T.accent,
                            backgroundCursorColor: _T.accent,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
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
                                    color: fontColor.withOpacity(0.8),
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
                  _EditorField(controller: titleCtrl, hint: 'Заголовок слайда...', isTitle: true),
                  const SizedBox(height: 8),
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

// ═══════════════════════════════════════════════════════════════
// PROPERTIES PANEL
// ═══════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index;
  final bool isPremium;
  final String activeTab;
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> freeBgs;
  final List<Map<String, dynamic>> premiumBgs;
  final String? customBg;
  final double fontSize;
  final Color fontColor;
  final String transition;
  final List<Map<String, dynamic>> allTransitions;
  final bool isImproving;
  final ValueChanged<String> onTabChange;
  final ValueChanged<int> onBgSelect;
  final VoidCallback onBgUpload;
  final VoidCallback onImageUpload;
  final ValueChanged<String> onFontChange;
  final ValueChanged<double> onFontSizeChange;
  final ValueChanged<Color> onFontColorChange;
  final ValueChanged<String> onTransitionChange;
  final int uploadsUsed;

  const _PropertiesPanel({
    required this.index,
    required this.isPremium,
    required this.activeTab,
    required this.globalFont,
    required this.selectedBgIndex,
    required this.freeBgs,
    required this.premiumBgs,
    required this.customBg,
    required this.fontSize,
    required this.fontColor,
    required this.transition,
    required this.allTransitions,
    required this.isImproving,
    required this.onTabChange,
    required this.onBgSelect,
    required this.onBgUpload,
    required this.onImageUpload,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onFontColorChange,
    required this.onTransitionChange,
    required this.uploadsUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(children: [
            _Tab('design', 'Дизайн', Icons.palette_rounded, activeTab, onTabChange),
            _Tab('image', 'Медиа', Icons.image_rounded, activeTab, onTabChange),
            _Tab('ai', 'ИИ', Icons.auto_awesome_rounded, activeTab, onTabChange),
          ]),
        ),
        const Divider(color: _T.border, height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: switch (activeTab) {
              'image' => _ImageTab(onUpload: onImageUpload, isPremium: isPremium),
              'ai'    => _AiTab(isImproving: isImproving, onImprove: () {}),
              _       => _DesignTab(
                  globalFont: globalFont,
                  selectedBgIndex: selectedBgIndex,
                  freeBgs: freeBgs,
                  premiumBgs: premiumBgs,
                  customBg: customBg,
                  fontSize: fontSize,
                  fontColor: fontColor,
                  transition: transition,
                  allTransitions: allTransitions,
                  isPremium: isPremium,
                  onBgSelect: onBgSelect,
                  onBgUpload: onBgUpload,
                  onFontChange: onFontChange,
                  onFontSizeChange: onFontSizeChange,
                  onFontColorChange: onFontColorChange,
                  onTransitionChange: onTransitionChange,
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

class _DesignTab extends StatelessWidget {
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> freeBgs;
  final List<Map<String, dynamic>> premiumBgs;
  final String? customBg;
  final double fontSize;
  final Color fontColor;
  final String transition;
  final List<Map<String, dynamic>> allTransitions;
  final bool isPremium;
  final ValueChanged<int> onBgSelect;
  final VoidCallback onBgUpload;
  final ValueChanged<String> onFontChange;
  final ValueChanged<double> onFontSizeChange;
  final ValueChanged<Color> onFontColorChange;
  final ValueChanged<String> onTransitionChange;

  const _DesignTab({
    required this.globalFont,
    required this.selectedBgIndex,
    required this.freeBgs,
    required this.premiumBgs,
    required this.customBg,
    required this.fontSize,
    required this.fontColor,
    required this.transition,
    required this.allTransitions,
    required this.isPremium,
    required this.onBgSelect,
    required this.onBgUpload,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onFontColorChange,
    required this.onTransitionChange,
  });

  static const List<Color> _fontColors = [
    Colors.white,
    Color(0xFFF2F2F2),
    Color(0xFF1A1A2E),
    Colors.black,
    Color(0xFF1DB954),
    Color(0xFF4facfe),
    Color(0xFFf5576c),
    Color(0xFFFFD700),
    Color(0xFFf093fb),
    Color(0xFFFF6B35),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ШРИФТ'),
      const SizedBox(height: 8),
      ...(['Inter', 'Georgia', 'Courier'].map((f) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onFontChange(f),
          child: AnimatedContainer(
            duration: _T.fast,
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: globalFont == f ? _T.accentDim : _T.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: globalFont == f ? _T.accent.withOpacity(0.4) : _T.border),
            ),
            child: Row(children: [
              Expanded(child: Text(f, style: TextStyle(fontFamily: f, color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w600))),
              if (globalFont == f) const Icon(Icons.check_circle_rounded, color: _T.accent, size: 16),
            ]),
          ),
        ),
      ))),
      const SizedBox(height: 18),
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
            child: Slider(value: fontSize, min: 6, max: 18, divisions: 12, onChanged: onFontSizeChange),
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
      _SectionLabel('ЦВЕТ ТЕКСТА'),
      const SizedBox(height: 10),
      Wrap(
        spacing: 7, runSpacing: 7,
        children: _fontColors.map((c) {
          final selected = fontColor.value == c.value;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onFontColorChange(c),
              child: AnimatedContainer(
                duration: _T.fast,
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(color: selected ? _T.accent : Colors.white12, width: selected ? 2.5 : 1),
                  boxShadow: selected ? [BoxShadow(color: _T.accent.withOpacity(0.4), blurRadius: 6)] : null,
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 18),
      _SectionLabel('ФОН'),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.4,
        children: freeBgs.asMap().entries.map((e) {
          final i = e.key; final bg = e.value;
          final selected = i == selectedBgIndex && customBg == null;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onBgSelect(i),
              child: AnimatedContainer(
                duration: _T.fast,
                decoration: BoxDecoration(
                  gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                  color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: selected ? _T.accent : Colors.transparent, width: 2),
                  boxShadow: selected ? [BoxShadow(color: _T.accent.withOpacity(0.35), blurRadius: 6)] : null,
                ),
                child: selected ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 12)) : null,
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 8),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onBgUpload,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: _T.border)),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.upload_rounded, color: _T.txtSecondary, size: 13),
              SizedBox(width: 6),
              Text('Загрузить фон', style: TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [_SectionLabel('PREMIUM ФОНЫ'), const Spacer(), if (!isPremium) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: const Text('PRO', style: TextStyle(color: _T.gold, fontSize: 9, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.4,
        children: premiumBgs.asMap().entries.map((e) {
          final i = e.key; final bg = e.value;
          return MouseRegion(
            cursor: isPremium ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            child: GestureDetector(
              onTap: isPremium ? () => onBgSelect(freeBgs.length + i) : null,
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                    color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                if (!isPremium)
                  Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white54, size: 13))),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 18),
      Row(children: [_SectionLabel('ПЕРЕХОД'), const Spacer(), if (!isPremium) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: const Text('2 бесплатно', style: TextStyle(color: _T.gold, fontSize: 9, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 2.0,
        children: allTransitions.map((t) {
          final isPrem = t['premium'] as bool;
          final locked = isPrem && !isPremium;
          final selected = transition == t['id'];
          return MouseRegion(
            cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: locked ? null : () => onTransitionChange(t['id'] as String),
              child: AnimatedContainer(
                duration: _T.fast,
                decoration: BoxDecoration(
                  color: selected ? _T.accentDim : _T.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? _T.accent.withOpacity(0.5) : _T.border),
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(t['icon'] as IconData, size: 16, color: locked ? _T.txtMuted : selected ? _T.accent : _T.txtSecondary),
                    const SizedBox(height: 3),
                    Text(t['label'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: locked ? _T.txtMuted : selected ? _T.accent : _T.txtSecondary)),
                  ]),
                  if (locked) Positioned(top: 4, right: 4, child: Icon(Icons.lock_rounded, size: 9, color: _T.gold.withOpacity(0.7))),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

class _ImageTab extends StatelessWidget {
  final VoidCallback onUpload;
  final bool isPremium;

  const _ImageTab({required this.onUpload, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ИЗОБРАЖЕНИЕ НА СЛАЙДЕ'),
      const SizedBox(height: 8),
      if (!isPremium)
        Container(
          width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: _T.gold.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.gold.withOpacity(0.2))),
          child: Row(children: const [
            Icon(Icons.star_rounded, color: _T.gold, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text('Замена изображений — Premium.', style: TextStyle(color: _T.gold, fontSize: 11, fontWeight: FontWeight.w500))),
          ]),
        ),
      MouseRegion(
        cursor: isPremium ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: isPremium ? onUpload : null,
          child: AnimatedContainer(
            duration: _T.fast,
            width: double.infinity, height: 90,
            decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: isPremium ? _T.border : _T.border.withOpacity(0.4))),
            child: Opacity(
              opacity: isPremium ? 1.0 : 0.4,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image_rounded, color: _T.accent, size: 17)),
                const SizedBox(height: 8),
                const Text('Нажмите для загрузки', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
                const Text('PNG, JPG до 10 МБ', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(10), border: Border.all(color: _T.border)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, color: _T.txtMuted, size: 13),
          SizedBox(width: 8),
          Expanded(child: Text('Unsplash автоматически подбирает изображение.', style: TextStyle(color: _T.txtMuted, fontSize: 11, height: 1.5))),
        ]),
      ),
    ]);
  }
}

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
          gradient: LinearGradient(colors: [_T.accent.withOpacity(0.08), _T.accentLight.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.accent.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15)),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Улучшить текст', style: TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              Text('Текущий слайд', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
            ]),
          ]),
          const SizedBox(height: 10),
          const Text('ИИ перепишет заголовок и пункты.', style: TextStyle(color: _T.txtSecondary, fontSize: 11, height: 1.5)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: isImproving ? null : onImprove,
              child: AnimatedContainer(
                duration: _T.fast,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isImproving ? null : const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight], begin: Alignment.centerLeft, end: Alignment.centerRight),
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
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════
// EXPORT SHEET
// ═══════════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isPremium;
  final Presentation presentation;

  const _ExportSheet({required this.isPremium, required this.presentation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(color: _T.bgSurface, borderRadius: _T.r16, border: Border.all(color: _T.border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
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
            _ExportOption(icon: Icons.slideshow_rounded, color: _T.accent, title: 'PowerPoint (PPTX)', subtitle: isPremium ? 'Без водяного знака' : 'С водяным знаком', badge: isPremium ? 'PRO' : null, onTap: () { Navigator.pop(context); ExportService.exportToPPTX(context: context, presentation: presentation, isPremium: isPremium); }),
            const SizedBox(height: 8),
            _ExportOption(icon: Icons.picture_as_pdf_rounded, color: isPremium ? _T.danger : _T.txtMuted, title: 'PDF', subtitle: isPremium ? 'Высокое качество' : 'Только Premium', locked: !isPremium, onTap: isPremium ? () { Navigator.pop(context); ExportService.exportToPDF(context: context, presentation: presentation, isPremium: true); } : null),
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

  const _ExportOption({required this.icon, required this.color, required this.title, required this.subtitle, this.badge, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
            ])),
            if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(5)), child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
            if (locked) const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 16),
            if (!locked && badge == null) const Icon(Icons.arrow_forward_ios_rounded, color: _T.txtMuted, size: 12),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED
// ═══════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8));
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final bool danger;
  final bool active;
  final bool disabled;

  const _IconBtn(this.icon, this.onTap, {this.size = 18, this.tooltip, this.danger = false, this.active = false, this.disabled = false});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.disabled ? _T.txtMuted : widget.danger ? _T.danger : widget.active ? _T.accent : _hovered ? _T.txtPrimary : _T.txtSecondary;

    return MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: GestureDetector(
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: _T.fast,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _hovered && !widget.disabled ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(7)),
            child: Icon(widget.icon, size: widget.size, color: color),
          ),
        ),
      ),
    );
  }
}

extension _IterableMapIndexed<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T element) f) {
    var i = 0;
    return map((e) => f(i++, e));
  }
}