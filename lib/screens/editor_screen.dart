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
  static const success = Color(0xFF1DB954);
  static const gold = Color(0xFFFFD700);
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
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
  SlideShape copyWith({double? x, double? y, double? width, double? height, Color? color, double? opacity}) {
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
  const SlideTemplate({required this.id, required this.name, required this.icon, required this.build});
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
  int _activeSlide = 0, _selectedBgIndex = 0, _imageUploadsUsed = 0;
  String _globalFont = 'Inter', _activePropTab = 'design', _currentTextStyle = 'body', _currentTextAlign = 'left';
  bool _navCollapsed = false, _propsPanelOpen = true, _isImproving = false;
  int _columnsCount = 1;
  Color _globalFontColor = Colors.white;
  late List<Color?> _slideFontColors;
  late List<String> _transitions;
  late List<String?> _chartTypes;
  late List<List<Map<String, dynamic>>> _chartData;
  late List<List<SlideShape>> _shapes;
  late List<double?> _imageWidths, _imageHeights;
  late List<String?> _imagePositions, _imageTextWrap;
  final Map<int, String?> _autoImages = {};
  final _scrollCtrl = ScrollController();
  final _canvasKey = GlobalKey();

  final List<SlideTemplate> _slideTemplates = [
    const SlideTemplate(id: 'cover_left', name: 'Обложка слева', icon: Icons.format_align_left_rounded, build: _buildCoverLeft),
    const SlideTemplate(id: 'cover_center', name: 'Обложка центр', icon: Icons.format_align_center_rounded, build: _buildCoverCenter),
    const SlideTemplate(id: 'two_columns', name: 'Две колонки', icon: Icons.view_column_rounded, build: _buildTwoColumns),
    const SlideTemplate(id: 'image_text', name: 'Изображение и текст', icon: Icons.image_rounded, build: _buildImageText),
    const SlideTemplate(id: 'quote', name: 'Цитата', icon: Icons.format_quote_rounded, build: _buildQuote),
  ];

  final List<Map<String, dynamic>> _freeBgs = [
    {'type': 'solid', 'color': const Color(0xFF1A1A1A), 'label': 'Тёмный'},
    {'type': 'solid', 'color': Colors.white, 'label': 'Белый'},
    {'type': 'gradient', 'colors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)], 'label': 'Midnight'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)], 'label': 'Фиолет'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)], 'label': 'Голубой'},
  ];

  static const List<Map<String, dynamic>> _allTransitions = [
    {'id': 'none', 'label': 'Нет', 'premium': false},
    {'id': 'fade', 'label': 'Затухание', 'premium': false},
    {'id': 'slide', 'label': 'Слайд', 'premium': true},
    {'id': 'zoom', 'label': 'Зум', 'premium': true},
  ];

  final Map<String, TextStylePreset> _textStyles = {
    'h1': TextStylePreset(name: 'Заголовок 1', fontSize: 32, fontWeight: FontWeight.w800),
    'h2': TextStylePreset(name: 'Заголовок 2', fontSize: 24, fontWeight: FontWeight.w700),
    'h3': TextStylePreset(name: 'Заголовок 3', fontSize: 18, fontWeight: FontWeight.w600),
    'body': TextStylePreset(name: 'Основной текст', fontSize: 14, fontWeight: FontWeight.w400),
    'quote': TextStylePreset(name: 'Цитата', fontSize: 16, fontWeight: FontWeight.w400, isItalic: true),
  };

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    int len = _presentation.slides.length;
    _customImages = List.filled(len, null);
    _customBgs = List.filled(len, null);
    _fontSizes = List.filled(len, 14.0);
    _fonts = List.filled(len, 'Inter');
    _slideFontColors = List.filled(len, Colors.white);
    _transitions = List.filled(len, 'none');
    _chartTypes = List.filled(len, null);
    _chartData = List.filled(len, []);
    _shapes = List.generate(len, (_) => []);
    _imageWidths = List.filled(len, 0.28);
    _imageHeights = List.filled(len, 0.55);
    _imagePositions = List.filled(len, 'right');
    _imageTextWrap = List.filled(len, 'around');
    _initControllers();
    _loadAutoImages();
    _countUploads();
  }

  void _initControllers() {
    _titleCtrl = _presentation.slides.map((s) => TextEditingController(text: s.title)).toList();
    _contentCtrl = _presentation.slides.map((s) => s.content.map((c) => TextEditingController(text: c)).toList()).toList();
  }

  void _countUploads() => _imageUploadsUsed = _customImages.where((i) => i != null).length;

  Future<void> _loadAutoImages() async {
    for (int i = 0; i < _presentation.slides.length; i++) {
      String q = _titleCtrl[i].text.isNotEmpty ? _titleCtrl[i].text : _presentation.title;
      _autoImages[i] = await ImageService.searchImage(q);
      if (mounted) setState(() {});
    }
  }

  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title = _titleCtrl[i].text;
      _presentation.slides[i].content = _contentCtrl[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    setState(() {
      int idx = _activeSlide + 1;
      _presentation.slides.insert(idx, Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleCtrl.insert(idx, TextEditingController(text: 'Новый слайд'));
      _contentCtrl.insert(idx, [TextEditingController(text: 'Введите текст')]);
      _customImages.insert(idx, null);
      _customBgs.insert(idx, null);
      _fontSizes.insert(idx, 14.0);
      _fonts.insert(idx, _globalFont);
      _slideFontColors.insert(idx, Colors.white);
      _transitions.insert(idx, 'none');
      _chartTypes.insert(idx, null);
      _chartData.insert(idx, []);
      _shapes.insert(idx, []);
      _imageWidths.insert(idx, 0.28);
      _imageHeights.insert(idx, 0.55);
      _imagePositions.insert(idx, 'right');
      _imageTextWrap.insert(idx, 'around');
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
      _chartTypes.removeAt(i);
      _chartData.removeAt(i);
      _shapes.removeAt(i);
      _imageWidths.removeAt(i);
      _imageHeights.removeAt(i);
      _imagePositions.removeAt(i);
      _imageTextWrap.removeAt(i);
      if (_activeSlide >= _presentation.slides.length) _activeSlide = _presentation.slides.length - 1;
    });
    _countUploads();
  }

  void _duplicateSlide(int i) {
    setState(() {
      int idx = i + 1;
      _presentation.slides.insert(idx, Slide(title: _presentation.slides[i].title, content: List.from(_presentation.slides[i].content)));
      _titleCtrl.insert(idx, TextEditingController(text: _titleCtrl[i].text));
      _contentCtrl.insert(idx, _contentCtrl[i].map((c) => TextEditingController(text: c.text)).toList());
      _customImages.insert(idx, _customImages[i]);
      _customBgs.insert(idx, _customBgs[i]);
      _fontSizes.insert(idx, _fontSizes[i]);
      _fonts.insert(idx, _fonts[i]);
      _slideFontColors.insert(idx, _slideFontColors[i]);
      _transitions.insert(idx, _transitions[i]);
      _chartTypes.insert(idx, _chartTypes[i]);
      _chartData.insert(idx, List.from(_chartData[i]));
      _shapes.insert(idx, _shapes[i].map((s) => s.copyWith()).toList());
      _imageWidths.insert(idx, _imageWidths[i]);
      _imageHeights.insert(idx, _imageHeights[i]);
      _imagePositions.insert(idx, _imagePositions[i]);
      _imageTextWrap.insert(idx, _imageTextWrap[i]);
      _activeSlide = idx;
    });
    _countUploads();
  }

  void _addContentItem(int i) => setState(() => _contentCtrl[i].add(TextEditingController(text: 'Новый пункт')));
  void _removeContentItem(int slide, int item) {
    if (_contentCtrl[slide].length <= 1) return;
    setState(() {
      _contentCtrl[slide][item].dispose();
      _contentCtrl[slide].removeAt(item);
    });
  }

  void _addShape(String type) {
    setState(() {
      _shapes[_activeSlide].add(SlideShape(id: DateTime.now().toString(), type: type, x: 100, y: 100, width: 80, height: 80, color: _globalFontColor, opacity: 0.8));
    });
  }

  void _removeShape(String id) {
    setState(() {
      _shapes[_activeSlide].removeWhere((s) => s.id == id);
    });
  }

  void _updateImageWidth(double w) => setState(() => _imageWidths[_activeSlide] = w);
  void _updateImageHeight(double h) => setState(() => _imageHeights[_activeSlide] = h);
  void _updateImagePosition(String p) => setState(() => _imagePositions[_activeSlide] = p);
  void _updateImageTextWrap(String w) => setState(() => _imageTextWrap[_activeSlide] = w);

  static Slide _buildCoverLeft() => Slide(title: 'Заголовок', content: ['Подзаголовок']);
  static Slide _buildCoverCenter() => Slide(title: 'Заголовок', content: ['Подзаголовок']);
  static Slide _buildTwoColumns() => Slide(title: 'Заголовок', content: ['Текст колонки 1', 'Текст колонки 2']);
  static Slide _buildImageText() => Slide(title: 'Заголовок', content: ['Описание изображения']);
  static Slide _buildQuote() => Slide(title: 'Цитата', content: ['Важная цитата']);

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Добавить шаблон слайда', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: _slideTemplates.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                int idx = _activeSlide + 1;
                Slide newSlide = _slideTemplates[i].build();
                setState(() {
                  _presentation.slides.insert(idx, newSlide);
                  _titleCtrl.insert(idx, TextEditingController(text: newSlide.title));
                  _contentCtrl.insert(idx, newSlide.content.map((c) => TextEditingController(text: c)).toList());
                  _customImages.insert(idx, null);
                  _customBgs.insert(idx, null);
                  _fontSizes.insert(idx, 14.0);
                  _fonts.insert(idx, _globalFont);
                  _slideFontColors.insert(idx, Colors.white);
                  _transitions.insert(idx, 'none');
                  _chartTypes.insert(idx, null);
                  _chartData.insert(idx, []);
                  _shapes.insert(idx, []);
                  _imageWidths.insert(idx, 0.28);
                  _imageHeights.insert(idx, 0.55);
                  _imagePositions.insert(idx, 'right');
                  _imageTextWrap.insert(idx, 'around');
                  _activeSlide = idx;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2A2A2A))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_slideTemplates[i].icon, color: const Color(0xFF1DB954), size: 28),
                  const SizedBox(height: 8),
                  Text(_slideTemplates[i].name, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _improveSlide(int index) async {
    setState(() => _isImproving = true);
    try {
      String t = await AiImproveService.improveText(_titleCtrl[index].text);
      List<String> cs = [];
      for (var c in _contentCtrl[index]) cs.add(await AiImproveService.improveText(c.text));
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

  Future<void> _uploadImage(int idx) async {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    if (!p) { _toast('Premium функция', warning: true); return; }
    var input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      var file = input.files?.first;
      if (file == null) return;
      var reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() {
        _customImages[idx] = reader.result as String;
        _imageWidths[idx] = 0.28;
        _imageHeights[idx] = 0.55;
        _imagePositions[idx] = 'right';
      }));
    });
  }

  Future<void> _uploadBg(int idx) async {
    var input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      var file = input.files?.first;
      if (file == null) return;
      var reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoad.listen((_) => setState(() => _customBgs[idx] = reader.result as String));
    });
  }

  Decoration _slideDeco(int idx) {
    if (_customBgs[idx] != null) return BoxDecoration(image: DecorationImage(image: NetworkImage(_customBgs[idx]!), fit: BoxFit.cover), borderRadius: _T.r12);
    var bg = _freeBgs[_selectedBgIndex.clamp(0, _freeBgs.length - 1)];
    if (bg['type'] == 'gradient') return BoxDecoration(gradient: LinearGradient(colors: bg['colors'] as List<Color>), borderRadius: _T.r12);
    return BoxDecoration(color: bg['color'] as Color, borderRadius: _T.r12);
  }

  void _toast(String msg, {bool success = false, bool error = false, bool warning = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: success ? _T.success : error ? _T.danger : warning ? _T.gold : _T.bgCard,
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24), duration: const Duration(seconds: 2),
    ));
  }

  void _export() {
    _saveAll();
    _showSheet(_ExportSheet(isPremium: Provider.of<UserProvider>(context, listen: false).isPremium, presentation: _presentation));
  }

  void _showSheet(Widget child) => showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => child);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bgBase,
      body: Column(children: [
        _TopBar(title: _presentation.title, slideCount: _presentation.slides.length, uploadsUsed: _imageUploadsUsed, onBack: () { _saveAll(); Navigator.pop(context); }, onExport: _export),
        const Divider(color: _T.border, height: 1),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(duration: _T.normal, width: _navCollapsed ? 48 : 200, child: _SlideNavigator(
              slides: _presentation.slides, titleControllers: _titleCtrl, activeIndex: _activeSlide, collapsed: _navCollapsed,
              customBgs: _customBgs, backgrounds: _freeBgs, selectedBgIndex: _selectedBgIndex,
              onSelect: (i) => setState(() => _activeSlide = i), onAdd: _addSlide, onDelete: _deleteSlide, onDuplicate: _duplicateSlide,
              onMoveUp: (i) => setState(() { var tmp = _presentation.slides[i]; _presentation.slides[i] = _presentation.slides[i-1]; _presentation.slides[i-1] = tmp; _activeSlide = i-1; }),
              onMoveDown: (i) => setState(() { var tmp = _presentation.slides[i]; _presentation.slides[i] = _presentation.slides[i+1]; _presentation.slides[i+1] = tmp; _activeSlide = i+1; }),
              onToggleCollapse: () => setState(() => _navCollapsed = !_navCollapsed),
            )),
            const VerticalDivider(color: _T.border, width: 1),
            Expanded(child: _Canvas(
              index: _activeSlide, titleCtrl: _titleCtrl[_activeSlide], contentCtrl: _contentCtrl[_activeSlide],
              decoration: _slideDeco(_activeSlide), font: _fonts[_activeSlide] != 'Inter' ? _fonts[_activeSlide] : _globalFont,
              fontSize: _fontSizes[_activeSlide], fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor, slideCount: _presentation.slides.length,
              image: _customImages[_activeSlide] ?? _autoImages[_activeSlide], hasCustomImage: _customImages[_activeSlide] != null,
              onRemoveImage: () => setState(() { _customImages[_activeSlide] = null; _countUploads(); }),
              textStyle: _currentTextStyle, textAlign: _currentTextAlign, columnsCount: _columnsCount,
              chartType: _chartTypes[_activeSlide], chartData: _chartData[_activeSlide], shapes: _shapes[_activeSlide],
              imageWidth: _imageWidths[_activeSlide] ?? 0.28, imageHeight: _imageHeights[_activeSlide] ?? 0.55,
              imagePosition: _imagePositions[_activeSlide] ?? 'right', imageTextWrap: _imageTextWrap[_activeSlide] ?? 'around',
              onAddItem: () => _addContentItem(_activeSlide), onRemoveItem: (i) => _removeContentItem(_activeSlide, i),
            )),
            const VerticalDivider(color: _T.border, width: 1),
            AnimatedContainer(duration: _T.normal, width: _propsPanelOpen ? 280 : 0, child: _propsPanelOpen ? _PropertiesPanel(
              index: _activeSlide, isPremium: Provider.of<UserProvider>(context).isPremium, activeTab: _activePropTab,
              globalFont: _globalFont, selectedBgIndex: _selectedBgIndex, freeBgs: _freeBgs, premiumBgs: const [], customBg: _customBgs[_activeSlide],
              fontSize: _fontSizes[_activeSlide], fontColor: _slideFontColors[_activeSlide] ?? _globalFontColor, transition: _transitions[_activeSlide],
              allTransitions: _allTransitions, isImproving: _isImproving, currentTextStyle: _currentTextStyle, currentTextAlign: _currentTextAlign,
              columnsCount: _columnsCount, textStyles: _textStyles, chartType: _chartTypes[_activeSlide], chartData: _chartData[_activeSlide],
              shapes: _shapes[_activeSlide], imageWidth: _imageWidths[_activeSlide], imageHeight: _imageHeights[_activeSlide],
              imagePosition: _imagePositions[_activeSlide], imageTextWrap: _imageTextWrap[_activeSlide], hasImage: _customImages[_activeSlide] != null || _autoImages[_activeSlide] != null,
              onTabChange: (t) => setState(() => _activePropTab = t), onBgSelect: (i) => setState(() => { _selectedBgIndex = i; _customBgs = List.filled(_presentation.slides.length, null); }),
              onBgUpload: () => _uploadBg(_activeSlide), onImageUpload: () => _uploadImage(_activeSlide),
              onFontChange: (f) => setState(() => { _globalFont = f; for (int i = 0; i < _fonts.length; i++) _fonts[i] = f; }),
              onFontSizeChange: (v) => setState(() => _fontSizes[_activeSlide] = v), onFontColorChange: (c) => setState(() { _slideFontColors[_activeSlide] = c; _globalFontColor = c; }),
              onTransitionChange: (t) => setState(() => _transitions[_activeSlide] = t), onTextStyleChange: (s) => setState(() => _currentTextStyle = s),
              onTextAlignChange: (a) => setState(() => _currentTextAlign = a), onColumnsChange: (c) => setState(() => _columnsCount = c),
              onChartTypeChange: (t) => setState(() => _chartTypes[_activeSlide] = t), onChartDataChange: (d) => setState(() => _chartData[_activeSlide] = d),
              onAddShape: _addShape, onImageWidthChange: _updateImageWidth, onImageHeightChange: _updateImageHeight,
              onImagePositionChange: _updateImagePosition, onImageTextWrapChange: _updateImageTextWrap, uploadsUsed: _imageUploadsUsed,
            ) : const SizedBox.shrink()),
          ]),
        ),
        const Divider(color: _T.border, height: 1),
        _ControlBar(activeSlide: _activeSlide, totalSlides: _presentation.slides.length, propsPanelOpen: _propsPanelOpen,
          onToggleProps: () => setState(() => _propsPanelOpen = !_propsPanelOpen), onPrev: () => setState(() { if (_activeSlide > 0) _activeSlide--; }),
          onNext: () => setState(() { if (_activeSlide < _presentation.slides.length - 1) _activeSlide++; }), onAdd: _addSlide,
          onDelete: () => _deleteSlide(_activeSlide), onDuplicate: () => _duplicateSlide(_activeSlide), onTemplate: _showTemplatePicker,
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
  final String title; final int slideCount, uploadsUsed; final VoidCallback onBack, onExport;
  const _TopBar({required this.title, required this.slideCount, required this.uploadsUsed, required this.onBack, required this.onExport});
  @override
  Widget build(BuildContext context) => Container(height: 52, color: _T.bgSurface, padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(children: [
      _IconBtn(Icons.arrow_back_ios_rounded, onBack, size: 17), const SizedBox(width: 8),
      Container(width: 26, height: 26, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14)),
      const SizedBox(width: 10), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
        Text('$slideCount слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 10)),
      ])),
      if (uploadsUsed > 0) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.12) : _T.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: uploadsUsed >= 10 ? _T.gold.withOpacity(0.3) : _T.accent.withOpacity(0.3))),
        child: Text('🖼 $uploadsUsed/10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: uploadsUsed >= 10 ? _T.gold : _T.accentLight))),
      _IconBtn(Icons.ios_share_rounded, onExport, tooltip: 'Экспорт', child: const Text('Экспорт', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SLIDE NAVIGATOR
// ═══════════════════════════════════════════════════════════════════════════════
class _SlideNavigator extends StatelessWidget {
  final List<Slide> slides; final List<TextEditingController> titleControllers; final int activeIndex; final bool collapsed;
  final List<String?> customBgs; final List<Map<String, dynamic>> backgrounds; final int selectedBgIndex;
  final ValueChanged<int> onSelect, onDelete, onDuplicate, onMoveUp, onMoveDown; final VoidCallback onAdd, onToggleCollapse;
  const _SlideNavigator({required this.slides, required this.titleControllers, required this.activeIndex, required this.collapsed,
    required this.customBgs, required this.backgrounds, required this.selectedBgIndex, required this.onSelect, required this.onAdd,
    required this.onDelete, required this.onDuplicate, required this.onMoveUp, required this.onMoveDown, required this.onToggleCollapse});
  Color _getColor(int i) { if (customBgs[i] != null) return Colors.grey.shade800; var bg = backgrounds[selectedBgIndex];
    if (bg['type'] == 'solid') return bg['color'] as Color; return (bg['colors'] as List<Color>).first; }
  @override Widget build(BuildContext context) => Container(color: _T.bgSurface, child: Column(children: [
    Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
      if (!collapsed) const Text('СЛАЙДЫ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)), const Spacer(),
      _IconBtn(collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, onToggleCollapse, size: 16),
    ])),
    const Divider(color: _T.border, height: 1),
    Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6), itemCount: slides.length,
      itemBuilder: (_, i) => _buildThumbnail(i))),
    const Divider(color: _T.border, height: 1),
    GestureDetector(onTap: onAdd, child: Container(height: 44, alignment: Alignment.center, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 20, height: 20, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(5), border: Border.all(color: _T.accent.withOpacity(0.4))), child: const Icon(Icons.add_rounded, color: _T.accent, size: 14)),
      if (!collapsed) const SizedBox(width: 8), if (!collapsed) const Text('Слайд', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600)),
    ]))),
  ]));
  Widget _buildThumbnail(int i) => StatefulBuilder(builder: (ctx, setState) {
    bool hover = false;
    return MouseRegion(
      cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => hover = true), onExit: (_) => setState(() => hover = false),
      child: GestureDetector(onTap: () => onSelect(i), child: AnimatedContainer(duration: _T.fast, margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: i == activeIndex ? _T.accent.withOpacity(0.12) : hover ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: i == activeIndex ? _T.accent.withOpacity(0.5) : Colors.transparent, width: 1.5)),
        child: collapsed ? _collapsedView(i) : _expandedView(i, hover),
      )),
    );
  });
  Widget _collapsedView(int i) => Column(children: [Container(width: 30, height: 20, decoration: BoxDecoration(color: _getColor(i), borderRadius: BorderRadius.circular(3)),
    child: Center(child: Text('${i+1}', style: TextStyle(fontSize: 8, color: _getColor(i).computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.w700))))]);
  Widget _expandedView(int i, bool hover) => Row(children: [
    Container(width: 52, height: 34, decoration: BoxDecoration(color: _getColor(i), borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${i+1}', style: TextStyle(fontSize: 10, color: _getColor(i).computeLuminance() > 0.5 ? Colors.black54 : Colors.white38, fontWeight: FontWeight.w700)))),
    const SizedBox(width: 8), Expanded(child: Text(titleControllers[i].text.isEmpty ? 'Слайд ${i+1}' : titleControllers[i].text,
      style: TextStyle(color: i == activeIndex ? _T.txtPrimary : _T.txtSecondary, fontSize: 11, fontWeight: i == activeIndex ? FontWeight.w600 : FontWeight.w400), maxLines: 2, overflow: TextOverflow.ellipsis)),
    if (hover) PopupMenuButton<String>(
      iconSize: 14, color: _T.bgCard, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _T.border)),
      icon: const Icon(Icons.more_vert_rounded, color: _T.txtSecondary, size: 14), onSelected: (v) {
        if (v == 'dup') onDuplicate(i);
        if (v == 'del') onDelete(i);
        if (v == 'up') onMoveUp(i);
        if (v == 'down') onMoveDown(i);
      },
      itemBuilder: (_) => [
        if (i > 0) const PopupMenuItem(value: 'up', height: 36, child: Row(children: [Icon(Icons.arrow_upward_rounded, size: 14), SizedBox(width: 8), Text('Вверх')])),
        if (i < slides.length - 1) const PopupMenuItem(value: 'down', height: 36, child: Row(children: [Icon(Icons.arrow_downward_rounded, size: 14), SizedBox(width: 8), Text('Вниз')])),
        const PopupMenuItem(value: 'dup', height: 36, child: Row(children: [Icon(Icons.copy_rounded, size: 14), SizedBox(width: 8), Text('Дублировать')])),
        if (slides.length > 1) const PopupMenuItem(value: 'del', height: 36, child: Row(children: [Icon(Icons.delete_outline_rounded, size: 14, color: _T.danger), SizedBox(width: 8), Text('Удалить', style: TextStyle(color: _T.danger))])),
      ],
    ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CANVAS
// ═══════════════════════════════════════════════════════════════════════════════
class _Canvas extends StatelessWidget {
  final int index, slideCount; final double fontSize; final Color fontColor;
  final TextEditingController titleCtrl; final List<TextEditingController> contentCtrl;
  final Decoration decoration; final String font, textStyle, textAlign; final int columnsCount;
  final String? image, chartType; final List<Map<String, dynamic>> chartData; final List<SlideShape> shapes;
  final double imageWidth, imageHeight; final String imagePosition, imageTextWrap;
  final VoidCallback onAddItem, onRemoveImage; final ValueChanged<int> onRemoveItem; final bool hasCustomImage;
  const _Canvas({super.key, required this.index, required this.titleCtrl, required this.contentCtrl, required this.decoration,
    required this.font, required this.fontSize, required this.fontColor, required this.slideCount, required this.textStyle,
    required this.textAlign, required this.columnsCount, this.image, this.chartType, required this.chartData, required this.shapes,
    required this.imageWidth, required this.imageHeight, required this.imagePosition, required this.imageTextWrap,
    required this.onAddItem, required this.onRemoveItem, required this.onRemoveImage, required this.hasCustomImage});

  @override
  Widget build(BuildContext context) {
    final logo = context.watch<BrandKitProvider>().logoUrl;
    return Container(color: _T.bgBase, child: Center(
      child: SingleChildScrollView(padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(children: [
          Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${index + 1} / $slideCount', style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500))),
          LayoutBuilder(builder: (ctx, _) {
            double width = (MediaQuery.of(context).size.width - 520).clamp(360.0, 900.0);
            double height = width * 9 / 16;
            return Container(width: width, height: height, decoration: decoration, clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                ...shapes.map((s) => Positioned(left: s.x, top: s.y, child: Opacity(opacity: s.opacity, child: _buildShape(s)))),
                Positioned(top: 12, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)), child: Text('${index + 1}', style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)))),
                Padding(padding: const EdgeInsets.fromLTRB(28, 36, 28, 20), child: _buildContent(width, height)),
                if (logo != null) Positioned(bottom: 10, right: 14, child: Opacity(opacity: 0.7, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(logo, width: 50, height: 20, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox())))),
              ]),
            );
          }),
          const SizedBox(height: 16),
          _buildContentEditor(MediaQuery.of(context).size.width),
        ]),
      ),
    ));
  }

  Widget _buildShape(SlideShape s) {
    switch (s.type) {
      case 'circle': return Container(width: s.width, height: s.height, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]));
      case 'square': return Container(width: s.width, height: s.height, decoration: BoxDecoration(color: s.color, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]));
      case 'rectangle': return Container(width: s.width, height: s.height, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]));
      case 'triangle': return CustomPaint(size: Size(s.width, s.height), painter: _TrianglePainter(color: s.color));
      case 'star': return CustomPaint(size: Size(s.width, s.height), painter: _StarPainter(color: s.color));
      default: return const SizedBox();
    }
  }

  Widget _buildContent(double width, double height) {
    if (chartType != null && chartData.isNotEmpty) return _buildChart(width, height);
    if (columnsCount > 1) return _buildColumns(width);
    Widget textCol = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildText(titleCtrl, true), const SizedBox(height: 12),
      ...contentCtrl.map((c) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: EdgeInsets.only(top: fontSize * 0.38, right: 7), child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle))),
        Expanded(child: _buildText(c, false)),
      ]))),
    ]);
    if (image == null) return textCol;
    double imgW = width * imageWidth, imgH = height * imageHeight;
    Widget img = Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(image!, width: imgW, height: imgH, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())), if (hasCustomImage) Positioned(top: 4, right: 4, child: GestureDetector(onTap: onRemoveImage, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.close_rounded, color: Colors.white, size: 12))))]);
    switch (imagePosition) {
      case 'left': return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [img, const SizedBox(width: 20), Expanded(child: textCol)]);
      case 'top': return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [img, const SizedBox(height: 20), textCol]);
      case 'bottom': return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [textCol, const SizedBox(height: 20), img]);
      default: return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: textCol), const SizedBox(width: 20), img]);
    }
  }

  Widget _buildColumns(double w) => Row(children: List.generate(columnsCount, (c) => Expanded(child: Padding(padding: EdgeInsets.only(right: c < columnsCount-1 ? 12 : 0), child: Column(children: [
    if (c == 0 && titleCtrl.text.isNotEmpty) _buildText(titleCtrl, true),
    const SizedBox(height: 8), ...contentCtrl.skip(c*2).take(2).map((ctrl) => _buildText(ctrl, false)),
  ])))));
  
  Widget _buildChart(double w, double h) {
    if (chartData.isEmpty) return Center(child: Container(width: w*0.6, height: h*0.6, decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.show_chart_rounded, color: _T.txtMuted, size: 48), SizedBox(height: 12), Text('Добавьте данные', style: TextStyle(color: _T.txtMuted))])));
    switch (chartType) {
      case 'bar': return _BarChart(data: chartData, height: h);
      case 'pie': return _PieChart(data: chartData, height: h);
      case 'line': return _LineChart(data: chartData, height: h);
      default: return const SizedBox();
    }
  }

  Widget _buildText(TextEditingController c, bool isTitle) {
    var preset = _getStyle();
    return EditableText(controller: c, focusNode: FocusNode(), style: GoogleFonts.inter(
      fontSize: isTitle ? preset.fontSize * 1.5 : preset.fontSize,
      fontWeight: isTitle ? FontWeight.w800 : preset.fontWeight,
      color: fontColor, height: 1.3, letterSpacing: preset.letterSpacing,
      fontStyle: preset.isItalic ? FontStyle.italic : FontStyle.normal,
    ), cursorColor: _T.accent, backgroundCursorColor: _T.accent, maxLines: null, textAlign: _getAlign());
  }

  Widget _buildContentEditor(double screenWidth) {
    double w = (screenWidth - 520).clamp(360.0, 900.0);
    return Container(width: w, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: _T.r12, border: Border.all(color: _T.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('СОДЕРЖИМОЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        TextField(controller: titleCtrl, style: GoogleFonts.inter(color: _T.txtPrimary, fontSize: 15, fontWeight: FontWeight.w700), maxLines: null,
          decoration: InputDecoration(hintText: 'Заголовок...', hintStyle: GoogleFonts.inter(color: _T.txtMuted), filled: true, fillColor: _T.bgCard, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.accent, width: 1.5)))),
        const SizedBox(height: 8),
        ...contentCtrl.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
          const Padding(padding: EdgeInsets.only(right: 8, top: 2), child: Icon(Icons.drag_indicator_rounded, color: _T.txtMuted, size: 14)),
          Expanded(child: TextField(controller: e.value, style: GoogleFonts.inter(color: _T.txtPrimary, fontSize: 13), maxLines: null,
            decoration: InputDecoration(hintText: 'Пункт ${e.key+1}...', hintStyle: GoogleFonts.inter(color: _T.txtMuted), filled: true, fillColor: _T.bgCard, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _T.accent, width: 1.5)))),
          const SizedBox(width: 4), GestureDetector(onTap: () => onRemoveItem(e.key), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 14)),
        ]))),
        const SizedBox(height: 4), GestureDetector(onTap: onAddItem, child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.add_rounded, color: _T.accent, size: 14), SizedBox(width: 4), Text('Добавить пункт', style: TextStyle(color: _T.accent, fontSize: 12))])),
      ]),
    );
  }

  TextStylePreset _getStyle() {
    switch (textStyle) {
      case 'h1': return TextStylePreset(name: 'H1', fontSize: 32, fontWeight: FontWeight.w800);
      case 'h2': return TextStylePreset(name: 'H2', fontSize: 24, fontWeight: FontWeight.w700);
      case 'h3': return TextStylePreset(name: 'H3', fontSize: 18, fontWeight: FontWeight.w600);
      case 'quote': return TextStylePreset(name: 'Quote', fontSize: 16, fontWeight: FontWeight.w400, isItalic: true);
      default: return TextStylePreset(name: 'Body', fontSize: 14, fontWeight: FontWeight.w400);
    }
  }
  TextAlign _getAlign() => textAlign == 'center' ? TextAlign.center : textAlign == 'right' ? TextAlign.right : TextAlign.left;
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHART WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _BarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; final double height;
  const _BarChart({required this.data, required this.height});
  @override Widget build(BuildContext context) {
    double maxY = data.map((e) => e['value'] as double).reduce((a,b) => a>b ? a : b) * 1.2;
    return SizedBox(height: height * 0.7, child: BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround, maxY: maxY,
      titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_) => Text(v.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_) { int i = v.toInt(); return i>=0 && i<data.length ? Text(data[i]['label'], style: const TextStyle(color: _T.txtSecondary, fontSize: 10)) : const Text(''); }))),
      borderData: FlBorderData(show: false), gridData: FlGridData(show: true, drawVerticalLine: false),
      barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value['value'], color: _T.accent, width: 30, borderRadius: BorderRadius.circular(4))])).toList(),
    )));
  }
}
class _PieChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; final double height;
  const _PieChart({required this.data, required this.height});
  @override Widget build(BuildContext context) {
    double total = data.map((e) => e['value'] as double).reduce((a,b) => a+b);
    List<Color> colors = [_T.accent, _T.accentLight, Colors.orange, Colors.purple, Colors.cyan];
    return SizedBox(height: height * 0.7, child: PieChart(PieChartData(
      sections: data.asMap().entries.map((e) => PieChartSectionData(value: e.value['value'], title: '${((e.value['value']/total)*100).toInt()}%', radius: 80, titleStyle: const TextStyle(color: Colors.white, fontSize: 12), color: colors[e.key % colors.length])).toList(),
      sectionsSpace: 2, centerSpaceRadius: 40,
    )));
  }
}
class _LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data; final double height;
  const _LineChart({required this.data, required this.height});
  @override Widget build(BuildContext context) {
    double maxY = data.map((e) => e['value'] as double).reduce((a,b) => a>b ? a : b) * 1.2;
    return SizedBox(height: height * 0.7, child: LineChart(LineChartData(
      minX: 0, maxX: (data.length-1).toDouble(), minY: 0, maxY: maxY,
      titlesData: FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_) => Text(v.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10)))),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_) { int i = v.toInt(); return i>=0 && i<data.length ? Text(data[i]['label'], style: const TextStyle(color: _T.txtSecondary, fontSize: 10)) : const Text(''); }))),
      borderData: FlBorderData(show: false), gridData: FlGridData(show: true),
      lineBarsData: [LineChartBarData(spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['value'])).toList(), isCurved: true, color: _T.accent, barWidth: 3, dotData: FlDotData(show: true), belowBarData: BarAreaData(show: true, color: _T.accent.withOpacity(0.1)))],
    )));
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHAPE PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color..style = PaintingStyle.fill;
    Path path = Path()..moveTo(size.width/2, 0)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});
  @override void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = color..style = PaintingStyle.fill;
    Path path = Path(); double cx = size.width/2, cy = size.height/2, or = size.width/2, ir = or * 0.4;
    for (int i = 0; i < 10; i++) {
      double r = i.isEven ? or : ir;
      double angle = i * (pi / 5) - pi / 2;
      double x = cx + r * cos(angle), y = cy + r * sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close(); canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTIES PANEL (упрощённый)
// ═══════════════════════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index; final bool isPremium; final String activeTab, globalFont, transition, currentTextStyle, currentTextAlign,? chartType, imagePosition, imageTextWrap;
  final int selectedBgIndex, columnsCount, uploadsUsed; final double fontSize; final Color fontColor; final double? imageWidth, imageHeight;
  final List<Map<String, dynamic>> freeBgs, premiumBgs, allTransitions; final String? customBg; final List<Map<String, dynamic>> chartData;
  final List<SlideShape> shapes; final Map<String, TextStylePreset> textStyles; final bool isImproving, hasImage;
  final ValueChanged<String> onTabChange, onFontChange, onTransitionChange, onTextStyleChange, onTextAlignChange, onChartTypeChange, onImagePositionChange, onImageTextWrapChange;
  final ValueChanged<int> onBgSelect, onColumnsChange; final VoidCallback onBgUpload, onImageUpload; final ValueChanged<double> onFontSizeChange, onImageWidthChange, onImageHeightChange;
  final ValueChanged<Color> onFontColorChange; final ValueChanged<List<Map<String, dynamic>>> onChartDataChange; final ValueChanged<String> onAddShape;
  const _PropertiesPanel({required this.index, required this.isPremium, required this.activeTab, required this.globalFont, required this.selectedBgIndex,
    required this.freeBgs, required this.premiumBgs, required this.customBg, required this.fontSize, required this.fontColor, required this.transition,
    required this.allTransitions, required this.isImproving, required this.currentTextStyle, required this.currentTextAlign, required this.columnsCount,
    required this.textStyles, this.chartType, required this.chartData, required this.shapes, this.imageWidth, this.imageHeight, this.imagePosition, this.imageTextWrap,
    required this.hasImage, required this.onTabChange, required this.onBgSelect, required this.onBgUpload, required this.onImageUpload,
    required this.onFontChange, required this.onFontSizeChange, required this.onFontColorChange, required this.onTransitionChange,
    required this.onTextStyleChange, required this.onTextAlignChange, required this.onColumnsChange, required this.onChartTypeChange,
    required this.onChartDataChange, required this.onAddShape, required this.onImageWidthChange, required this.onImageHeightChange,
    required this.onImagePositionChange, required this.onImageTextWrapChange, required this.uploadsUsed});
  @override Widget build(BuildContext context) => Container(color: _T.bgSurface, child: Column(children: [
    Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(children: [
      _buildTab('design', 'Дизайн', Icons.palette_rounded), _buildTab('image', 'Медиа', Icons.image_rounded), _buildTab('shapes', 'Фигуры', Icons.shape_line_rounded),
      _buildTab('charts', 'Графики', Icons.show_chart_rounded), _buildTab('ai', 'ИИ', Icons.auto_awesome_rounded),
    ])),
    const Divider(color: _T.border, height: 1),
    Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: _buildContent())),
  ]));
  Widget _buildTab(String id, String label, IconData icon) => Expanded(child: GestureDetector(onTap: () => onTabChange(id), child: AnimatedContainer(duration: _T.fast, margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), padding: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: id == activeTab ? _T.accentDim : Colors.transparent, borderRadius: BorderRadius.circular(6), border: Border.all(color: id == activeTab ? _T.accent.withOpacity(0.3) : Colors.transparent)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 12, color: id == activeTab ? _T.accentLight : _T.txtMuted), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: id == activeTab ? _T.accentLight : _T.txtMuted))]))));
  Widget _buildContent() {
    if (activeTab == 'image') return _buildImageTab();
    if (activeTab == 'shapes') return _buildShapesTab();
    if (activeTab == 'charts') return _buildChartsTab();
    if (activeTab == 'ai') return _buildAiTab();
    return _buildDesignTab();
  }
  Widget _buildDesignTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ШРИФТ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    ...['Inter', 'Georgia', 'Courier'].map((f) => GestureDetector(onTap: () => onFontChange(f), child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: globalFont == f ? _T.accentDim : _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: globalFont == f ? _T.accent.withOpacity(0.4) : _T.border)), child: Row(children: [Expanded(child: Text(f, style: GoogleFonts.getFont(f, color: _T.txtPrimary, fontSize: 13))), if (globalFont == f) const Icon(Icons.check_circle_rounded, color: _T.accent, size: 16)])))),
    const SizedBox(height: 16),
    const Text('РАЗМЕР', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    Slider(value: fontSize, min: 10, max: 28, onChanged: onFontSizeChange, activeColor: _T.accent),
    const SizedBox(height: 16),
    const Text('ЦВЕТ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    Wrap(spacing: 7, children: [Colors.white, Colors.black, _T.accent, Colors.blue, Colors.red, _T.gold].map((c) => GestureDetector(onTap: () => onFontColorChange(c), child: Container(width: 28, height: 28, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: fontColor == c ? _T.accent : Colors.transparent, width: 2))))).toList()),
    const SizedBox(height: 16),
    const Text('ФОН', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    Wrap(spacing: 8, children: freeBgs.asMap().entries.map((e) => GestureDetector(onTap: () => onBgSelect(e.key), child: Container(width: 44, height: 44, decoration: BoxDecoration(gradient: e.value['type'] == 'gradient' ? LinearGradient(colors: e.value['colors'] as List<Color>) : null, color: e.value['type'] == 'solid' ? e.value['color'] as Color : null, borderRadius: BorderRadius.circular(8), border: Border.all(color: selectedBgIndex == e.key && customBg == null ? _T.accent : Colors.transparent, width: 2))))).toList()),
    const SizedBox(height: 8),
    GestureDetector(onTap: onBgUpload, child: Container(padding: const EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('Загрузить фон', style: TextStyle(color: _T.txtSecondary, fontSize: 12))))),
  ]);
  Widget _buildImageTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ИЗОБРАЖЕНИЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    GestureDetector(onTap: onImageUpload, child: Container(height: 80, decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)), child: Center(child: Text(hasImage ? 'Заменить' : 'Загрузить', style: const TextStyle(color: _T.accent))))),
    if (hasImage) ...[
      const SizedBox(height: 16),
      const Text('РАЗМЕР', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
      Row(children: [Expanded(child: Slider(value: imageWidth ?? 0.28, min: 0.1, max: 0.6, onChanged: onImageWidthChange)), Text('${((imageWidth ?? 0.28)*100).toInt()}%')]),
      Row(children: [Expanded(child: Slider(value: imageHeight ?? 0.55, min: 0.1, max: 0.8, onChanged: onImageHeightChange)), Text('${((imageHeight ?? 0.55)*100).toInt()}%')]),
      const SizedBox(height: 16),
      const Text('ПОЗИЦИЯ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['left', 'right', 'top', 'bottom'].map((p) => IconButton(onPressed: () => onImagePositionChange(p), icon: Icon(p == 'left' ? Icons.format_align_left : p == 'right' ? Icons.format_align_right : p == 'top' ? Icons.vertical_align_top : Icons.vertical_align_bottom, color: imagePosition == p ? _T.accent : _T.txtSecondary))).toList()),
    ],
  ]);
  Widget _buildShapesTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ДОБАВИТЬ ФИГУРУ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    const SizedBox(height: 8),
    Wrap(spacing: 8, children: [Icons.circle_rounded, Icons.square_rounded, Icons.rectangle_rounded, Icons.triangle_rounded, Icons.star_rounded].map((icon) => GestureDetector(onTap: () => onAddShape(icon == Icons.circle_rounded ? 'circle' : icon == Icons.square_rounded ? 'square' : icon == Icons.rectangle_rounded ? 'rectangle' : icon == Icons.triangle_rounded ? 'triangle' : 'star'), child: Container(width: 50, height: 50, decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: _T.accent, size: 28)))).toList()),
    if (shapes.isNotEmpty) ...[
      const SizedBox(height: 16),
      const Text('ФИГУРЫ НА СЛАЙДЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
      ...shapes.map((s) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(_getShapeIcon(s.type), color: s.color), const SizedBox(width: 12), Expanded(child: Text(s.type)), GestureDetector(onTap: () => onAddShape('remove_${s.id}'), child: const Icon(Icons.close, color: _T.danger))]))),
    ],
  ]);
  IconData _getShapeIcon(String t) => t == 'circle' ? Icons.circle_rounded : t == 'square' ? Icons.square_rounded : t == 'rectangle' ? Icons.rectangle_rounded : t == 'triangle' ? Icons.triangle_rounded : Icons.star_rounded;
  Widget _buildChartsTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ТИП ГРАФИКА', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _chartButton('bar', Icons.bar_chart_rounded, 'Столбчатый'), _chartButton('pie', Icons.pie_chart_rounded, 'Круговой'), _chartButton('line', Icons.show_chart_rounded, 'Линейный'), _chartButton(null, Icons.clear_rounded, 'Удалить'),
    ]),
    if (chartType != null) ...[
      const SizedBox(height: 16),
      const Text('ДАННЫЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
      ...chartData.asMap().entries.map((e) => Row(children: [Expanded(child: TextField(controller: TextEditingController(text: e.value['label']), style: const TextStyle(color: Colors.white), onChanged: (v) { var d = List.from(chartData); d[e.key]['label'] = v; onChartDataChange(d); })), const SizedBox(width: 8), Expanded(child: TextField(controller: TextEditingController(text: e.value['value'].toString()), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), onChanged: (v) { var d = List.from(chartData); d[e.key]['value'] = double.tryParse(v) ?? 0; onChartDataChange(d); }))])),
      GestureDetector(onTap: () { var d = List.from(chartData); d.add({'label': 'Новый', 'value': 100}); onChartDataChange(d); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)), child: const Center(child: Text('+ Добавить', style: TextStyle(color: _T.accent))))),
    ],
  ]);
  Widget _chartButton(String? t, IconData icon, String label) => GestureDetector(onTap: () => onChartTypeChange(t), child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: chartType == t ? _T.accentDim : _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: chartType == t ? _T.accent : _T.border)), child: Icon(icon, color: chartType == t ? _T.accent : _T.txtSecondary)), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: chartType == t ? _T.accent : _T.txtSecondary))]));
  Widget _buildAiTab() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('ИИ ПОМОЩНИК', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700)),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [_T.accent.withOpacity(0.08), _T.accentLight.withOpacity(0.05)]), borderRadius: BorderRadius.circular(12)), child: Column(children: [
      Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18)), const SizedBox(width: 12), const Text('Улучшить текст', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 12),
      const Text('ИИ перепишет заголовок и пункты', style: TextStyle(color: _T.txtSecondary, fontSize: 12)),
      const SizedBox(height: 12),
      GestureDetector(onTap: isImproving ? null : () {}, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: isImproving ? null : const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: Center(child: isImproving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Улучшить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))))),
    ])),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORT SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isPremium; final Presentation presentation;
  const _ExportSheet({required this.isPremium, required this.presentation});
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 32), decoration: BoxDecoration(color: _T.bgSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _T.border)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.only(top: 12, bottom: 16), child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)))),
      const Text('Экспорт', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      ListTile(onTap: () { Navigator.pop(context); ExportService.exportToPPTX(context: context, presentation: presentation, isPremium: isPremium); }, leading: const Icon(Icons.slideshow), title: const Text('PowerPoint'), subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком')),
      ListTile(onTap: isPremium ? () { Navigator.pop(context); ExportService.exportToPDF(context: context, presentation: presentation, isPremium: true); } : null, leading: Icon(Icons.picture_as_pdf, color: isPremium ? null : _T.txtMuted), title: const Text('PDF'), subtitle: Text(isPremium ? 'Высокое качество' : 'Только Premium'), trailing: !isPremium ? const Icon(Icons.lock) : null),
      const SizedBox(height: 16),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// CONTROL BAR
// ═══════════════════════════════════════════════════════════════════════════════
class _ControlBar extends StatelessWidget {
  final int activeSlide, totalSlides; final bool propsPanelOpen;
  final VoidCallback onToggleProps, onPrev, onNext, onAdd, onDelete, onDuplicate, onTemplate;
  const _ControlBar({required this.activeSlide, required this.totalSlides, required this.propsPanelOpen, required this.onToggleProps, required this.onPrev, required this.onNext, required this.onAdd, required this.onDelete, required this.onDuplicate, required this.onTemplate});
  @override Widget build(BuildContext context) => Container(height: 48, color: _T.bgSurface, padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      _IconBtn(Icons.copy_rounded, onDuplicate), _IconBtn(Icons.delete_outline_rounded, onDelete, danger: true), _IconBtn(Icons.template_rounded, onTemplate),
      const Spacer(),
      _IconBtn(Icons.arrow_back_rounded, onPrev, disabled: activeSlide == 0),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${activeSlide + 1} / $totalSlides', style: const TextStyle(color: _T.txtSecondary, fontSize: 13))),
      _IconBtn(Icons.arrow_forward_rounded, onNext, disabled: activeSlide == totalSlides - 1),
      const Spacer(),
      _IconBtn(Icons.add_rounded, onAdd), _IconBtn(propsPanelOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined, onToggleProps),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// ICON BUTTON
// ═══════════════════════════════════════════════════════════════════════════════
class _IconBtn extends StatefulWidget {
  final IconData icon; final VoidCallback? onTap; final double size; final String? tooltip; final bool danger, disabled; final Widget? child;
  const _IconBtn(this.icon, this.onTap, {this.size = 18, this.tooltip, this.danger = false, this.disabled = false, this.child});
  @override State<_IconBtn> createState() => _IconBtnState();
}
class _IconBtnState extends State<_IconBtn> {
  bool hover = false;
  @override Widget build(BuildContext context) {
    Color color = widget.disabled ? _T.txtMuted : widget.danger ? _T.danger : hover ? _T.txtPrimary : _T.txtSecondary;
    return MouseRegion(cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click, onEnter: (_) => setState(() => hover = true), onExit: (_) => setState(() => hover = false),
      child: Tooltip(message: widget.tooltip ?? '', child: GestureDetector(onTap: widget.disabled ? null : widget.onTap, child: AnimatedContainer(duration: _T.fast, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: hover && !widget.disabled ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: widget.child ?? Icon(widget.icon, size: widget.size, color: color)))));
  }
}