import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  static const borderFocus = Color(0xFF3A3A3A);
  static const txtPrimary = Colors.white;
  static const txtSecondary = Color(0xFF9A9A9A);
  static const txtMuted = Color(0xFF4A4A4A);
  static const accent = Color(0xFF1DB954);
  static const accentLight = Color(0xFF1ED760);
  static const accentDim = Color(0xFF1DB95420);
  static const danger = Color(0xFFFF3B30);
  static const success = Color(0xFF1DB954);
  static const gold = Color(0xFFFFD700);
  static const r4 = BorderRadius.all(Radius.circular(4));
  static const r8 = BorderRadius.all(Radius.circular(8));
  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
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
  double x;
  double y;
  double width;
  double height;
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
    String? id,
    String? type,
    double? x,
    double? y,
    double? width,
    double? height,
    Color? color,
    double? opacity,
  }) {
    return SlideShape(
      id: id ?? this.id,
      type: type ?? this.type,
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
  final String id;
  final String name;
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
// EDITOR SCREEN
// ═══════════════════════════════════════════════════════════════════════════════
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

  Color _globalFontColor = Colors.white;
  late List<Color?> _slideFontColors;
  late List<String> _transitions;

  // Стили текста
  String _currentTextStyle = 'body';
  String _currentTextAlign = 'left';
  int _columnsCount = 1;

  // Графики
  late List<String?> _chartTypes;
  late List<List<Map<String, dynamic>>> _chartData;

  // Фигуры
  late List<List<SlideShape>> _shapes;

  // Управление изображениями
  late List<double?> _imageWidths;
  late List<double?> _imageHeights;
  late List<String?> _imagePositions;
  late List<String?> _imageTextWrap;

  final Map<int, String?> _autoImages = {};
  final _scrollCtrl = ScrollController();
  final _canvasKey = GlobalKey();

  // Шаблоны слайдов
  final List<SlideTemplate> _slideTemplates = [
    const SlideTemplate(
      id: 'cover_left',
      name: 'Обложка по левому краю',
      icon: Icons.vertical_align_left_rounded,
      build: _buildCoverLeftTemplate,
    ),
    const SlideTemplate(
      id: 'cover_center',
      name: 'Обложка по центру',
      icon: Icons.center_focus_strong_rounded,
      build: _buildCoverCenterTemplate,
    ),
    const SlideTemplate(
      id: 'two_columns',
      name: 'Две колонки',
      icon: Icons.view_column_rounded,
      build: _buildTwoColumnsTemplate,
    ),
    const SlideTemplate(
      id: 'three_columns',
      name: 'Три колонки',
      icon: Icons.view_quilt_rounded,
      build: _buildThreeColumnsTemplate,
    ),
    const SlideTemplate(
      id: 'image_and_text',
      name: 'Изображение и текст',
      icon: Icons.image_rounded,
      build: _buildImageAndTextTemplate,
    ),
    const SlideTemplate(
      id: 'quote',
      name: 'Цитата',
      icon: Icons.format_quote_rounded,
      build: _buildQuoteTemplate,
    ),
  ];

  // Бесплатные фоны
  final List<Map<String, dynamic>> _freeBgs = [
    {'type': 'solid', 'color': const Color(0xFF1A1A1A), 'label': 'Тёмный'},
    {'type': 'solid', 'color': Colors.white, 'label': 'Белый'},
    {'type': 'solid', 'color': const Color(0xFF0F0F0F), 'label': 'Чёрный'},
    {'type': 'solid', 'color': const Color(0xFFFFF8E7), 'label': 'Кремовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF1a1a2e), const Color(0xFF16213e)], 'label': 'Midnight'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)], 'label': 'Фиолет'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)], 'label': 'Голубой'},
    {'type': 'gradient', 'colors': [const Color(0xFFf093fb), const Color(0xFFf5576c)], 'label': 'Розовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF434343), const Color(0xFF000000)], 'label': 'Уголь'},
  ];

  final List<Map<String, dynamic>> _premiumBgs = [
    {'type': 'gradient', 'colors': [const Color(0xFF1DB954), const Color(0xFF191414)], 'label': 'Spotify'},
    {'type': 'gradient', 'colors': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], 'label': 'Неон'},
    {'type': 'gradient', 'colors': [const Color(0xFF0F0C29), const Color(0xFF302B63), const Color(0xFF24243E)], 'label': 'Cosmos'},
    {'type': 'gradient', 'colors': [const Color(0xFF11998e), const Color(0xFF38ef7d)], 'label': 'Mint'},
    {'type': 'gradient', 'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], 'label': 'Закат'},
    {'type': 'gradient', 'colors': [const Color(0xFFFFE000), const Color(0xFF799F0C)], 'label': 'Лимон'},
    {'type': 'gradient', 'colors': [const Color(0xFF00b4db), const Color(0xFF0083B0)], 'label': 'Океан'},
    {'type': 'solid', 'color': const Color(0xFF1A1A2E), 'label': 'Navy'},
  ];

  static const List<Map<String, dynamic>> _allTransitions = [
    {'id': 'none', 'label': 'Нет', 'icon': Icons.block_rounded, 'premium': false},
    {'id': 'fade', 'label': 'Затухание', 'icon': Icons.blur_on_rounded, 'premium': false},
    {'id': 'slide', 'label': 'Слайд', 'icon': Icons.swap_horiz_rounded, 'premium': true},
    {'id': 'zoom', 'label': 'Зум', 'icon': Icons.zoom_in_rounded, 'premium': true},
    {'id': 'flip', 'label': 'Флип', 'icon': Icons.flip_rounded, 'premium': true},
    {'id': 'cube', 'label': 'Куб', 'icon': Icons.view_in_ar_rounded, 'premium': true},
  ];

  final Map<String, TextStylePreset> _textStyles = {
    'h1': TextStylePreset(name: 'Заголовок 1', fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
    'h2': TextStylePreset(name: 'Заголовок 2', fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    'h3': TextStylePreset(name: 'Заголовок 3', fontSize: 18, fontWeight: FontWeight.w600),
    'body': TextStylePreset(name: 'Основной текст', fontSize: 14, fontWeight: FontWeight.w400),
    'small': TextStylePreset(name: 'Мелкий текст', fontSize: 11, fontWeight: FontWeight.w400),
    'quote': TextStylePreset(name: 'Цитата', fontSize: 16, fontWeight: FontWeight.w400, isItalic: true),
  };

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _customImages = List.filled(_presentation.slides.length, null);
    _customBgs = List.filled(_presentation.slides.length, null);
    _fontSizes = List.filled(_presentation.slides.length, 14.0);
    _fonts = List.filled(_presentation.slides.length, 'Inter');
    _slideFontColors = List.filled(_presentation.slides.length, Colors.white);
    _transitions = List.filled(_presentation.slides.length, 'none');
    _chartTypes = List.filled(_presentation.slides.length, null);
    _chartData = List.filled(_presentation.slides.length, []);
    _shapes = List.generate(_presentation.slides.length, (_) => []);
    _imageWidths = List.filled(_presentation.slides.length, 0.28);
    _imageHeights = List.filled(_presentation.slides.length, 0.55);
    _imagePositions = List.filled(_presentation.slides.length, 'right');
    _imageTextWrap = List.filled(_presentation.slides.length, 'around');
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
      final q = _titleCtrl[i].text.isNotEmpty ? _titleCtrl[i].text : _presentation.title;
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
      _chartTypes.insert(idx, _chartTypes[i]);
      _chartData.insert(idx, List.from(_chartData[i]));
      _shapes.insert(idx, _shapes[i].map((s) => s.copyWith(id: DateTime.now().toString())).toList());
      _imageWidths.insert(idx, _imageWidths[i]);
      _imageHeights.insert(idx, _imageHeights[i]);
      _imagePositions.insert(idx, _imagePositions[i]);
      _imageTextWrap.insert(idx, _imageTextWrap[i]);
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
      swap(_chartTypes);
      swap(_chartData);
      swap(_shapes);
      swap(_imageWidths);
      swap(_imageHeights);
      swap(_imagePositions);
      swap(_imageTextWrap);
      _activeSlide = to;
    });
  }

  void _addContentItem(int i) => setState(() => _contentCtrl[i].add(TextEditingController(text: 'Новый пункт')));

  void _removeContentItem(int slide, int item) {
    if (_contentCtrl[slide].length <= 1) return;
    setState(() {
      _contentCtrl[slide][item].dispose();
      _contentCtrl[slide].removeAt(item);
    });
  }

  // Фигуры
  void _addShape(String type) {
    setState(() {
      _shapes[_activeSlide].add(SlideShape(
        id: DateTime.now().toString(),
        type: type,
        x: 100,
        y: 100,
        width: 80,
        height: 80,
        color: _globalFontColor,
        opacity: 0.8,
      ));
    });
  }

  void _removeShape(String id) {
    setState(() {
      _shapes[_activeSlide].removeWhere((s) => s.id == id);
    });
  }

  // Управление изображениями
  void _updateImageWidth(double width) {
    setState(() {
      _imageWidths[_activeSlide] = width;
    });
  }

  void _updateImageHeight(double height) {
    setState(() {
      _imageHeights[_activeSlide] = height;
    });
  }

  void _updateImagePosition(String position) {
    setState(() {
      _imagePositions[_activeSlide] = position;
    });
  }

  void _updateImageTextWrap(String wrap) {
    setState(() {
      _imageTextWrap[_activeSlide] = wrap;
    });
  }

  // Шаблоны слайдов
  static Slide _buildCoverLeftTemplate() {
    return Slide(title: 'Заголовок презентации', content: ['Подзаголовок презентации']);
  }

  static Slide _buildCoverCenterTemplate() {
    return Slide(title: 'Заголовок презентации', content: ['Подзаголовок презентации']);
  }

  static Slide _buildTwoColumnsTemplate() {
    return Slide(title: 'Заголовок', content: ['Текст первой колонки', 'Текст второй колонки']);
  }

  static Slide _buildThreeColumnsTemplate() {
    return Slide(title: 'Заголовок', content: ['Колонка 1', 'Колонка 2', 'Колонка 3']);
  }

  static Slide _buildImageAndTextTemplate() {
    return Slide(title: 'Заголовок', content: ['Описание изображения']);
  }

  static Slide _buildQuoteTemplate() {
    return Slide(title: 'Цитата', content: ['Важная цитата']);
  }

  void _showTemplatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _T.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Добавить шаблон слайда',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Выберите макет для нового слайда',
              style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 13)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _slideTemplates.length,
              itemBuilder: (_, i) => _TemplateCard(
                template: _slideTemplates[i],
                onTap: () {
                  Navigator.pop(ctx);
                  _addSlideFromTemplate(_slideTemplates[i]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSlideFromTemplate(SlideTemplate template) {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      _toast('Максимум ${up.maxSlidesPerPresentation} слайдов');
      return;
    }

    setState(() {
      final idx = _activeSlide + 1;
      final newSlide = template.build();
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
        _imageWidths[index] = 0.28;
        _imageHeights[index] = 0.55;
        _imagePositions[index] = 'right';
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
    if (error) bg = _T.danger.withOpacity(0.9);
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
                textStyle: _currentTextStyle,
                textAlign: _currentTextAlign,
                columnsCount: _columnsCount,
                chartType: _chartTypes[_activeSlide],
                chartData: _chartData[_activeSlide],
                shapes: _shapes[_activeSlide],
                imageWidth: _imageWidths[_activeSlide] ?? 0.28,
                imageHeight: _imageHeights[_activeSlide] ?? 0.55,
                imagePosition: _imagePositions[_activeSlide] ?? 'right',
                imageTextWrap: _imageTextWrap[_activeSlide] ?? 'around',
                onAddItem: () => _addContentItem(_activeSlide),
                onRemoveItem: (i) => _removeContentItem(_activeSlide, i),
                onRemoveImage: () => setState(() { _customImages[_activeSlide] = null; _countUploads(); }),
                hasCustomImage: _customImages[_activeSlide] != null,
                onAddShape: _addShape,
                onRemoveShape: _removeShape,
              ),
            ),
            const VerticalDivider(color: _T.border, width: 1),
            AnimatedContainer(
              duration: _T.normal,
              width: _propsPanelOpen ? 280 : 0,
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
                      currentTextStyle: _currentTextStyle,
                      currentTextAlign: _currentTextAlign,
                      columnsCount: _columnsCount,
                      textStyles: _textStyles,
                      chartType: _chartTypes[_activeSlide],
                      chartData: _chartData[_activeSlide],
                      shapes: _shapes[_activeSlide],
                      imageWidth: _imageWidths[_activeSlide],
                      imageHeight: _imageHeights[_activeSlide],
                      imagePosition: _imagePositions[_activeSlide],
                      imageTextWrap: _imageTextWrap[_activeSlide],
                      hasImage: _customImages[_activeSlide] != null || _autoImages[_activeSlide] != null,
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
                      onTextStyleChange: (style) => setState(() => _currentTextStyle = style),
                      onTextAlignChange: (align) => setState(() => _currentTextAlign = align),
                      onColumnsChange: (count) => setState(() => _columnsCount = count),
                      onChartTypeChange: (type) => setState(() => _chartTypes[_activeSlide] = type),
                      onChartDataChange: (data) => setState(() => _chartData[_activeSlide] = data),
                      onAddShape: _addShape,
                      onImageWidthChange: _updateImageWidth,
                      onImageHeightChange: _updateImageHeight,
                      onImagePositionChange: _updateImagePosition,
                      onImageTextWrapChange: _updateImageTextWrap,
                      uploadsUsed: _imageUploadsUsed,
                    )
                  : const SizedBox.shrink(),
            ),
          ]),
        ),
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
          onTemplate: _showTemplatePicker,
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
// TEMPLATE CARD
// ═══════════════════════════════════════════════════════════════════════════════
class _TemplateCard extends StatelessWidget {
  final SlideTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(template.icon, color: const Color(0xFF1DB954), size: 28),
              const SizedBox(height: 8),
              Text(
                template.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
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
        _IconBtn(Icons.arrow_back_ios_rounded, onBack, tooltip: 'Назад', size: 17),
        const SizedBox(width: 8),
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
            Text('$slideCount слайдов', style: const TextStyle(color: _T.txtMuted, fontSize: 10)),
          ]),
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
            child: Text('🖼 $uploadsUsed/10', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: uploadsUsed >= 10 ? _T.gold : _T.accentLight)),
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
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final ValueChanged<int> onDelete, onDuplicate, onMoveUp, onMoveDown;
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
    final bg = backgrounds[selectedBgIndex];
    if (bg['type'] == 'solid') return bg['color'] as Color;
    return (bg['colors'] as List<Color>).first;
  }

  @override
  Widget build(BuildContext context) => Container(
    color: _T.bgSurface,
    child: Column(children: [
      Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 8), child: Row(children: [
        if (!collapsed) ...[const Text('СЛАЙДЫ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)), const Spacer()],
        _IconBtn(collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, onToggleCollapse, size: 16)
      ])),
      const Divider(color: _T.border, height: 1),
      Expanded(child: ListView.builder(
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
      )),
      const Divider(color: _T.border, height: 1),
      GestureDetector(
        onTap: onAdd,
        child: Container(height: 44, alignment: Alignment.center, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 20, height: 20, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(5), border: Border.all(color: _T.accent.withOpacity(0.4))), child: const Icon(Icons.add_rounded, color: _T.accent, size: 14)),
          if (!collapsed) ...[const SizedBox(width: 8), const Text('Слайд', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w600))]
        ])),
      ),
    ]),
  );
}

class _SlideThumbnail extends StatefulWidget {
  final int index;
  final String title;
  final bool isActive, collapsed;
  final Color bgColor;
  final VoidCallback onTap, onDuplicate;
  final VoidCallback? onDelete, onMoveUp, onMoveDown;
  const _SlideThumbnail({required this.index, required this.title, required this.isActive, required this.collapsed, required this.bgColor, required this.onTap, this.onDelete, required this.onDuplicate, this.onMoveUp, this.onMoveDown});
  @override State<_SlideThumbnail> createState() => _SlideThumbnailState();
}

class _SlideThumbnailState extends State<_SlideThumbnail> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
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
          border: Border.all(color: widget.isActive ? _T.accent.withOpacity(0.5) : Colors.transparent, width: 1.5),
        ),
        child: widget.collapsed ? _collapsedView() : _expandedView(),
      ),
    ),
  );
  
  Widget _collapsedView() => Column(children: [
    Container(width: 30, height: 20, decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(3)), child: Center(child: Text('${widget.index + 1}', style: TextStyle(fontSize: 8, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white, fontWeight: FontWeight.w700)))),
  ]);
  
  Widget _expandedView() => Row(children: [
    Container(width: 52, height: 34, decoration: BoxDecoration(color: widget.bgColor, borderRadius: BorderRadius.circular(4)), child: Center(child: Text('${widget.index + 1}', style: TextStyle(fontSize: 10, color: widget.bgColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white38, fontWeight: FontWeight.w700)))),
    const SizedBox(width: 8),
    Expanded(child: Text(widget.title.isEmpty ? 'Слайд ${widget.index + 1}' : widget.title, style: TextStyle(color: widget.isActive ? _T.txtPrimary : _T.txtSecondary, fontSize: 11, fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400), maxLines: 2, overflow: TextOverflow.ellipsis)),
    if (_hovered) PopupMenuButton<String>(
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
        if (widget.onMoveUp != null) const PopupMenuItem(value: 'up', height: 36, child: _MenuItem(Icons.arrow_upward_rounded, 'Вверх')),
        if (widget.onMoveDown != null) const PopupMenuItem(value: 'down', height: 36, child: _MenuItem(Icons.arrow_downward_rounded, 'Вниз')),
        const PopupMenuItem(value: 'dup', height: 36, child: _MenuItem(Icons.copy_rounded, 'Дублировать')),
        if (widget.onDelete != null) const PopupMenuItem(value: 'del', height: 36, child: _MenuItem(Icons.delete_outline_rounded, 'Удалить', danger: true)),
      ],
    ),
  ]);
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuItem(this.icon, this.label, {this.danger = false});
  @override Widget build(BuildContext context) => Row(children: [Icon(icon, size: 14, color: danger ? _T.danger : _T.txtSecondary), const SizedBox(width: 8), Text(label, style: TextStyle(color: danger ? _T.danger : _T.txtPrimary, fontSize: 12))]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// CANVAS
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
  final Color fontColor;
  final int slideCount;
  final String textStyle;
  final String textAlign;
  final int columnsCount;
  final String? chartType;
  final List<Map<String, dynamic>> chartData;
  final List<SlideShape> shapes;
  final double imageWidth;
  final double imageHeight;
  final String imagePosition;
  final String imageTextWrap;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onRemoveImage;
  final bool hasCustomImage;
  final ValueChanged<String> onAddShape;
  final ValueChanged<String> onRemoveShape;

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
    required this.textStyle,
    required this.textAlign,
    required this.columnsCount,
    required this.chartType,
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
    required this.onAddShape,
    required this.onRemoveShape,
  });

  @override
  Widget build(BuildContext context) {
    final logo = context.watch<BrandKitProvider>().logoUrl;

    return Container(
      color: _T.bgBase,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(children: [
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('${index + 1} / $slideCount', style: const TextStyle(color: _T.txtMuted, fontSize: 11, fontWeight: FontWeight.w500))),
            LayoutBuilder(builder: (ctx, constraints) {
              final width = (MediaQuery.of(context).size.width - 520).clamp(360.0, 900.0);
              final height = width * 9 / 16;
              return Container(
                width: width, height: height,
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: Stack(children: [
                  ...shapes.map((shape) => Positioned(
                    left: shape.x,
                    top: shape.y,
                    child: Opacity(
                      opacity: shape.opacity,
                      child: _buildShapeWidget(shape),
                    ),
                  )),
                  Positioned(top: 12, left: 14, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(5)), child: Text('${index + 1}', style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w700)))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 20),
                    child: _buildContent(width, height),
                  ),
                  if (logo != null)
                    Positioned(
                      bottom: 10, right: 14,
                      child: Opacity(
                        opacity: 0.7,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(logo, width: 50, height: 20, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox()),
                        ),
                      ),
                    ),
                ]),
              );
            }),
            const SizedBox(height: 16),
            _buildContentEditor(),
          ]),
        ),
      ),
    );
  }

  Widget _buildShapeWidget(SlideShape shape) {
    switch (shape.type) {
      case 'circle':
        return Container(
          width: shape.width,
          height: shape.height,
          decoration: BoxDecoration(
            color: shape.color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))],
          ),
        );
      case 'square':
        return Container(
          width: shape.width,
          height: shape.height,
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.circular(0),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))],
          ),
        );
      case 'rectangle':
        return Container(
          width: shape.width,
          height: shape.height,
          decoration: BoxDecoration(
            color: shape.color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(2, 2))],
          ),
        );
      case 'triangle':
        return CustomPaint(
          size: Size(shape.width, shape.height),
          painter: _TrianglePainter(color: shape.color),
        );
      case 'star':
        return CustomPaint(
          size: Size(shape.width, shape.height),
          painter: _StarPainter(color: shape.color),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContent(double width, double height) {
    if (chartType != null && chartData.isNotEmpty) {
      return _buildChartWidget(width, height);
    }

    if (columnsCount > 1) {
      return _buildMultiColumnContent(width, height);
    }

    // Стандартная верстка с изображением
    final imageWidget = image != null ? _buildImageWidget(width, height) : null;
    final textWidget = _buildTextColumn();

    if (imageWidget == null) {
      return textWidget;
    }

    switch (imagePosition) {
      case 'left':
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          imageWidget,
          const SizedBox(width: 20),
          Expanded(child: textWidget),
        ]);
      case 'top':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          imageWidget,
          const SizedBox(height: 20),
          textWidget,
        ]);
      case 'bottom':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          textWidget,
          const SizedBox(height: 20),
          imageWidget,
        ]);
      default: // 'right'
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: textWidget),
          const SizedBox(width: 20),
          imageWidget,
        ]);
    }
  }

  Widget _buildMultiColumnContent(double width, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(columnsCount, (colIndex) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: colIndex < columnsCount - 1 ? 12 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (colIndex == 0 && titleCtrl.text.isNotEmpty)
                  _buildEditableText(titleCtrl, isTitle: true),
                const SizedBox(height: 8),
                ...contentCtrl
                    .skip(colIndex * 2)
                    .take(2)
                    .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildEditableText(c, isTitle: false),
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextColumn() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildEditableText(titleCtrl, isTitle: true),
      const SizedBox(height: 12),
      // Убрано ограничение take(5) - теперь показывает все пункты
      ...contentCtrl.mapIndexed((i, c) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.only(top: fontSize * 0.38, right: 7), child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: _T.accent, shape: BoxShape.circle))),
          Expanded(child: _buildEditableText(c, isTitle: false)),
        ]),
      )),
    ]);
  }

  Widget _buildImageWidget(double width, double height) {
    final imageW = width * imageWidth;
    final imageH = height * imageHeight;
    
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          image!,
          width: imageW,
          height: imageH,
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
              width: 24, height: 24,
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
    ]);
  }

  Widget _buildChartWidget(double width, double height) {
    if (chartData.isEmpty) {
      return Center(
        child: Container(
          width: width * 0.6, height: height * 0.6,
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.border),
          ),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.show_chart_rounded, color: _T.txtMuted, size: 48),
            SizedBox(height: 12),
            Text('Добавьте данные для графика', style: TextStyle(color: _T.txtMuted, fontSize: 13)),
            SizedBox(height: 4),
            Text('В панели справа → Графики', style: TextStyle(color: _T.txtMuted, fontSize: 11)),
          ]),
        ),
      );
    }

    switch (chartType) {
      case 'bar':
        return _BarChartWidget(data: chartData, color: _T.accent, height: height);
      case 'pie':
        return _PieChartWidget(data: chartData, height: height);
      case 'line':
        return _LineChartWidget(data: chartData, color: _T.accent, height: height);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEditableText(TextEditingController controller, {required bool isTitle}) {
    final stylePreset = _getTextStylePreset();
    return EditableText(
      controller: controller,
      focusNode: FocusNode(),
      style: TextStyle(
        fontSize: isTitle ? stylePreset.fontSize * 1.5 : stylePreset.fontSize,
        fontWeight: isTitle ? FontWeight.w800 : stylePreset.fontWeight,
        fontFamily: font,
        color: fontColor,
        height: 1.3,
        letterSpacing: stylePreset.letterSpacing,
        fontStyle: stylePreset.isItalic ? FontStyle.italic : FontStyle.normal,
      ),
      cursorColor: _T.accent,
      backgroundCursorColor: _T.accent,
      maxLines: null, // Убрано ограничение maxLines
      textAlign: _getTextAlign(),
    );
  }

  Widget _buildContentEditor() {
    final width = (MediaQuery.of(context).size.width - 520).clamp(360.0, 900.0);
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _T.bgSurface, borderRadius: _T.r12, border: Border.all(color: _T.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('СОДЕРЖИМОЕ', style: TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        _EditorField(controller: titleCtrl, hint: 'Заголовок слайда...', isTitle: true),
        const SizedBox(height: 8),
        ...contentCtrl.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Padding(padding: EdgeInsets.only(right: 8, top: 2), child: Icon(Icons.drag_indicator_rounded, color: _T.txtMuted, size: 14)),
            Expanded(child: _EditorField(controller: e.value, hint: 'Пункт ${e.key + 1}...')),
            const SizedBox(width: 4),
            GestureDetector(onTap: () => onRemoveItem(e.key), child: const Icon(Icons.close_rounded, color: _T.txtMuted, size: 14)),
          ]),
        )),
        const SizedBox(height: 4),
        GestureDetector(onTap: onAddItem, child: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.add_rounded, color: _T.accent, size: 14), SizedBox(width: 4), Text('Добавить пункт', style: TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w500))])),
      ]),
    );
  }

  TextStylePreset _getTextStylePreset() {
    switch (textStyle) {
      case 'h1': return TextStylePreset(name: 'H1', fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5);
      case 'h2': return TextStylePreset(name: 'H2', fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3);
      case 'h3': return TextStylePreset(name: 'H3', fontSize: 18, fontWeight: FontWeight.w600);
      case 'small': return TextStylePreset(name: 'Small', fontSize: 11, fontWeight: FontWeight.w400);
      case 'quote': return TextStylePreset(name: 'Quote', fontSize: 16, fontWeight: FontWeight.w400, isItalic: true);
      default: return TextStylePreset(name: 'Body', fontSize: 14, fontWeight: FontWeight.w400);
    }
  }

  TextAlign _getTextAlign() {
    switch (textAlign) {
      case 'center': return TextAlign.center;
      case 'right': return TextAlign.right;
      default: return TextAlign.left;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHAPE PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    final points = 5;
    final angleStep = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = i * angleStep - pi / 2;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// CHART WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _BarChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color color;
  final double height;

  const _BarChartWidget({required this.data, required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b) * 1.2;
    return SizedBox(
      height: height * 0.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Text(data[index]['label'], style: const TextStyle(color: _T.txtSecondary, fontSize: 10));
                }
                return const Text('');
              },
            )),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) {
            return FlLine(color: _T.border, strokeWidth: 0.5);
          }),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [BarChartRodData(toY: entry.value['value'], color: color, width: 30, borderRadius: BorderRadius.circular(4))],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double height;

  const _PieChartWidget({required this.data, required this.height});

  @override
  Widget build(BuildContext context) {
    final total = data.map((e) => e['value'] as double).reduce((a, b) => a + b);
    return SizedBox(
      height: height * 0.7,
      child: PieChart(
        PieChartData(
          sections: data.asMap().entries.map((entry) {
            final index = entry.key;
            final value = entry.value['value'] as double;
            return PieChartSectionData(
              value: value,
              title: '${((value / total) * 100).toInt()}%',
              radius: 80,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              color: [
                _T.accent,
                _T.accentLight,
                Colors.orange,
                Colors.purple,
                Colors.cyan,
                Colors.pink,
              ][index % 6],
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color color;
  final double height;

  const _LineChartWidget({required this.data, required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b) * 1.2;
    return SizedBox(
      height: height * 0.7,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString(), style: const TextStyle(color: _T.txtSecondary, fontSize: 10));
            })),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Text(data[index]['label'], style: const TextStyle(color: _T.txtSecondary, fontSize: 10));
                }
                return const Text('');
              },
            )),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) {
            return FlLine(color: _T.border, strokeWidth: 0.5);
          }, getDrawingVerticalLine: (value) {
            return FlLine(color: _T.border, strokeWidth: 0.5);
          }),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['value']);
              }).toList(),
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(radius: 4, color: color, strokeWidth: 0);
              }),
              belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
            ),
          ],
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
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: TextStyle(color: _T.txtPrimary, fontSize: isTitle ? 15 : 13, fontWeight: isTitle ? FontWeight.w700 : FontWeight.w400),
    maxLines: null, // Убрано ограничение maxLines
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

// ═══════════════════════════════════════════════════════════════════════════════
// PROPERTIES PANEL
// ═══════════════════════════════════════════════════════════════════════════════
class _PropertiesPanel extends StatelessWidget {
  final int index;
  final bool isPremium;
  final String activeTab;
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> freeBgs, premiumBgs, allTransitions;
  final String? customBg;
  final double fontSize;
  final Color fontColor;
  final String transition;
  final bool isImproving;
  final String currentTextStyle;
  final String currentTextAlign;
  final int columnsCount;
  final Map<String, TextStylePreset> textStyles;
  final String? chartType;
  final List<Map<String, dynamic>> chartData;
  final List<SlideShape> shapes;
  final double? imageWidth;
  final double? imageHeight;
  final String? imagePosition;
  final String? imageTextWrap;
  final bool hasImage;
  final ValueChanged<String> onTabChange, onFontChange, onTransitionChange, onTextStyleChange, onTextAlignChange;
  final ValueChanged<int> onBgSelect, onColumnsChange;
  final VoidCallback onBgUpload, onImageUpload;
  final ValueChanged<double> onFontSizeChange;
  final ValueChanged<Color> onFontColorChange;
  final ValueChanged<String?> onChartTypeChange;
  final ValueChanged<List<Map<String, dynamic>>> onChartDataChange;
  final ValueChanged<String> onAddShape;
  final ValueChanged<double> onImageWidthChange;
  final ValueChanged<double> onImageHeightChange;
  final ValueChanged<String> onImagePositionChange;
  final ValueChanged<String> onImageTextWrapChange;
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
    required this.currentTextStyle,
    required this.currentTextAlign,
    required this.columnsCount,
    required this.textStyles,
    required this.chartType,
    required this.chartData,
    required this.shapes,
    required this.imageWidth,
    required this.imageHeight,
    required this.imagePosition,
    required this.imageTextWrap,
    required this.hasImage,
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
    required this.onImageWidthChange,
    required this.onImageHeightChange,
    required this.onImagePositionChange,
    required this.onImageTextWrapChange,
    required this.uploadsUsed,
  });

  @override
  Widget build(BuildContext context) => Container(
    color: _T.bgSurface,
    child: Column(children: [
      Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 6), child: Row(children: [
        _Tab('design', 'Дизайн', Icons.palette_rounded, activeTab, onTabChange),
        _Tab('text_style', 'Стили', Icons.text_fields_rounded, activeTab, onTabChange),
        _Tab('align', 'Выравнивание', Icons.format_align_left_rounded, activeTab, onTabChange),
        _Tab('columns', 'Колонки', Icons.view_column_rounded, activeTab, onTabChange),
        _Tab('charts', 'Графики', Icons.show_chart_rounded, activeTab, onTabChange),
        _Tab('shapes', 'Фигуры', Icons.shape_line_rounded, activeTab, onTabChange),
        _Tab('image', 'Изображение', Icons.image_rounded, activeTab, onTabChange),
        _Tab('ai', 'ИИ', Icons.auto_awesome_rounded, activeTab, onTabChange),
      ])),
      const Divider(color: _T.border, height: 1),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: switch (activeTab) {
        'image' => _ImageTab(
            onUpload: onImageUpload,
            isPremium: isPremium,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            imagePosition: imagePosition,
            imageTextWrap: imageTextWrap,
            hasImage: hasImage,
            onWidthChanged: onImageWidthChange,
            onHeightChanged: onImageHeightChange,
            onPositionChanged: onImagePositionChange,
            onTextWrapChanged: onImageTextWrapChange,
          ),
        'ai' => _AiTab(isImproving: isImproving, onImprove: () {}),
        'text_style' => _TextStyleTab(
            currentStyle: currentTextStyle,
            textStyles: textStyles,
            onStyleSelected: onTextStyleChange,
          ),
        'align' => _AlignTab(
            currentAlign: currentTextAlign,
            onAlignSelected: onTextAlignChange,
          ),
        'columns' => _ColumnsTab(
            columnsCount: columnsCount,
            onColumnsChanged: onColumnsChange,
          ),
        'charts' => _ChartsTab(
            currentChartType: chartType,
            chartData: chartData,
            onChartTypeSelected: onChartTypeChange,
            onChartDataChanged: onChartDataChange,
          ),
        'shapes' => _ShapesTab(
            onAddShape: onAddShape,
            currentShapes: shapes,
          ),
        _ => _DesignTab(
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
      })),
    ]),
  );
}

class _Tab extends StatelessWidget {
  final String id, label, active;
  final IconData icon;
  final ValueChanged<String> onTap;
  const _Tab(this.id, this.label, this.icon, this.active, this.onTap);
  @override
  Widget build(BuildContext context) {
    final a = id == active;
    return Expanded(child: GestureDetector(
      onTap: () => onTap(id),
      child: AnimatedContainer(
        duration: _T.fast,
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: a ? _T.accentDim : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: a ? _T.accent.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 12, color: a ? _T.accentLight : _T.txtMuted),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: a ? _T.accentLight : _T.txtMuted)),
        ]),
      ),
    ));
  }
}

// ── DESIGN TAB ────────────────────────────────────────────────────────────────
class _DesignTab extends StatelessWidget {
  final String globalFont;
  final int selectedBgIndex;
  final List<Map<String, dynamic>> freeBgs, premiumBgs, allTransitions;
  final String? customBg;
  final double fontSize;
  final Color fontColor;
  final String transition;
  final bool isPremium;
  final ValueChanged<int> onBgSelect;
  final VoidCallback onBgUpload;
  final ValueChanged<String> onFontChange, onTransitionChange;
  final ValueChanged<double> onFontSizeChange;
  final ValueChanged<Color> onFontColorChange;

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
    Color(0xFF000000),
    Color(0xFF1DB954),
    Color(0xFF4facfe),
    Color(0xFFf5576c),
    Color(0xFFFFD700),
    Color(0xFFf093fb),
    Color(0xFFFF6B35),
  ];

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionLabel('ШРИФТ'), const SizedBox(height: 8),
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
    _SectionLabel('РАЗМЕР ТЕКСТА'), const SizedBox(height: 10),
    Row(children: [
      Expanded(child: SliderTheme(
        data: SliderThemeData(activeTrackColor: _T.accent, inactiveTrackColor: _T.border, thumbColor: _T.accent, overlayColor: _T.accentDim, trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
        child: Slider(value: fontSize, min: 10, max: 28, divisions: 18, onChanged: onFontSizeChange),
      )),
      Container(width: 42, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(6), border: Border.all(color: _T.border)), child: Text('${fontSize.toInt()}', style: const TextStyle(color: _T.txtPrimary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
    ]),
    const SizedBox(height: 18),
    _SectionLabel('ЦВЕТ ТЕКСТА'), const SizedBox(height: 10),
    Wrap(spacing: 7, runSpacing: 7, children: _fontColors.map((c) {
      final s = fontColor.value == c.value;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onFontColorChange(c),
          child: AnimatedContainer(
            duration: _T.fast,
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: s ? _T.accent : Colors.white12, width: s ? 2.5 : 1),
              boxShadow: s ? [BoxShadow(color: _T.accent.withOpacity(0.4), blurRadius: 6)] : null,
            ),
            child: s ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
          ),
        ),
      );
    }).toList()),
    const SizedBox(height: 18),
    _SectionLabel('ФОН'), const SizedBox(height: 8),
    GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1.4,
      children: freeBgs.asMap().entries.map((e) {
        final i = e.key; final bg = e.value;
        final s = i == selectedBgIndex && customBg == null;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onBgSelect(i),
            child: AnimatedContainer(
              duration: _T.fast,
              decoration: BoxDecoration(
                gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: s ? _T.accent : Colors.transparent, width: 2),
                boxShadow: s ? [BoxShadow(color: _T.accent.withOpacity(0.35), blurRadius: 6)] : null,
              ),
              child: s ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 12)) : null,
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
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
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
              if (!isPremium) Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white54, size: 13))),
            ]),
          ),
        );
      }).toList(),
    ),
    const SizedBox(height: 18),
    Row(children: [_SectionLabel('ПЕРЕХОД'), const Spacer(), if (!isPremium) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: _T.gold.withOpacity(0.12), borderRadius: BorderRadius.circular(4)), child: const Text('2 бесплатно', style: TextStyle(color: _T.gold, fontSize: 9, fontWeight: FontWeight.w700)))]),
    const SizedBox(height: 8),
    GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 2.0,
      children: allTransitions.map((t) {
        final pr = t['premium'] as bool;
        final locked = pr && !isPremium;
        final s = transition == t['id'];
        return MouseRegion(
          cursor: locked ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: locked ? null : () => onTransitionChange(t['id'] as String),
            child: AnimatedContainer(
              duration: _T.fast,
              decoration: BoxDecoration(color: s ? _T.accentDim : _T.bgCard, borderRadius: BorderRadius.circular(8), border: Border.all(color: s ? _T.accent.withOpacity(0.5) : _T.border)),
              child: Stack(alignment: Alignment.center, children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(t['icon'] as IconData, size: 16, color: locked ? _T.txtMuted : s ? _T.accent : _T.txtSecondary),
                  const SizedBox(height: 3),
                  Text(t['label'] as String, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: locked ? _T.txtMuted : s ? _T.accent : _T.txtSecondary)),
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

// ── TEXT STYLE TAB ────────────────────────────────────────────────────────────
class _TextStyleTab extends StatelessWidget {
  final String currentStyle;
  final Map<String, TextStylePreset> textStyles;
  final ValueChanged<String> onStyleSelected;

  const _TextStyleTab({
    required this.currentStyle,
    required this.textStyles,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('СТИЛИ ТЕКСТА'), const SizedBox(height: 12),
      ...textStyles.entries.map((entry) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onStyleSelected(entry.key),
          child: AnimatedContainer(
            duration: _T.fast,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: currentStyle == entry.key ? _T.accentDim : _T.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: currentStyle == entry.key ? _T.accent.withOpacity(0.4) : _T.border),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(color: _T.accent, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(entry.value.name, style: const TextStyle(color: _T.txtPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${entry.value.fontSize.toInt()}px • ${entry.value.fontWeight == FontWeight.w800 ? 'Жирный' : entry.value.fontWeight == FontWeight.w700 ? 'Полужирный' : 'Обычный'}', style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
                ]),
              ),
              if (currentStyle == entry.key) const Icon(Icons.check_circle_rounded, color: _T.accent, size: 20),
            ]),
          ),
        ),
      )),
    ]);
  }
}

// ── ALIGN TAB ─────────────────────────────────────────────────────────────────
class _AlignTab extends StatelessWidget {
  final String currentAlign;
  final ValueChanged<String> onAlignSelected;

  const _AlignTab({
    required this.currentAlign,
    required this.onAlignSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ВЫРАВНИВАНИЕ'), const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _AlignButton(Icons.format_align_left_rounded, 'left', currentAlign == 'left', onAlignSelected),
        _AlignButton(Icons.format_align_center_rounded, 'center', currentAlign == 'center', onAlignSelected),
        _AlignButton(Icons.format_align_right_rounded, 'right', currentAlign == 'right', onAlignSelected),
      ]),
    ]);
  }
}

class _AlignButton extends StatelessWidget {
  final IconData icon;
  final String align;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _AlignButton(this.icon, this.align, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(align),
        child: AnimatedContainer(
          duration: _T.fast,
          width: 60, height: 50,
          decoration: BoxDecoration(
            color: isSelected ? _T.accentDim : _T.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? _T.accent.withOpacity(0.5) : _T.border),
          ),
          child: Icon(icon, color: isSelected ? _T.accent : _T.txtSecondary, size: 24),
        ),
      ),
    );
  }
}

// ── COLUMNS TAB ───────────────────────────────────────────────────────────────
class _ColumnsTab extends StatelessWidget {
  final int columnsCount;
  final ValueChanged<int> onColumnsChanged;

  const _ColumnsTab({
    required this.columnsCount,
    required this.onColumnsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('КОЛИЧЕСТВО КОЛОНОК'),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _ColumnButton(1, '1 колонка', columnsCount == 1, onColumnsChanged),
        _ColumnButton(2, '2 колонки', columnsCount == 2, onColumnsChanged),
        _ColumnButton(3, '3 колонки', columnsCount == 3, onColumnsChanged),
        _ColumnButton(4, '4 колонки', columnsCount == 4, onColumnsChanged),
      ]),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _T.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _T.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: _T.accent, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Контент автоматически распределится по колонкам',
                style: TextStyle(color: _T.txtSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

class _ColumnButton extends StatelessWidget {
  final int count;
  final String label;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _ColumnButton(this.count, this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(count),
        child: AnimatedContainer(
          duration: _T.fast,
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: isSelected ? _T.accentDim : _T.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? _T.accent.withOpacity(0.5) : _T.border),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(count, (_) => Container(width: 8, height: 20, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(color: isSelected ? _T.accent : _T.txtMuted, borderRadius: BorderRadius.circular(2))))),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: isSelected ? _T.accent : _T.txtSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ── CHARTS TAB ────────────────────────────────────────────────────────────────
class _ChartsTab extends StatefulWidget {
  final String? currentChartType;
  final List<Map<String, dynamic>> chartData;
  final ValueChanged<String?> onChartTypeSelected;
  final ValueChanged<List<Map<String, dynamic>>> onChartDataChanged;

  const _ChartsTab({
    required this.currentChartType,
    required this.chartData,
    required this.onChartTypeSelected,
    required this.onChartDataChanged,
  });

  @override
  State<_ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<_ChartsTab> {
  final List<TextEditingController> _labelControllers = [];
  final List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _labelControllers.clear();
    _valueControllers.clear();
    
    if (widget.chartData.isEmpty) {
      _addDataPoint();
      _addDataPoint();
      _addDataPoint();
      _addDataPoint();
    } else {
      for (var item in widget.chartData) {
        _labelControllers.add(TextEditingController(text: item['label']));
        _valueControllers.add(TextEditingController(text: item['value'].toString()));
      }
    }
  }

  void _updateData() {
    final List<Map<String, dynamic>> newData = [];
    for (int i = 0; i < _labelControllers.length; i++) {
      final label = _labelControllers[i].text;
      final value = double.tryParse(_valueControllers[i].text) ?? 0;
      if (label.isNotEmpty && value > 0) {
        newData.add({'label': label, 'value': value});
      }
    }
    widget.onChartDataChanged(newData);
  }

  void _addDataPoint() {
    setState(() {
      _labelControllers.add(TextEditingController(text: 'Категория'));
      _valueControllers.add(TextEditingController(text: '100'));
    });
  }

  void _removeDataPoint(int index) {
    setState(() {
      _labelControllers[index].dispose();
      _valueControllers[index].dispose();
      _labelControllers.removeAt(index);
      _valueControllers.removeAt(index);
    });
    _updateData();
  }

  @override
  void dispose() {
    for (var c in _labelControllers) c.dispose();
    for (var c in _valueControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ТИП ГРАФИКА'),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _ChartTypeButton(
          icon: Icons.bar_chart_rounded,
          label: 'Столбчатый',
          type: 'bar',
          isSelected: widget.currentChartType == 'bar',
          onTap: () => widget.onChartTypeSelected('bar'),
        ),
        _ChartTypeButton(
          icon: Icons.pie_chart_rounded,
          label: 'Круговой',
          type: 'pie',
          isSelected: widget.currentChartType == 'pie',
          onTap: () => widget.onChartTypeSelected('pie'),
        ),
        _ChartTypeButton(
          icon: Icons.show_chart_rounded,
          label: 'Линейный',
          type: 'line',
          isSelected: widget.currentChartType == 'line',
          onTap: () => widget.onChartTypeSelected('line'),
        ),
        _ChartTypeButton(
          icon: Icons.clear_rounded,
          label: 'Удалить',
          type: null,
          isSelected: widget.currentChartType == null,
          onTap: () => widget.onChartTypeSelected(null),
        ),
      ]),
      const SizedBox(height: 24),
      if (widget.currentChartType != null) ...[
        _SectionLabel('ДАННЫЕ'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.border),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _labelControllers.length,
            separatorBuilder: (_, __) => const Divider(color: _T.border, height: 1),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _labelControllers[i],
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Метка',
                      hintStyle: TextStyle(color: _T.txtMuted),
                      filled: true,
                      fillColor: _T.bgSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onChanged: (_) => _updateData(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _valueControllers[i],
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Знач.',
                      hintStyle: TextStyle(color: _T.txtMuted),
                      filled: true,
                      fillColor: _T.bgSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onChanged: (_) => _updateData(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _removeDataPoint(i),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _T.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.close_rounded, color: _T.danger, size: 16),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _addDataPoint,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _T.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_rounded, color: _T.accent, size: 18),
                SizedBox(width: 8),
                Text('Добавить данные', style: TextStyle(color: _T.accent, fontSize: 13, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _T.border),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: _T.accent, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('График будет отображаться на слайде. Цвета настраиваются автоматически.', style: TextStyle(color: _T.txtSecondary, fontSize: 11))),
          ]),
        ),
      ],
    ]);
  }
}

class _ChartTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTypeButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: isSelected ? _T.accentDim : _T.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? _T.accent.withOpacity(0.5) : _T.border),
            ),
            child: Icon(icon, color: isSelected ? _T.accent : _T.txtSecondary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? _T.accent : _T.txtSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── SHAPES TAB ────────────────────────────────────────────────────────────────
class _ShapesTab extends StatelessWidget {
  final ValueChanged<String> onAddShape;
  final List<SlideShape> currentShapes;

  const _ShapesTab({
    required this.onAddShape,
    required this.currentShapes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ДОБАВИТЬ ФИГУРУ'),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _ShapeButton(
          icon: Icons.circle_rounded,
          label: 'Круг',
          type: 'circle',
          onTap: () => onAddShape('circle'),
        ),
        _ShapeButton(
          icon: Icons.square_rounded,
          label: 'Квадрат',
          type: 'square',
          onTap: () => onAddShape('square'),
        ),
        _ShapeButton(
          icon: Icons.rectangle_rounded,
          label: 'Прямоугольник',
          type: 'rectangle',
          onTap: () => onAddShape('rectangle'),
        ),
        _ShapeButton(
          icon: Icons.triangle_rounded,
          label: 'Треугольник',
          type: 'triangle',
          onTap: () => onAddShape('triangle'),
        ),
        _ShapeButton(
          icon: Icons.star_rounded,
          label: 'Звезда',
          type: 'star',
          onTap: () => onAddShape('star'),
        ),
      ]),
      const SizedBox(height: 24),
      if (currentShapes.isNotEmpty) ...[
        _SectionLabel('ФИГУРЫ НА СЛАЙДЕ'),
        const SizedBox(height: 12),
        ...currentShapes.map((shape) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _T.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _T.border),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: shape.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getShapeIcon(shape.type), color: shape.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_getShapeName(shape.type), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text('Размер: ${shape.width.toInt()}x${shape.height.toInt()}', style: const TextStyle(color: _T.txtSecondary, fontSize: 11)),
              ]),
            ),
            GestureDetector(
              onTap: () => onAddShape('remove_${shape.id}'),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.delete_outline_rounded, color: _T.danger, size: 18),
              ),
            ),
          ]),
        )),
      ],
    ]);
  }

  IconData _getShapeIcon(String type) {
    switch (type) {
      case 'circle': return Icons.circle_rounded;
      case 'square': return Icons.square_rounded;
      case 'rectangle': return Icons.rectangle_rounded;
      case 'triangle': return Icons.triangle_rounded;
      case 'star': return Icons.star_rounded;
      default: return Icons.shape_line_rounded;
    }
  }

  String _getShapeName(String type) {
    switch (type) {
      case 'circle': return 'Круг';
      case 'square': return 'Квадрат';
      case 'rectangle': return 'Прямоугольник';
      case 'triangle': return 'Треугольник';
      case 'star': return 'Звезда';
      default: return 'Фигура';
    }
  }
}

class _ShapeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;
  final VoidCallback onTap;

  const _ShapeButton({
    required this.icon,
    required this.label,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              color: _T.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.border),
            ),
            child: Icon(icon, color: _T.accent, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: _T.txtSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

// ── IMAGE TAB ─────────────────────────────────────────────────────────────────
class _ImageTab extends StatefulWidget {
  final VoidCallback onUpload;
  final bool isPremium;
  final double? imageWidth;
  final double? imageHeight;
  final String? imagePosition;
  final String? imageTextWrap;
  final bool hasImage;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<String> onPositionChanged;
  final ValueChanged<String> onTextWrapChanged;

  const _ImageTab({
    required this.onUpload,
    required this.isPremium,
    this.imageWidth,
    this.imageHeight,
    this.imagePosition,
    this.imageTextWrap,
    required this.hasImage,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onPositionChanged,
    required this.onTextWrapChanged,
  });

  @override
  State<_ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<_ImageTab> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel('ИЗОБРАЖЕНИЕ НА СЛАЙДЕ'),
      const SizedBox(height: 8),
      
      if (!widget.isPremium)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _T.gold.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _T.gold.withOpacity(0.2)),
          ),
          child: Row(children: const [
            Icon(Icons.star_rounded, color: _T.gold, size: 14),
            SizedBox(width: 8),
            Expanded(child: Text('Замена изображений — Premium.', style: TextStyle(color: _T.gold, fontSize: 11, fontWeight: FontWeight.w500))),
          ]),
        ),
      
      MouseRegion(
        cursor: widget.isPremium ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTap: widget.isPremium ? widget.onUpload : null,
          child: AnimatedContainer(
            duration: _T.fast,
            width: double.infinity,
            height: widget.hasImage ? 80 : 100,
            decoration: BoxDecoration(
              color: _T.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.isPremium ? _T.border : _T.border.withOpacity(0.4)),
            ),
            child: Opacity(
              opacity: widget.isPremium ? 1.0 : 0.4,
              child: widget.hasImage
                  ? const Center(child: Text('Заменить изображение', style: TextStyle(color: _T.txtSecondary, fontSize: 13)))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: _T.accentDim, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.image_rounded, color: _T.accent, size: 20)),
                      const SizedBox(height: 8),
                      const Text('Нажмите для загрузки', style: TextStyle(color: _T.txtSecondary, fontSize: 12)),
                      const Text('PNG, JPG до 10 МБ', style: TextStyle(color: _T.txtMuted, fontSize: 10)),
                    ]),
            ),
          ),
        ),
      ),
      
      if (widget.hasImage) ...[
        const SizedBox(height: 16),
        const Divider(color: _T.border),
        const SizedBox(height: 16),
        
        _SectionLabel('РАЗМЕР'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ширина', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
              Slider(
                value: widget.imageWidth ?? 0.28,
                min: 0.1,
                max: 0.6,
                divisions: 10,
                onChanged: widget.onWidthChanged,
                activeColor: _T.accent,
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Высота', style: TextStyle(color: _T.txtSecondary, fontSize: 11)),
              Slider(
                value: widget.imageHeight ?? 0.55,
                min: 0.1,
                max: 0.8,
                divisions: 10,
                onChanged: widget.onHeightChanged,
                activeColor: _T.accent,
              ),
            ]),
          ),
        ]),
        
        const SizedBox(height: 16),
        _SectionLabel('ПОЗИЦИЯ'),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _PositionButton(Icons.format_align_left_rounded, 'left', widget.imagePosition == 'left', widget.onPositionChanged),
          _PositionButton(Icons.format_align_right_rounded, 'right', widget.imagePosition == 'right', widget.onPositionChanged),
          _PositionButton(Icons.vertical_align_top_rounded, 'top', widget.imagePosition == 'top', widget.onPositionChanged),
          _PositionButton(Icons.vertical_align_bottom_rounded, 'bottom', widget.imagePosition == 'bottom', widget.onPositionChanged),
        ]),
        
        const SizedBox(height: 16),
        _SectionLabel('ОБТЕКАНИЕ'),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _WrapButton('Вокруг', 'around', widget.imageTextWrap == 'around', widget.onTextWrapChanged),
          _WrapButton('Сверху', 'above', widget.imageTextWrap == 'above', widget.onTextWrapChanged),
          _WrapButton('Снизу', 'below', widget.imageTextWrap == 'below', widget.onTextWrapChanged),
          _WrapButton('Нет', 'none', widget.imageTextWrap == 'none', widget.onTextWrapChanged),
        ]),
      ],
      
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _T.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _T.border),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, color: _T.accent, size: 14),
          SizedBox(width: 8),
          Expanded(child: Text('Unsplash подбирает изображение автоматически.', style: TextStyle(color: _T.txtSecondary, fontSize: 11))),
        ]),
      ),
    ]);
  }
}

class _PositionButton extends StatelessWidget {
  final IconData icon;
  final String position;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _PositionButton(this.icon, this.position, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(position),
        child: AnimatedContainer(
          duration: _T.fast,
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: isSelected ? _T.accentDim : _T.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? _T.accent.withOpacity(0.5) : _T.border),
          ),
          child: Icon(icon, color: isSelected ? _T.accent : _T.txtSecondary, size: 24),
        ),
      ),
    );
  }
}

class _WrapButton extends StatelessWidget {
  final String label;
  final String wrapType;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _WrapButton(this.label, this.wrapType, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onTap(wrapType),
        child: AnimatedContainer(
          duration: _T.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? _T.accentDim : _T.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? _T.accent.withOpacity(0.5) : _T.border),
          ),
          child: Text(label, style: TextStyle(color: isSelected ? _T.accent : _T.txtSecondary, fontSize: 12)),
        ),
      ),
    );
  }
}

// ── AI TAB ────────────────────────────────────────────────────────────────────
class _AiTab extends StatelessWidget {
  final bool isImproving;
  final VoidCallback onImprove;
  const _AiTab({required this.isImproving, required this.onImprove});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _SectionLabel('ИИ ПОМОЩНИК'), const SizedBox(height: 12),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_T.accent.withOpacity(0.08), _T.accentLight.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.accent.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Улучшить текст', style: TextStyle(color: _T.txtPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('Текущий слайд', style: TextStyle(color: _T.txtMuted, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 12),
        const Text('ИИ перепишет заголовок и пункты.', style: TextStyle(color: _T.txtSecondary, fontSize: 12, height: 1.4)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: isImproving ? null : onImprove,
            child: AnimatedContainer(
              duration: _T.fast,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isImproving ? null : const LinearGradient(colors: [Color(0xFF169C46), _T.accent, _T.accentLight], begin: Alignment.centerLeft, end: Alignment.centerRight),
                color: isImproving ? _T.bgHover : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: isImproving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: _T.accent, strokeWidth: 2)) : const Text('Улучшить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))),
            ),
          ),
        ),
      ]),
    ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════════
// EXPORT SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _ExportSheet extends StatelessWidget {
  final bool isPremium;
  final Presentation presentation;
  const _ExportSheet({required this.isPremium, required this.presentation});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
    decoration: BoxDecoration(color: _T.bgSurface, borderRadius: _T.r16, border: Border.all(color: _T.border)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.only(top: 12, bottom: 16), child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _T.border, borderRadius: BorderRadius.circular(2)))),
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

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final String? badge;
  final bool locked;
  final VoidCallback? onTap;
  const _ExportOption({required this.icon, required this.color, required this.title, required this.subtitle, this.badge, this.locked = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Opacity(
      opacity: locked ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: _T.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border)),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: _T.txtPrimary, fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(color: _T.txtSecondary, fontSize: 11))])),
          if (badge != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_T.accent, _T.accentLight]), borderRadius: BorderRadius.circular(5)), child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
          if (locked) const Icon(Icons.lock_rounded, color: _T.txtMuted, size: 16),
          if (!locked && badge == null) const Icon(Icons.arrow_forward_ios_rounded, color: _T.txtMuted, size: 12),
        ]),
      ),
    ),
  );
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
  Widget build(BuildContext context) => Container(
    height: 48,
    color: _T.bgSurface,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(children: [
      _IconBtn(Icons.undo_rounded, () {}, size: 16, tooltip: 'Отменить'),
      _IconBtn(Icons.redo_rounded, () {}, size: 16, tooltip: 'Повторить'),
      const SizedBox(width: 8),
      Container(width: 1, height: 24, color: _T.border),
      const SizedBox(width: 8),
      _IconBtn(Icons.copy_rounded, onDuplicate, size: 15, tooltip: 'Дублировать'),
      _IconBtn(Icons.delete_outline_rounded, onDelete, size: 15, tooltip: 'Удалить', danger: true),
      _IconBtn(Icons.template_rounded, onTemplate, size: 16, tooltip: 'Шаблоны слайдов'),
      const Spacer(),
      _IconBtn(Icons.arrow_back_rounded, onPrev, size: 16, disabled: activeSlide == 0),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('${activeSlide + 1} / $totalSlides', style: const TextStyle(color: _T.txtSecondary, fontSize: 13, fontWeight: FontWeight.w600))),
      _IconBtn(Icons.arrow_forward_rounded, onNext, size: 16, disabled: activeSlide == totalSlides - 1),
      const Spacer(),
      _IconBtn(propsPanelOpen ? Icons.view_sidebar : Icons.view_sidebar_outlined, onToggleProps, size: 16, tooltip: propsPanelOpen ? 'Скрыть панель' : 'Показать панель', active: propsPanelOpen),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override Widget build(BuildContext context) => Text(text, style: const TextStyle(color: _T.txtMuted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8));
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String? tooltip;
  final bool danger, active, disabled;
  const _IconBtn(this.icon, this.onTap, {this.size = 18, this.tooltip, this.danger = false, this.active = false, this.disabled = false});
  @override State<_IconBtn> createState() => _IconBtnState();
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _hovered && !widget.disabled ? _T.bgHover : Colors.transparent, borderRadius: BorderRadius.circular(8)),
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