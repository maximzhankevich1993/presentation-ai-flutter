import 'dart:math';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../providers/logo_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/image_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════════════════════
class _T {
  // Backgrounds — slightly warmer than pure #12
  static const bgBase    = Color(0xFF0E0E0E);
  static const bgSurface = Color(0xFF161616);
  static const bgCard    = Color(0xFF1C1C1C);
  static const bgHover   = Color(0xFF222222);

  // Borders — more subtle with opacity
  static const border    = Color(0x12FFFFFF); // ~7 %
  static const borderEm  = Color(0x1FFFFFFF); // ~12 %

  // Text
  static const txtPrimary   = Color(0xFFF0F0F0);
  static const txtSecondary = Color(0xFF888888);
  static const txtMuted     = Color(0xFF444444);

  // Accent – Spotify green, unchanged
  static const accent      = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim   = Color(0x1F1DB954); // 12 %

  // Semantic
  static const danger  = Color(0xFFFF3B30);
  static const success = Color(0xFF1DB954);
  static const gold    = Color(0xFFFFD700);

  // Radii
  static const r8  = BorderRadius.all(Radius.circular(8));
  static const r10 = BorderRadius.all(Radius.circular(10));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r14 = BorderRadius.all(Radius.circular(14));
  static const r16 = BorderRadius.all(Radius.circular(16));

  // Durations
  static const fast   = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════════════════

/// A thin 0.5 px divider that respects the design token border colour.
class _ThinDivider extends StatelessWidget {
  final Axis direction;
  const _ThinDivider({this.direction = Axis.horizontal});

  @override
  Widget build(BuildContext context) {
    return direction == Axis.horizontal
        ? const Divider(color: _T.border, height: 1, thickness: 0.5)
        : const VerticalDivider(color: _T.border, width: 1, thickness: 0.5);
  }
}

/// A small pill badge.
class _Pill extends StatelessWidget {
  final String label;
  final Color bg, fg, borderColor;
  const _Pill({
    required this.label,
    this.bg = _T.accentDim,
    this.fg = _T.accentLight,
    this.borderColor = const Color(0x331DB954),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: _T.r16,
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEXT STYLE PRESET
// ═══════════════════════════════════════════════════════════════════════════════
class TextStylePreset {
  final String name;
  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final bool isItalic;
  const TextStylePreset({
    required this.name,
    required this.fontSize,
    required this.fontWeight,
    this.letterSpacing = 0,
    this.isItalic = false,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHAPE MODEL
// ═══════════════════════════════════════════════════════════════════════════════
class SlideShape {
  final String id;
  final String type;
  double x, y, width, height;
  Color color;
  double opacity;

  SlideShape({
    required this.id,
    required this.type,
    this.x = 50,
    this.y = 50,
    this.width = 80,
    this.height = 80,
    this.color = Colors.white,
    this.opacity = 0.8,
  });

  SlideShape copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    Color? color,
    double? opacity,
  }) {
    return SlideShape(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE TEMPLATE
// ═══════════════════════════════════════════════════════════════════════════════
class SlideTemplate {
  final String id, name;
  final IconData icon;
  final Slide Function() build;
  const SlideTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.build,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// HOVER CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _HoverCard({required this.child, required this.onTap});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: _T.fast,
          scale: hover ? 1.02 : 1,
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EDITOR SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  late Presentation _presentation;
  late List<TextEditingController> _titleCtrl;
  late List<List<TextEditingController>> _contentCtrl;
  late List<String?> _customImages, _customBgs;
  late List<double> _fontSizes;
  late List<String> _fonts;

  int _activeSlide = 0;
  int _selectedBgIndex = 0;
  int _imageUploadsUsed = 0;
  String _globalFont = 'Inter';
  String _activePropTab = 'design';
  String _currentTextStyle = 'body';
  String _currentTextAlign = 'left';
  bool _navCollapsed = false;
  bool _propsPanelOpen = true;
  bool _isImproving = false;
  int _columnsCount = 1;
  Color _globalFontColor = _T.txtPrimary;

  late List<Color?> _slideFontColors;
  late List<String> _transitions;
  late List<String?> _chartTypes;
  late List<List<Map<String, dynamic>>> _chartData;
  late List<List<SlideShape>> _shapes;
  late List<double?> _imageWidths, _imageHeights;
  late List<String?> _imagePositions, _imageTextWrap;

  final Map<int, String?> _autoImages = {};
  final _scrollCtrl = ScrollController();

  // ─── Templates ──────────────────────────────────────────────────────────────
  final List<SlideTemplate> _slideTemplates = [
    const SlideTemplate(
      id: 'cover_left',
      name: 'Обложка слева',
      icon: Icons.format_align_left_rounded,
      build: _buildCoverLeft,
    ),
    const SlideTemplate(
      id: 'cover_center',
      name: 'Обложка центр',
      icon: Icons.format_align_center_rounded,
      build: _buildCoverCenter,
    ),
    const SlideTemplate(
      id: 'two_columns',
      name: 'Две колонки',
      icon: Icons.view_column_rounded,
      build: _buildTwoColumns,
    ),
    const SlideTemplate(
      id: 'image_text',
      name: 'Изображение и текст',
      icon: Icons.image_rounded,
      build: _buildImageText,
    ),
    const SlideTemplate(
      id: 'quote',
      name: 'Цитата',
      icon: Icons.format_quote_rounded,
      build: _buildQuote,
    ),
  ];

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _freeBgs = [
    {'type': 'solid',    'color': const Color(0xFF1A1A1A),  'label': 'Тёмный'},
    {'type': 'solid',    'color': Colors.white,              'label': 'Белый'},
    {'type': 'gradient', 'colors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)], 'label': 'Midnight'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)], 'label': 'Фиолет'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)], 'label': 'Голубой'},
  ];

  static const List<Map<String, dynamic>> _allTransitions = [
    {'id': 'none',  'label': 'Нет',       'premium': false},
    {'id': 'fade',  'label': 'Затухание', 'premium': false},
    {'id': 'slide', 'label': 'Слайд',     'premium': true},
    {'id': 'zoom',  'label': 'Зум',       'premium': true},
  ];

  final Map<String, TextStylePreset> _textStyles = {
    'h1':   const TextStylePreset(name: 'Заголовок 1',    fontSize: 32, fontWeight: FontWeight.w800),
    'h2':   const TextStylePreset(name: 'Заголовок 2',    fontSize: 24, fontWeight: FontWeight.w700),
    'h3':   const TextStylePreset(name: 'Заголовок 3',    fontSize: 18, fontWeight: FontWeight.w600),
    'body': const TextStylePreset(name: 'Основной текст', fontSize: 14, fontWeight: FontWeight.w400),
    'quote':const TextStylePreset(name: 'Цитата',         fontSize: 16, fontWeight: FontWeight.w400, isItalic: true),
  };

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    final len = _presentation.slides.length;
    _customImages    = List.filled(len, null);
    _customBgs       = List.filled(len, null);
    _fontSizes       = List.filled(len, 14.0);
    _fonts           = List.filled(len, 'Inter');
    _slideFontColors = List.filled(len, _T.txtPrimary);
    _transitions     = List.filled(len, 'none');
    _chartTypes      = List.filled(len, null);
    _chartData       = List.filled(len, []);
    _shapes          = List.generate(len, (_) => []);
    _imageWidths     = List.filled(len, 0.28);
    _imageHeights    = List.filled(len, 0.55);
    _imagePositions  = List.filled(len, 'right');
    _imageTextWrap   = List.filled(len, 'around');
    _initControllers();
    _loadAutoImages();
    _countUploads();
  }

  void _initControllers() {
    _titleCtrl   = _presentation.slides.map((s) => TextEditingController(text: s.title)).toList();
    _contentCtrl = _presentation.slides
        .map((s) => s.content.map((c) => TextEditingController(text: c)).toList())
        .toList();
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

  // ─── Slide management ────────────────────────────────────────────────────────
  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title   = _titleCtrl[i].text;
      _presentation.slides[i].content = _contentCtrl[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    setState(() {
      final idx = _activeSlide + 1;
      _presentation.slides.insert(idx, Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleCtrl.insert(idx,    TextEditingController(text: 'Новый слайд'));
      _contentCtrl.insert(idx,  [TextEditingController(text: 'Введите текст')]);
      _customImages.insert(idx,    null);
      _customBgs.insert(idx,       null);
      _fontSizes.insert(idx,       14.0);
      _fonts.insert(idx,           _globalFont);
      _slideFontColors.insert(idx, _T.txtPrimary);
      _transitions.insert(idx,     'none');
      _chartTypes.insert(idx,      null);
      _chartData.insert(idx,       []);
      _shapes.insert(idx,          []);
      _imageWidths.insert(idx,     0.28);
      _imageHeights.insert(idx,    0.55);
      _imagePositions.insert(idx,  'right');
      _imageTextWrap.insert(idx,   'around');
      _activeSlide = idx;
    });
  }

  void _deleteSlide(int i) {
    if (_presentation.slides.length <= 1) return;
    setState(() {
      _titleCtrl[i].dispose();
      for (final c in _contentCtrl[i]) c.dispose();
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
      _chartTypes.removeAt(i);
      _chartData.removeAt(i);
      _shapes.removeAt(i);
      _imageWidths.removeAt(i);
      _imageHeights.removeAt(i);
      _imagePositions.removeAt(i);
      _imageTextWrap.removeAt(i);
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
        title:   _presentation.slides[i].title,
        content: List.from(_presentation.slides[i].content),
      ));
      _titleCtrl.insert(idx,    TextEditingController(text: _titleCtrl[i].text));
      _contentCtrl.insert(idx,  _contentCtrl[i].map((c) => TextEditingController(text: c.text)).toList());
      _customImages.insert(idx,    _customImages[i]);
      _customBgs.insert(idx,       _customBgs[i]);
      _fontSizes.insert(idx,       _fontSizes[i]);
      _fonts.insert(idx,           _fonts[i]);
      _slideFontColors.insert(idx, _slideFontColors[i]);
      _transitions.insert(idx,     _transitions[i]);
      _chartTypes.insert(idx,      _chartTypes[i]);
      _chartData.insert(idx,       List.from(_chartData[i]));
      _shapes.insert(idx,          _shapes[i].map((s) => s.copyWith()).toList());
      _imageWidths.insert(idx,     _imageWidths[i]);
      _imageHeights.insert(idx,    _imageHeights[i]);
      _imagePositions.insert(idx,  _imagePositions[i]);
      _imageTextWrap.insert(idx,   _imageTextWrap[i]);
      _activeSlide = idx;
    });
    _countUploads();
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

  void _addShape(String type) {
    setState(() {
      _shapes[_activeSlide].add(SlideShape(
        id: DateTime.now().toString(),
        type: type,
        x: 100, y: 100, width: 80, height: 80,
        color: _globalFontColor, opacity: 0.8,
      ));
    });
  }

  void _removeShape(String id) =>
      setState(() => _shapes[_activeSlide].removeWhere((s) => s.id == id));

  void _updateImageWidth(double w)    => setState(() => _imageWidths[_activeSlide] = w);
  void _updateImageHeight(double h)   => setState(() => _imageHeights[_activeSlide] = h);
  void _updateImagePosition(String p) => setState(() => _imagePositions[_activeSlide] = p);
  void _updateImageTextWrap(String w) => setState(() => _imageTextWrap[_activeSlide] = w);

  // ─── Static template builders ────────────────────────────────────────────────
  static Slide _buildCoverLeft()   => Slide(title: 'Заголовок', content: ['Подзаголовок']);
  static Slide _buildCoverCenter() => Slide(title: 'Заголовок', content: ['Подзаголовок']);
  static Slide _buildTwoColumns()  => Slide(title: 'Заголовок', content: ['Текст колонки 1', 'Текст колонки 2']);
  static Slide _buildImageText()   => Slide(title: 'Заголовок', content: ['Описание изображения']);
  static Slide _buildQuote()       => Slide(title: 'Цитата',    content: ['Важная цитата']);

  // ─── Modals ──────────────────────────────────────────────────────────────────
  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TemplateSheet(
        templates: _slideTemplates,
        onSelect: (template) {
          Navigator.pop(context);
          final idx      = _activeSlide + 1;
          final newSlide = template.build();
          setState(() {
            _presentation.slides.insert(idx, newSlide);
            _titleCtrl.insert(idx,    TextEditingController(text: newSlide.title));
            _contentCtrl.insert(idx,  newSlide.content.map((c) => TextEditingController(text: c)).toList());
            _customImages.insert(idx,    null);
            _customBgs.insert(idx,       null);
            _fontSizes.insert(idx,       14.0);
            _fonts.insert(idx,           _globalFont);
            _slideFontColors.insert(idx, _T.txtPrimary);
            _transitions.insert(idx,     'none');
            _chartTypes.insert(idx,      null);
            _chartData.insert(idx,       []);
            _shapes.insert(idx,          []);
            _imageWidths.insert(idx,     0.28);
            _imageHeights.insert(idx,    0.55);
            _imagePositions.insert(idx,  'right');
            _imageTextWrap.insert(idx,   'around');
            _activeSlide = idx;
          });
        },
      ),
    );
  }

  // ─── AI improve ──────────────────────────────────────────────────────────────
  Future<void> _improveSlide(int index) async {
    setState(() => _isImproving = true);
    try {
      final t  = await AiImproveService.improveText(_titleCtrl[index].text);
      final cs = <String>[];
      for (final c in _contentCtrl[index]) {
        cs.add(await AiImproveService.improveText(c.text));
      }
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

  // ─── Upload helpers ──────────────────────────────────────────────────────────
  Future<void> _uploadImage(int idx) async {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    if (!isPremium) { _toast('Premium функция', warning: true); return; }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() {
        _customImages[idx]   = reader.result as String;
        _imageWidths[idx]    = 0.28;
        _imageHeights[idx]   = 0.55;
        _imagePositions[idx] = 'right';
      }));
    });
  }

  Future<void> _uploadBg(int idx) async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() => _customBgs[idx] = reader.result as String));
    });
  }

  // ─── Slide decoration ────────────────────────────────────────────────────────
  Decoration _slideDeco(int idx) {
    const shadow = BoxShadow(
      color: Color(0x44000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    );
    if (_customBgs[idx] != null) {
      return BoxDecoration(
        image: DecorationImage(image: NetworkImage(_customBgs[idx]!), fit: BoxFit.cover),
        borderRadius: _T.r16,
        boxShadow: const [shadow],
      );
    }
    final bg = _freeBgs[_selectedBgIndex.clamp(0, _freeBgs.length - 1)];
    if (bg['type'] == 'gradient') {
      return BoxDecoration(
        gradient: LinearGradient(colors: bg['colors'] as List<Color>),
        borderRadius: _T.r16,
        boxShadow: const [shadow],
      );
    }
    return BoxDecoration(
      color: bg['color'] as Color,
      borderRadius: _T.r16,
      boxShadow: const [shadow],
    );
  }

  // ─── Toast ───────────────────────────────────────────────────────────────────
  void _toast(String msg, {bool success = false, bool error = false, bool warning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: success ? _T.success : error ? _T.danger : warning ? _T.gold : _T.bgCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: _T.r10),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      duration: const Duration(seconds: 2),
    ));
  }

  // ─── Export ──────────────────────────────────────────────────────────────────
  void _export() {
    _saveAll();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExportSheet(
        isPremium: Provider.of<UserProvider>(context, listen: false).isPremium,
        presentation: _presentation,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────
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
        const _ThinDivider(),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Left navigator ──────────────────────────────────────────────
            AnimatedContainer(
              duration: _T.normal,
              width: _navCollapsed ? 48 : 188,
              child: _SlideNavigator(
                slides: _presentation.slides,
                titleControllers: _titleCtrl,
                activeIndex: _activeSlide,
                collapsed: _navCollapsed,
                customBgs: _customBgs,
                backgrounds: _freeBgs,
                selectedBgIndex: _selectedBgIndex,
                onSelect:    (i) => setState(() => _activeSlide = i),
                onAdd:       _addSlide,
                onDelete:    _deleteSlide,
                onDuplicate: _duplicateSlide,
                onMoveUp: (i) => setState(() {
                  final tmp = _presentation.slides[i];
                  _presentation.slides[i]     = _presentation.slides[i - 1];
                  _presentation.slides[i - 1] = tmp;
                  _activeSlide = i - 1;
                }),
                onMoveDown: (i) => setState(() {
                  final tmp = _presentation.slides[i];
                  _presentation.slides[i]     = _presentation.slides[i + 1];
                  _presentation.slides[i + 1] = tmp;
                  _activeSlide = i + 1;
                }),
                onToggleCollapse: () => setState(() => _navCollapsed = !_navCollapsed),
              ),
            ),
            const _ThinDivider(direction: Axis.vertical),

            // ── Centre canvas ───────────────────────────────────────────────
            Expanded(
              child: _Canvas(
                index: _activeSlide,
                titleCtrl: _titleCtrl[_activeSlide],
                contentCtrl: _contentCtrl[_activeSlide],
                decoration: _slideDeco(_activeSlide),
                font: _fonts[_activeSlide] != 'Inter' ? _fonts[_activeSlide] : _globalFont,
                fontSize: _fontSizes[_activeSlide],
                fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor,
                slideCount: _presentation.slides.length,
                image: _customImages[_activeSlide] ?? _autoImages[_activeSlide],
                hasCustomImage: _customImages[_activeSlide] != null,
                onRemoveImage: () => setState(() { _customImages[_activeSlide] = null; _countUploads(); }),
                textStyle: _currentTextStyle,
                textAlign: _currentTextAlign,
                columnsCount: _columnsCount,
                chartType: _chartTypes[_activeSlide],
                chartData: _chartData[_activeSlide],
                shapes: _shapes[_activeSlide],
                imageWidth:    _imageWidths[_activeSlide] ?? 0.28,
                imageHeight:   _imageHeights[_activeSlide] ?? 0.55,
                imagePosition: _imagePositions[_activeSlide] ?? 'right',
                imageTextWrap: _imageTextWrap[_activeSlide] ?? 'around',
                onAddItem:    () => _addContentItem(_activeSlide),
                onRemoveItem: (i) => _removeContentItem(_activeSlide, i),
              ),
            ),
            const _ThinDivider(direction: Axis.vertical),

            // ── Right properties panel ──────────────────────────────────────
            AnimatedContainer(
              duration: _T.normal,
              width: _propsPanelOpen ? 264 : 0,
              child: AnimatedSwitcher(
                duration: _T.fast,
                child: !_propsPanelOpen
                    ? const SizedBox.shrink()
                    : _PropertiesPanel(
                        key: ValueKey(_activeSlide),
                        index: _activeSlide,
                        isPremium: Provider.of<UserProvider>(context).isPremium,
                        activeTab: _activePropTab,
                        globalFont: _globalFont,
                        selectedBgIndex: _selectedBgIndex,
                        freeBgs: _freeBgs,
                        premiumBgs: const [],
                        customBg: _customBgs[_activeSlide],
                        fontSize: _fontSizes[_activeSlide],
                        fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor,
                        transition: _transitions[_activeSlide],
                        allTransitions: _allTransitions,
                        isImproving: _isImproving,
                        currentTextStyle: _currentTextStyle,
                        currentTextAlign: _currentTextAlign,
                        columnsCount: _columnsCount,
                        textStyles: _textStyles,
                        chartType: _chartTypes[_activeSlide],
                        chartData: _chartData[_activeSlide],
                        shapes: _shapes[_activeSlide],
                        imageWidth:    _imageWidths[_activeSlide],
                        imageHeight:   _imageHeights[_activeSlide],
                        imagePosition: _imagePositions[_activeSlide],
                        imageTextWrap: _imageTextWrap[_activeSlide],
                        hasImage: _customImages[_activeSlide] != null || _autoImages[_activeSlide] != null,
                        uploadsUsed: _imageUploadsUsed,
                        onTabChange: (t) => setState(() => _activePropTab = t),
                        onBgSelect: (i) => setState(() {
                          _selectedBgIndex = i;
                          _customBgs = List.filled(_presentation.slides.length, null);
                        }),
                        onBgUpload:    () => _uploadBg(_activeSlide),
                        onImageUpload: () => _uploadImage(_activeSlide),
                        onFontChange: (f) => setState(() {
                          _globalFont = f;
                          for (int i = 0; i < _fonts.length; i++) _fonts[i] = f;
                        }),
                        onFontSizeChange:      (v) => setState(() => _fontSizes[_activeSlide] = v),
                        onFontColorChange:     (c) => setState(() { _slideFontColors[_activeSlide] = c; _globalFontColor = c; }),
                        onTransitionChange:    (t) => setState(() => _transitions[_activeSlide] = t),
                        onTextStyleChange:     (s) => setState(() => _currentTextStyle = s),
                        onTextAlignChange:     (a) => setState(() => _currentTextAlign = a),
                        onColumnsChange:       (c) => setState(() => _columnsCount = c),
                        onChartTypeChange:     (t) => setState(() => _chartTypes[_activeSlide] = t),
                        onChartDataChange:     (d) => setState(() => _chartData[_activeSlide] = d),
                        onAddShape:            _addShape,
                        onRemoveShape:         _removeShape,
                        onImageWidthChange:    _updateImageWidth,
                        onImageHeightChange:   _updateImageHeight,
                        onImagePositionChange: _updateImagePosition,
                        onImageTextWrapChange: _updateImageTextWrap,
                        onImprove: () => _improveSlide(_activeSlide),
                      ),
              ),
            ),
          ]),
        ),
        const _ThinDivider(),
        _ControlBar(
          activeSlide: _activeSlide,
          totalSlides: _presentation.slides.length,
          propsPanelOpen: _propsPanelOpen,
          onToggleProps: () => setState(() => _propsPanelOpen = !_propsPanelOpen),
          onPrev:      () => setState(() { if (_activeSlide > 0) _activeSlide--; }),
          onNext:      () => setState(() { if (_activeSlide < _presentation.slides.length - 1) _activeSlide++; }),
          onAdd:       _addSlide,
          onDelete:    () => _deleteSlide(_activeSlide),
          onDuplicate: () => _duplicateSlide(_activeSlide),
          onTemplate:  _showTemplatePicker,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (final c in _titleCtrl) { c.dispose(); }
    for (final group in _contentCtrl) { for (final c in group) { c.dispose(); } }
    _scrollCtrl.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String title;
  final int slideCount, uploadsUsed;
  final VoidCallback onBack, onExport;

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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: _T.bgSurface,
      child: Row(children: [
        _IconBtn(Icons.arrow_back_ios_new_rounded, onBack, size: 15, tooltip: 'Назад'),
        const SizedBox(width: 10),

        // App logo
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_T.accent, _T.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),

        // Title + meta
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 1),
            Text('$slideCount слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 11)),
          ]),
        ),

        // Upload counter (only when > 0)
        if (uploadsUsed > 0) ...[
          _Pill(
            label: '🖼 $uploadsUsed/10',
            bg: uploadsUsed >= 10 ? const Color(0x1AFFD700) : _T.accentDim,
            fg: uploadsUsed >= 10 ? _T.gold : _T.accentLight,
            borderColor: uploadsUsed >= 10 ? const Color(0x33FFD700) : const Color(0x331DB954),
          ),
          const SizedBox(width: 8),
        ],

        // Export button
        GestureDetector(
          onTap: onExport,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Экспорт', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TEMPLATE SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _TemplateSheet extends StatelessWidget {
  final List<SlideTemplate> templates;
  final ValueChanged<SlideTemplate> onSelect;

  const _TemplateSheet({required this.templates, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      decoration: BoxDecoration(
        color: _T.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: _T.border)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const Text('Добавить шаблон слайда',
            style: TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.3,
            crossAxisSpacing: 10, mainAxisSpacing: 10,
          ),
          itemCount: templates.length,
          itemBuilder: (_, i) => _HoverCard(
            onTap: () => onSelect(templates[i]),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _T.bgCard, borderRadius: _T.r12,
                border: Border.all(color: _T.border),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)),
                  child: Icon(templates[i].icon, color: _T.accent, size: 22),
                ),
                const SizedBox(height: 8),
                Text(templates[i].name,
                    style: const TextStyle(color: _T.txtPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE NAVIGATOR
// ═══════════════════════════════════════════════════════════════════════════════
class _SlideNavigator extends StatelessWidget {
  final List<Slide> slides;
  final List<TextEditingController> titleControllers;
  final int activeIndex;
  final bool collapsed;
  final List<String?> customBgs;
  final List<Map<String, dynamic>> backgrounds;
  final int selectedBgIndex;
  final ValueChanged<int> onSelect, onDelete, onDuplicate, onMoveUp, onMoveDown;
  final VoidCallback onAdd, onToggleCollapse;

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

  Color _getColor(int i) {
    if (customBgs[i] != null) return Colors.grey.shade800;
    final bg = backgrounds[selectedBgIndex];
    if (bg['type'] == 'solid') return bg['color'] as Color;
    return (bg['colors'] as List<Color>).first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
        SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(children: [
              if (!collapsed)
                const Text('СЛАЙДЫ',
                    style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
              const Spacer(),
              _IconBtn(
                collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                onToggleCollapse, size: 15,
              ),
            ]),
          ),
        ),
        const _ThinDivider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            itemCount: slides.length,
            itemBuilder: (_, i) => _SlideThumbnail(
              index: i,
              title: titleControllers[i].text,
              isActive: i == activeIndex,
              collapsed: collapsed,
              bgColor: _getColor(i),
              onTap:       () => onSelect(i),
              onDelete:    slides.length > 1 ? () => onDelete(i) : null,
              onDuplicate: () => onDuplicate(i),
              onMoveUp:    i > 0 ? () => onMoveUp(i) : null,
              onMoveDown:  i < slides.length - 1 ? () => onMoveDown(i) : null,
            ),
          ),
        ),
        const _ThinDivider(),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            height: 40, alignment: Alignment.center,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  color: _T.accentDim,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _T.accent.withOpacity(0.35)),
                ),
                child: const Icon(Icons.add_rounded, color: _T.accent, size: 14),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 7),
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
  final bool isActive, collapsed;
  final Color bgColor;
  final VoidCallback onTap, onDuplicate;
  final VoidCallback? onDelete, onMoveUp, onMoveDown;

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
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _T.fast,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: widget.isActive ? _T.accentDim : hover ? _T.bgHover : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isActive ? _T.accent.withOpacity(0.4) : Colors.transparent,
              width: 1,
            ),
          ),
          child: widget.collapsed ? _collapsedView() : _expandedView(),
        ),
      ),
    );
  }

  Widget _collapsedView() => Center(
    child: Container(
      width: 30, height: 20,
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(3)),
      child: Center(
        child: Text('${widget.index + 1}', style: TextStyle(
          fontSize: 8,
          color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white38,
          fontWeight: FontWeight.w700,
        )),
      ),
    ),
  );

  Widget _expandedView() => Row(children: [
    Container(
      width: 50, height: 32,
      decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(4)),
      child: Center(
        child: Text('${widget.index + 1}', style: TextStyle(
          fontSize: 10,
          color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black38 : Colors.white30,
          fontWeight: FontWeight.w700,
        )),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: Text(
        widget.title.isEmpty ? 'Слайд ${widget.index + 1}' : widget.title,
        style: TextStyle(
          color: widget.isActive ? _T.txtPrimary : _T.txtSecondary,
          fontSize: 11,
          fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 2, overflow: TextOverflow.ellipsis,
      ),
    ),
    if (hover)
      PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 13,
        color: _T.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _T.border),
        ),
        icon: const Icon(Icons.more_vert_rounded, color: _T.txtSecondary, size: 13),
        onSelected: (v) {
          if (v == 'dup')  widget.onDuplicate();
          if (v == 'del')  widget.onDelete?.call();
          if (v == 'up')   widget.onMoveUp?.call();
          if (v == 'down') widget.onMoveDown?.call();
        },
        itemBuilder: (_) => [
          if (widget.onMoveUp != null)
            const PopupMenuItem(value: 'up',   height: 36, child: Row(children: [Icon(Icons.arrow_upward_rounded,   size: 14), SizedBox(width: 8), Text('Вверх')])),
          if (widget.onMoveDown != null)
            const PopupMenuItem(value: 'down', height: 36, child: Row(children: [Icon(Icons.arrow_downward_rounded, size: 14), SizedBox(width: 8), Text('Вниз')])),
          const PopupMenuItem(value: 'dup', height: 36, child: Row(children: [Icon(Icons.copy_rounded, size: 14), SizedBox(width: 8), Text('Дублировать')])),
          if (widget.onDelete != null)
            const PopupMenuItem(value: 'del', height: 36, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 14, color: _T.danger), SizedBox(width: 8), Text('Удалить', style: TextStyle(color: _T.danger))])),
        ],
      ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CANVAS
// ═══════════════════════════════════════════════════════════════════════════════
class _Canvas extends StatelessWidget {
  final int index, slideCount;
  final double fontSize;
  final Color fontColor;
  final TextEditingController titleCtrl;
  final List<TextEditingController> contentCtrl;
  final Decoration decoration;
  final String font, textStyle, textAlign;
  final int columnsCount;
  final String? image, chartType;
  final List<Map<String, dynamic>> chartData;
  final List<SlideShape> shapes;
  final double imageWidth, imageHeight;
  final String imagePosition, imageTextWrap;
  final VoidCallback onAddItem, onRemoveImage;
  final ValueChanged<int> onRemoveItem;
  final bool hasCustomImage;

  const _Canvas({
    super.key,
    required this.index,
    required this.titleCtrl,
    required this.contentCtrl,
    required this.decoration,
    required this.font,
    required this.fontSize,
    required this.fontColor,
    required this.slideCount,
    required this.textStyle,
    required this.textAlign,
    required this.columnsCount,
    this.image,
    this.chartType,
    required this.chartData,
    required this.shapes,
    required this.imageWidth,
    required this.imageHeight,
    required this.imagePosition,
    required this.imageTextWrap,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onRemoveImage,
    required this.hasCustomImage,
  });

  @override
  Widget build(BuildContext context) {
    final logo = context.watch<BrandKitProvider>().logoUrl;
    return Container(
      color: _T.bgBase,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('${index + 1} / $slideCount',
                  style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500)),
            ),
            LayoutBuilder(builder: (ctx, _) {
              final width  = (MediaQuery.of(context).size.width - 504).clamp(360.0, 900.0);
              final height = width * 9 / 16;
              return Container(
                width: width, height: height,
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  ...shapes.map((s) => Positioned(left: s.x, top: s.y,
                      child: Opacity(opacity: s.opacity, child: _buildShape(s)))),
                  Positioned(top: 10, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(28, 34, 28, 18), child: _buildContent(width, height)),
                  if (logo != null)
                    Positioned(bottom: 10, right: 12,
                      child: Opacity(opacity: 0.65,
                        child: ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: Image.network(logo, width: 48, height: 18, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox()))),
                    ),
                ]),
              );
            }),
            const SizedBox(height: 14),
            _buildContentEditor(MediaQuery.of(context).size.width),
          ]),
        ),
      ),
    );
  }

  Widget _buildShape(SlideShape s) {
    switch (s.type) {
      case 'circle':
        return Container(width: s.width, height: s.height,
            decoration: BoxDecoration(color: s.color, shape: BoxShape.circle));
      case 'square':
        return Container(width: s.width, height: s.height, color: s.color);
      case 'rectangle':
        return Container(width: s.width, height: s.height,
            decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(8)));
      case 'triangle':
        return CustomPaint(size: Size(s.width, s.height), painter: _TrianglePainter(color: s.color));
      case 'star':
        return CustomPaint(size: Size(s.width, s.height), painter: _StarPainter(color: s.color));
      default:
        return const SizedBox();
    }
  }

  Widget _buildContent(double width, double height) {
    if (chartType != null && chartData.isNotEmpty) return _buildChart(width, height);
    if (columnsCount > 1) return _buildColumns();

    final textCol = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildText(titleCtrl, true),
      const SizedBox(height: 10),
      ...contentCtrl.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.only(top: fontSize * 0.4, right: 7),
              child: Container(width: 5, height: 5,
                  decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle))),
          Expanded(child: _buildText(c, false)),
        ]),
      )),
    ]);

    if (image == null) return textCol;

    final imgW = width * imageWidth, imgH = height * imageHeight;
    final img = Stack(children: [
      ClipRRect(borderRadius: BorderRadius.circular(10),
        child: Image.network(image!, width: imgW, height: imgH, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox())),
      if (hasCustomImage)
        Positioned(top: 4, right: 4,
          child: GestureDetector(onTap: onRemoveImage,
            child: Container(width: 18, height: 18,
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 11)))),
    ]);

    switch (imagePosition) {
      case 'left':
        return Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [img, const SizedBox(width: 18), Expanded(child: textCol)]);
      case 'top':
        return Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [img, const SizedBox(height: 18), textCol]);
      case 'bottom':
        return Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [textCol, const SizedBox(height: 18), img]);
      default:
        return Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: textCol), const SizedBox(width: 18), img]);
    }
  }

  Widget _buildColumns() {
    return Row(children: List.generate(columnsCount, (c) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: c < columnsCount - 1 ? 12 : 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (c == 0 && titleCtrl.text.isNotEmpty) _buildText(titleCtrl, true),
          const SizedBox(height: 8),
          ...List.generate(2, (i) {
            final idx = c * 2 + i;
            return idx < contentCtrl.length
                ? Padding(padding: const EdgeInsets.only(bottom: 6), child: _buildText(contentCtrl[idx], false))
                : const SizedBox.shrink();
          }),
        ]),
      ),
    )));
  }

  Widget _buildChart(double w, double h) {
    if (chartData.isEmpty) {
      return Center(child: Container(
        width: w * 0.55, height: h * 0.55,
        decoration: BoxDecoration(color: _T.bgCard, borderRadius: _T.r12, border: Border.all(color: _T.border)),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.show_chart_rounded, color: _T.txtMuted, size: 40),
          SizedBox(height: 10),
          Text('Добавьте данные', style: TextStyle(color: _T.txtMuted, fontSize: 13)),
        ]),
      ));
    }

    final maxY = chartData.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b) * 1.2;

    switch (chartType) {
      case 'bar':
        return SizedBox(height: h * 0.7, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround, maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  return i >= 0 && i < chartData.length
                      ? Text(chartData[i]['label'] as String, style: const TextStyle(color: _T.txtSecondary, fontSize: 10))
                      : const Text('');
                })),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: _T.border, strokeWidth: 0.5)),
          barGroups: chartData.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [BarChartRodData(toY: e.value['value'] as double, color: _T.accent, width: 28,
                borderRadius: BorderRadius.circular(4))],
          )).toList(),
        )));

      case 'pie':
        final total = chartData.map((e) => e['value'] as double).reduce((a, b) => a + b);
        const colors = [_T.accent, _T.accentLight, Colors.orange, Colors.purple, Colors.cyan];
        return SizedBox(height: h * 0.7, child: PieChart(PieChartData(
          sections: chartData.asMap().entries.map((e) => PieChartSectionData(
            value: e.value['value'] as double,
            title: '${((e.value['value'] as double / total) * 100).toInt()}%',
            radius: 76,
            titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
            color: colors[e.key % colors.length],
          )).toList(),
          sectionsSpace: 2, centerSpaceRadius: 38,
        )));

      case 'line':
        return SizedBox(height: h * 0.7, child: LineChart(LineChartData(
          minX: 0, maxX: (chartData.length - 1).toDouble(), minY: 0, maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  return i >= 0 && i < chartData.length
                      ? Text(chartData[i]['label'] as String, style: const TextStyle(color: _T.txtSecondary, fontSize: 10))
                      : const Text('');
                })),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true,
              getDrawingHorizontalLine: (_) => FlLine(color: _T.border, strokeWidth: 0.5)),
          lineBarsData: [LineChartBarData(
            spots: chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'] as double)).toList(),
            isCurved: true, color: _T.accent, barWidth: 2.5,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: _T.accentDim),
          )],
        )));

      default:
        return const SizedBox();
    }
  }

  Widget _buildText(TextEditingController c, bool isTitle) {
    final preset = _getStyle();
    return TextField(
      controller: c,
      maxLines: null,
      cursorColor: _T.accent,
      textAlign: _getAlign(),
      style: TextStyle(
        fontFamily: font,
        fontSize: isTitle ? preset.fontSize * 1.5 : preset.fontSize,
        fontWeight: isTitle ? FontWeight.w800 : preset.fontWeight,
        color: fontColor,
        height: 1.3,
        letterSpacing: preset.letterSpacing,
        fontStyle: preset.isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      decoration: const InputDecoration(
        border: InputBorder.none, isCollapsed: true, contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContentEditor(double screenWidth) {
    final w = (screenWidth - 504).clamp(360.0, 900.0);
    return Container(
      width: w,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.bgSurface, borderRadius: _T.r14, border: Border.all(color: _T.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('СОДЕРЖИМОЕ',
            style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        _EditorField(controller: titleCtrl, hint: 'Заголовок...', bold: true),
        const SizedBox(height: 6),
        ...contentCtrl.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(children: [
            const Padding(padding: EdgeInsets.only(right: 7, top: 1),
                child: Icon(Icons.drag_indicator_rounded, color: _T.txtMuted, size: 13)),
            Expanded(child: _EditorField(controller: e.value, hint: 'Пункт ${e.key + 1}...')),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => onRemoveItem(e.key),
              child: const Padding(padding: EdgeInsets.all(4),
                  child: Icon(Icons.close_rounded, color: _T.txtMuted, size: 13)),
            ),
          ]),
        )),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: onAddItem,
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_rounded, color: _T.accent, size: 14),
            SizedBox(width: 4),
            Text('Добавить пункт', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  TextStylePreset _getStyle() {
    switch (textStyle) {
      case 'h1':    return const TextStylePreset(name: 'H1',    fontSize: 32, fontWeight: FontWeight.w800);
      case 'h2':    return const TextStylePreset(name: 'H2',    fontSize: 24, fontWeight: FontWeight.w700);
      case 'h3':    return const TextStylePreset(name: 'H3',    fontSize: 18, fontWeight: FontWeight.w600);
      case 'quote': return const TextStylePreset(name: 'Quote', fontSize: 16, fontWeight: FontWeight.w400, isItalic: true);
      default:      return const TextStylePreset(name: 'Body',  fontSize: 14, fontWeight: FontWeight.w400);
    }
  }

  TextAlign _getAlign() =>
      textAlign == 'center' ? TextAlign.center : textAlign == 'right' ? TextAlign.right : TextAlign.left;
}

/// Reusable styled editor text field.
class _EditorField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool bold;

  const _EditorField({required this.controller, required this.hint, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(
        color: _T.txtPrimary,
        fontSize: bold ? 14 : 13,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _T.txtMuted),
        filled: true, fillColor: _T.bgCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.accent, width: 1.5)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHAPE PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════
class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;
  const _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final cx = size.width / 2, cy = size.height / 2;
    final or = size.width / 2, ir = or * 0.4;
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? or : ir;
      final angle = i * (pi / 5) - pi / 2;
      final x = cx + r * cos(angle), y = cy + r * sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTIES PANEL
// ═══════════════════════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index;
  final bool isPremium;
  final String activeTab, globalFont, transition, currentTextStyle, currentTextAlign;
  final String? chartType, imagePosition, imageTextWrap;
  final int selectedBgIndex, columnsCount, uploadsUsed;
  final double fontSize;
  final Color fontColor;
  final double? imageWidth, imageHeight;
  final List<Map<String, dynamic>> freeBgs, premiumBgs, allTransitions;
  final String? customBg;
  final List<Map<String, dynamic>> chartData;
  final List<SlideShape> shapes;
  final Map<String, TextStylePreset> textStyles;
  final bool isImproving, hasImage;

  final ValueChanged<String> onTabChange, onFontChange, onTransitionChange,
      onTextStyleChange, onTextAlignChange, onImagePositionChange, onImageTextWrapChange;
  final ValueChanged<String?> onChartTypeChange;
  final ValueChanged<int> onBgSelect, onColumnsChange;
  final VoidCallback onBgUpload, onImageUpload, onImprove;
  final ValueChanged<double> onFontSizeChange, onImageWidthChange, onImageHeightChange;
  final ValueChanged<Color> onFontColorChange;
  final ValueChanged<List<Map<String, dynamic>>> onChartDataChange;
  final ValueChanged<String> onAddShape, onRemoveShape;

  const _PropertiesPanel({
    super.key,
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
    required this.currentTextStyle,
    required this.currentTextAlign,
    required this.columnsCount,
    required this.textStyles,
    this.chartType,
    required this.chartData,
    required this.shapes,
    this.imageWidth,
    this.imageHeight,
    this.imagePosition,
    this.imageTextWrap,
    required this.hasImage,
    required this.uploadsUsed,
    required this.onTabChange,
    required this.onBgSelect,
    required this.onBgUpload,
    required this.onImageUpload,
    required this.onFontChange,
    required this.onFontSizeChange,
    required this.onFontColorChange,
    required this.onTransitionChange,
    required this.onTextStyleChange,
    required this.onTextAlignChange,
    required this.onColumnsChange,
    required this.onChartTypeChange,
    required this.onChartDataChange,
    required this.onAddShape,
    required this.onRemoveShape,
    required this.onImageWidthChange,
    required this.onImageHeightChange,
    required this.onImagePositionChange,
    required this.onImageTextWrapChange,
    required this.onImprove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bgSurface,
      child: Column(children: [
        SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: Row(children: [
              _buildTab('design', 'Дизайн', Icons.palette_outlined),
              _buildTab('media',  'Медиа',  Icons.photo_outlined),
              _buildTab('shapes', 'Фигуры', Icons.category_outlined),
              _buildTab('charts', 'График', Icons.show_chart_rounded),
              _buildTab('ai',     'ИИ',     Icons.auto_awesome_outlined),
            ]),
          ),
        ),
        const _ThinDivider(),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: _buildContent(),
        )),
      ]),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    final active = id == activeTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChange(id),
        child: AnimatedContainer(
          duration: _T.fast,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? _T.accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? _T.accent.withOpacity(0.25) : Colors.transparent),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 11, color: active ? _T.accentLight : _T.txtMuted),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: active ? _T.accentLight : _T.txtMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (activeTab) {
      case 'media':  return _buildMediaTab();
      case 'shapes': return _buildShapesTab();
      case 'charts': return _buildChartsTab();
      case 'ai':     return _buildAiTab();
      default:       return _buildDesignTab();
    }
  }

  // ── Design ────────────────────────────────────────────────────────────────
  Widget _buildDesignTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PropSection('ШРИФТ', child: Column(children: [
        for (final f in ['Inter', 'Roboto', 'Playfair Display'])
          _FontChip(name: f, selected: globalFont == f, onTap: () => onFontChange(f)),
      ])),
      _PropSection('РАЗМЕР ТЕКСТА', child: _SliderRow(
        value: fontSize, min: 10, max: 28,
        label: '${fontSize.round()}px', onChanged: onFontSizeChange,
      )),
      _PropSection('ЦВЕТ ТЕКСТА', child: Wrap(spacing: 7, children: [
        for (final c in [Colors.white, Colors.black, _T.accent, Colors.blue, Colors.red, _T.gold])
          _ColorDot(color: c, selected: fontColor == c, onTap: () => onFontColorChange(c)),
      ])),
      _PropSection('ФОН СЛАЙДА', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 8, children: freeBgs.asMap().entries.map((e) {
          final isSelected = selectedBgIndex == e.key && customBg == null;
          return GestureDetector(
            onTap: () => onBgSelect(e.key),
            child: AnimatedContainer(
              duration: _T.fast,
              width: 40, height: 28,
              decoration: BoxDecoration(
                gradient: e.value['type'] == 'gradient'
                    ? LinearGradient(colors: e.value['colors'] as List<Color>) : null,
                color: e.value['type'] == 'solid' ? e.value['color'] as Color : null,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: isSelected ? _T.accent : _T.border, width: isSelected ? 2 : 1),
              ),
            ),
          );
        }).toList()),
        const SizedBox(height: 8),
        _UploadButton(label: 'Загрузить фон', onTap: onBgUpload),
      ])),
      _PropSection('ПЕРЕХОД', child: Wrap(spacing: 6, runSpacing: 6, children: allTransitions.map((t) {
        final isPremiumTrans = t['premium'] as bool;
        final isSelected     = transition == t['id'];
        return GestureDetector(
          onTap: isPremiumTrans ? null : () => onTransitionChange(t['id'] as String),
          child: AnimatedContainer(
            duration: _T.fast,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected ? _T.accentDim : _T.bgCard,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: isSelected ? _T.accent.withOpacity(0.35) : _T.border),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(t['label'] as String, style: TextStyle(fontSize: 11,
                  color: isPremiumTrans ? _T.txtMuted : isSelected ? _T.accentLight : _T.txtSecondary)),
              if (isPremiumTrans) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock_outline_rounded, size: 11, color: _T.txtMuted),
              ],
            ]),
          ),
        );
      }).toList())),
    ]);
  }

  // ── Media ─────────────────────────────────────────────────────────────────
  Widget _buildMediaTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PropSection('ИЗОБРАЖЕНИЕ', child: GestureDetector(
        onTap: onImageUpload,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: _T.bgCard, borderRadius: _T.r10,
            border: Border.all(color: hasImage ? _T.accent.withOpacity(0.3) : _T.border),
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(hasImage ? Icons.swap_horiz_rounded : Icons.add_photo_alternate_outlined,
                color: _T.accent, size: 22),
            const SizedBox(height: 4),
            Text(hasImage ? 'Заменить' : 'Загрузить',
                style: const TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w500)),
          ])),
        ),
      )),
      if (hasImage) ...[
        _PropSection('ШИРИНА', child: _SliderRow(
          value: imageWidth ?? 0.28, min: 0.1, max: 0.6,
          label: '${((imageWidth ?? 0.28) * 100).round()}%', onChanged: onImageWidthChange,
        )),
        _PropSection('ВЫСОТА', child: _SliderRow(
          value: imageHeight ?? 0.55, min: 0.1, max: 0.8,
          label: '${((imageHeight ?? 0.55) * 100).round()}%', onChanged: onImageHeightChange,
        )),
        _PropSection('ПОЗИЦИЯ', child: Row(children: [
          for (final pair in [
            ('left', Icons.format_align_left_rounded),
            ('right', Icons.format_align_right_rounded),
            ('top', Icons.vertical_align_top_rounded),
            ('bottom', Icons.vertical_align_bottom_rounded),
          ])
            Expanded(child: GestureDetector(
              onTap: () => onImagePositionChange(pair.$1),
              child: AnimatedContainer(
                duration: _T.fast,
                margin: const EdgeInsets.only(right: 4),
                height: 36,
                decoration: BoxDecoration(
                  color: imagePosition == pair.$1 ? _T.accentDim : _T.bgCard,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: imagePosition == pair.$1 ? _T.accent.withOpacity(0.4) : _T.border),
                ),
                child: Icon(pair.$2, size: 16, color: imagePosition == pair.$1 ? _T.accent : _T.txtSecondary),
              ),
            )),
        ])),
      ],
    ]);
  }

  // ── Shapes ────────────────────────────────────────────────────────────────
  Widget _buildShapesTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PropSection('ДОБАВИТЬ ФИГУРУ', child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final pair in [
          ('circle',    Icons.circle_outlined),
          ('square',    Icons.square_outlined),
          ('rectangle', Icons.rectangle_outlined),
          ('triangle',  Icons.change_history_rounded),
          ('star',      Icons.star_outline_rounded),
        ])
          GestureDetector(
            onTap: () => onAddShape(pair.$1),
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: _T.bgCard, borderRadius: _T.r10, border: Border.all(color: _T.border)),
              child: Icon(pair.$2, color: _T.accent, size: 24),
            ),
          ),
      ])),
      if (shapes.isNotEmpty)
        _PropSection('НА СЛАЙДЕ', child: Column(children: shapes.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: _T.bgCard, borderRadius: _T.r8, border: Border.all(color: _T.border)),
          child: Row(children: [
            Icon(_shapeIcon(s.type), color: s.color, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(s.type, style: const TextStyle(color: _T.txtPrimary, fontSize: 12))),
            GestureDetector(
              onTap: () => onRemoveShape(s.id),
              child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 14),
            ),
          ]),
        )).toList())),
    ]);
  }

  IconData _shapeIcon(String t) {
    switch (t) {
      case 'circle':    return Icons.circle_outlined;
      case 'square':    return Icons.square_outlined;
      case 'rectangle': return Icons.rectangle_outlined;
      case 'triangle':  return Icons.change_history_rounded;
      default:          return Icons.star_outline_rounded;
    }
  }

  // ── Charts ────────────────────────────────────────────────────────────────
  Widget _buildChartsTab() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PropSection('ТИП ГРАФИКА', child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _ChartTypeBtn(icon: Icons.bar_chart_rounded,  label: 'Столб.',  selected: chartType == 'bar',  onTap: () => onChartTypeChange('bar')),
        _ChartTypeBtn(icon: Icons.pie_chart_rounded,  label: 'Круг.',   selected: chartType == 'pie',  onTap: () => onChartTypeChange('pie')),
        _ChartTypeBtn(icon: Icons.show_chart_rounded, label: 'Линия',   selected: chartType == 'line', onTap: () => onChartTypeChange('line')),
        _ChartTypeBtn(icon: Icons.close_rounded,      label: 'Убрать',  selected: chartType == null,   onTap: () => onChartTypeChange(null)),
      ])),
      if (chartType != null)
        _PropSection('ДАННЫЕ', child: Column(children: [
          ...chartData.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(child: _EditorField(
                controller: TextEditingController(text: e.value['label'] as String),
                hint: 'Метка',
              )),
              const SizedBox(width: 8),
              SizedBox(width: 72, child: _EditorField(
                controller: TextEditingController(text: (e.value['value'] as double).toString()),
                hint: '0',
              )),
            ]),
          )),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              final d = List<Map<String, dynamic>>.from(chartData)..add({'label': 'Новый', 'value': 100.0});
              onChartDataChange(d);
            },
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: _T.accentDim, borderRadius: _T.r8),
              child: const Center(child: Text('+ Добавить',
                  style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600))),
            ),
          ),
        ])),
    ]);
  }

  // ── AI ────────────────────────────────────────────────────────────────────
  Widget _buildAiTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _T.accentDim, borderRadius: _T.r14,
        border: Border.all(color: _T.accent.withOpacity(0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          const Text('Улучшить текст',
              style: TextStyle(color: _T.txtPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        const Text('ИИ перепишет заголовок и пункты слайда, сделав их чище и убедительнее.',
            style: TextStyle(color: _T.txtSecondary, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: isImproving ? null : onImprove,
          child: AnimatedContainer(
            duration: _T.fast,
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isImproving ? null : const LinearGradient(colors: [_T.accent, _T.accentLight]),
              color: isImproving ? _T.bgCard : null,
              borderRadius: _T.r8,
            ),
            child: Center(child: isImproving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _T.accent))
                : const Text('Улучшить слайд',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _PropSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _PropSection(this.title, {required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _FontChip({required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _T.fast,
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _T.accentDim : _T.bgCard,
          borderRadius: _T.r8,
          border: Border.all(color: selected ? _T.accent.withOpacity(0.35) : _T.border),
        ),
        child: Row(children: [
          Expanded(child: Text(name, style: const TextStyle(color: _T.txtPrimary, fontSize: 13))),
          if (selected) const Icon(Icons.check_circle_rounded, color: _T.accent, size: 15),
        ]),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ColorDot({required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _T.fast,
        width: 26, height: 26,
        decoration: BoxDecoration(
          color: color, shape: BoxShape.circle,
          border: Border.all(color: selected ? _T.accent : _T.border, width: selected ? 2 : 1),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final double value, min, max;
  final String label;
  final ValueChanged<double> onChanged;
  const _SliderRow({required this.value, required this.min, required this.max, required this.label, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          activeTrackColor: _T.accent,
          inactiveTrackColor: _T.bgHover,
          thumbColor: _T.accentLight,
          overlayColor: _T.accentDim,
        ),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      )),
      const SizedBox(width: 4),
      SizedBox(width: 36,
          child: Text(label, style: const TextStyle(color: _T.txtSecondary, fontSize: 11), textAlign: TextAlign.right)),
    ]);
  }
}

class _UploadButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _UploadButton({required this.label, required this.onTap});

  @override
  State<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends State<_UploadButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _T.fast,
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: hover ? _T.bgHover : _T.bgCard,
            borderRadius: _T.r8,
            border: Border.all(color: hover ? _T.borderEm : _T.border),
          ),
          child: Center(child: Text(widget.label,
              style: TextStyle(color: hover ? _T.txtPrimary : _T.txtSecondary, fontSize: 12))),
        ),
      ),
    );
  }
}

class _ChartTypeBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChartTypeBtn({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        AnimatedContainer(
          duration: _T.fast,
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: selected ? _T.accentDim : _T.bgCard,
            borderRadius: _T.r8,
            border: Border.all(color: selected ? _T.accent.withOpacity(0.35) : _T.border),
          ),
          child: Icon(icon, color: selected ? _T.accent : _T.txtSecondary, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: selected ? _T.accent : _T.txtSecondary)),
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
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 28),
      decoration: BoxDecoration(
        color: _T.bgSurface, borderRadius: _T.r16, border: Border.all(color: _T.border),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(
          width: 36, height: 4,
          margin: const EdgeInsets.only(top: 12, bottom: 14),
          decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)),
        )),
        const Text('Экспорт', style: TextStyle(color: _T.txtPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const _ThinDivider(),
        ListTile(
          onTap: () {
            Navigator.pop(context);
            ExportService.exportToPPTX(context: context, presentation: presentation, isPremium: isPremium);
          },
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0x1FFF6B35), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.slideshow_rounded, color: Color(0xFFFF6B35), size: 20),
          ),
          title: const Text('PowerPoint', style: TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком',
              style: const TextStyle(color: _T.txtSecondary, fontSize: 12)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _T.txtMuted),
        ),
        ListTile(
          onTap: isPremium ? () {
            Navigator.pop(context);
            ExportService.exportToPDF(context: context, presentation: presentation, isPremium: isPremium);
          } : null,
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: isPremium ? const Color(0x1FFF3B30) : _T.bgCard, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.picture_as_pdf_rounded, color: isPremium ? _T.danger : _T.txtMuted, size: 20),
          ),
          title: Text('PDF', style: TextStyle(color: isPremium ? _T.txtPrimary : _T.txtMuted, fontWeight: FontWeight.w600)),
          subtitle: Text(isPremium ? 'Высокое качество' : 'Только Premium',
              style: const TextStyle(color: _T.txtSecondary, fontSize: 12)),
          trailing: !isPremium
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _T.gold.withOpacity(0.3)),
                  ),
                  child: const Text('Premium', style: TextStyle(color: _T.gold, fontSize: 10, fontWeight: FontWeight.w700)),
                )
              : const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _T.txtMuted),
        ),
        const SizedBox(height: 12),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONTROL BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _ControlBar extends StatelessWidget {
  final int activeSlide, totalSlides;
  final bool propsPanelOpen;
  final VoidCallback onToggleProps, onPrev, onNext, onAdd, onDelete, onDuplicate, onTemplate;

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
    required this.onTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: _T.bgSurface,
      child: Row(children: [
        _IconBtn(Icons.copy_rounded,           onDuplicate, tooltip: 'Дублировать'),
        _IconBtn(Icons.delete_outline_rounded, onDelete,    tooltip: 'Удалить', danger: true),
        _IconBtn(Icons.view_quilt_rounded,     onTemplate,  tooltip: 'Шаблоны'),
        const Spacer(),
        _IconBtn(Icons.arrow_back_rounded,    onPrev, disabled: activeSlide == 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('${activeSlide + 1} / $totalSlides',
              style: const TextStyle(color: _T.txtSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        _IconBtn(Icons.arrow_forward_rounded, onNext, disabled: activeSlide == totalSlides - 1),
        const Spacer(),
        _IconBtn(Icons.add_rounded, onAdd, tooltip: 'Новый слайд'),
        Container(width: 1, height: 20, color: _T.border, margin: const EdgeInsets.symmetric(horizontal: 6)),
        _IconBtn(
          propsPanelOpen ? Icons.view_sidebar_rounded : Icons.view_sidebar_outlined,
          onToggleProps,
          tooltip: propsPanelOpen ? 'Скрыть панель' : 'Показать панель',
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final bool danger, disabled;
  final Widget? child;

  const _IconBtn(
    this.icon,
    this.onTap, {
    this.size = 17,
    this.tooltip,
    this.danger = false,
    this.disabled = false,
    this.child,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.disabled
        ? _T.txtMuted
        : widget.danger
            ? _T.danger
            : hover
                ? _T.txtPrimary
                : _T.txtSecondary;

    return MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: GestureDetector(
          onTap: widget.disabled ? null : widget.onTap,
          child: AnimatedContainer(
            duration: _T.fast,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: hover && !widget.disabled ? _T.bgHover : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: widget.child ?? Icon(widget.icon, size: widget.size, color: color),
          ),
        ),
      ),
    );
  }
}