import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/image_service.dart';
import 'share_screen.dart';

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Presentation _presentation;
  late List<TextEditingController> _titleControllers;
  late List<List<TextEditingController>> _contentControllers;

  String _fontPair = 'Inter';
  int _selectedBgIndex = 0;

  final Map<int, String?> _slideImages = {};
  final Map<int, Offset> _imagePositions = {};
  final Map<int, double> _imageSizes = {};
  bool _imagesLoading = false;

  final List<Map<String, dynamic>> _basicBackgrounds = [
    {'type': 'solid', 'color': Colors.white, 'label': 'Белый'},
    {'type': 'gradient', 'colors': [const Color(0xFF667eea), const Color(0xFF764ba2)], 'label': 'Фиолетовый'},
    {'type': 'gradient', 'colors': [const Color(0xFFf093fb), const Color(0xFFf5576c)], 'label': 'Розовый'},
    {'type': 'gradient', 'colors': [const Color(0xFF4facfe), const Color(0xFF00f2fe)], 'label': 'Голубой'},
    {'type': 'solid', 'color': const Color(0xFF0F0F1A), 'label': 'Тёмный'},
    {'type': 'gradient', 'colors': [const Color(0xFF434343), const Color(0xFF000000)], 'label': 'Чёрный'},
    {'type': 'gradient', 'colors': [const Color(0xFFFFE000), const Color(0xFF799F0C)], 'label': 'Зелёный'},
    {'type': 'solid', 'color': const Color(0xFFFFF8E7), 'label': 'Кремовый'},
  ];

  final List<Map<String, dynamic>> _premiumBackgrounds = [
    {'type': 'gradient', 'colors': [const Color(0xFF1DB954), const Color(0xFF191414)], 'label': 'Spotify'},
    {'type': 'gradient', 'colors': [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], 'label': 'Закат'},
    {'type': 'gradient', 'colors': [const Color(0xFF00b4db), const Color(0xFF0083B0)], 'label': 'Океан'},
    {'type': 'gradient', 'colors': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], 'label': 'Неон'},
    {'type': 'gradient', 'colors': [const Color(0xFF11998e), const Color(0xFF38ef7d)], 'label': 'Neo Mint'},
    {'type': 'solid', 'color': const Color(0xFF1A1A2E), 'label': 'Midnight'},
  ];

  final List<Map<String, String>> _fontOptions = [
    {'name': 'Inter', 'label': 'Современный'},
    {'name': 'Georgia', 'label': 'Элегантный'},
    {'name': 'Courier', 'label': 'Моноширинный'},
  ];

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _initControllers();
    _loadImages();
  }

  void _initControllers() {
    _titleControllers = _presentation.slides
        .map((s) => TextEditingController(text: s.title))
        .toList();
    _contentControllers = _presentation.slides
        .map((s) => s.content.map((c) => TextEditingController(text: c)).toList())
        .toList();
  }

  Future<void> _loadImages() async {
    setState(() => _imagesLoading = true);
    for (int i = 0; i < _presentation.slides.length; i++) {
      final query = _titleControllers[i].text.isNotEmpty
          ? _titleControllers[i].text
          : _presentation.title;
      final imageUrl = await ImageService.searchImage(query);
      _slideImages[i] = imageUrl;
      // Начальная позиция — правый верхний угол
      _imagePositions[i] = const Offset(0.6, 0.08);
      _imageSizes[i] = 0.3;
    }
    setState(() => _imagesLoading = false);
  }

  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title = _titleControllers[i].text;
      _presentation.slides[i].content = _contentControllers[i].map((c) => c.text).toList();
    }
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Максимум ${up.maxSlidesPerPresentation} слайдов')),
      );
      return;
    }
    setState(() {
      _presentation.slides.add(Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleControllers.add(TextEditingController(text: 'Новый слайд'));
      _contentControllers.add([TextEditingController(text: 'Введите текст')]);
    });
  }

  void _deleteSlide(int index) {
    if (_presentation.slides.length <= 1) return;
    setState(() {
      _presentation.slides.removeAt(index);
      _titleControllers[index].dispose();
      for (var c in _contentControllers[index]) { c.dispose(); }
      _titleControllers.removeAt(index);
      _contentControllers.removeAt(index);
      _slideImages.remove(index);
      _imagePositions.remove(index);
      _imageSizes.remove(index);
    });
  }

  void _duplicateSlide(int index) {
    setState(() {
      final slide = _presentation.slides[index];
      _presentation.slides.insert(index + 1, Slide(title: '${slide.title} (копия)', content: List.from(slide.content)));
      _titleControllers.insert(index + 1, TextEditingController(text: '${slide.title} (копия)'));
      _contentControllers.insert(index + 1, slide.content.map((c) => TextEditingController(text: c)).toList());
    });
  }

  void _addContentItem(int slideIndex) {
    setState(() {
      _contentControllers[slideIndex].add(TextEditingController(text: 'Новый пункт'));
    });
  }

  void _removeContentItem(int slideIndex, int itemIndex) {
    if (_contentControllers[slideIndex].length <= 1) return;
    setState(() {
      _contentControllers[slideIndex][itemIndex].dispose();
      _contentControllers[slideIndex].removeAt(itemIndex);
    });
  }

  Future<void> _improveSlide(int index) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))),
    );
    try {
      final improvedTitle = await AiImproveService.improveText(_titleControllers[index].text);
      final improvedContent = <String>[];
      for (final c in _contentControllers[index]) {
        improvedContent.add(await AiImproveService.improveText(c.text));
      }
      Navigator.pop(context);
      setState(() {
        _titleControllers[index].text = improvedTitle;
        for (int i = 0; i < improvedContent.length && i < _contentControllers[index].length; i++) {
          _contentControllers[index][i].text = improvedContent[i];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Текст улучшен!'), backgroundColor: Color(0xFF1DB954)),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Decoration _getSlideDecoration() {
    final bg = _basicBackgrounds[_selectedBgIndex];
    if (bg['type'] == 'gradient') {
      final colors = bg['colors'] as List<Color>;
      return BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
      );
    }
    return BoxDecoration(
      color: bg['color'] as Color,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
    );
  }

  bool get _isDark {
    final bg = _basicBackgrounds[_selectedBgIndex];
    if (bg['type'] == 'solid') return (bg['color'] as Color).computeLuminance() < 0.5;
    return true;
  }

  void _showBgPicker() {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, maxChildSize: 0.8, minChildSize: 0.3, expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            const Text('Выбор фона', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Бесплатные', style: TextStyle(fontSize: 11, color: Colors.white38)),
            const SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1,
              children: _basicBackgrounds.asMap().entries.map((entry) {
                final i = entry.key;
                final bg = entry.value;
                return GestureDetector(
                  onTap: () { setState(() => _selectedBgIndex = i); Navigator.pop(ctx); },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                      color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: i == _selectedBgIndex ? const Color(0xFF1DB954) : Colors.white10, width: 2),
                    ),
                    child: i == _selectedBgIndex ? const Center(child: Icon(Icons.check, color: Color(0xFF1DB954))) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Row(children: [Icon(Icons.star, color: Color(0xFFFFD700), size: 14), SizedBox(width: 4), Text('Premium', style: TextStyle(fontSize: 11, color: Color(0xFFFFD700)))]),
            const SizedBox(height: 6),
            GridView.count(
              crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1,
              children: _premiumBackgrounds.map((bg) {
                return GestureDetector(
                  onTap: isPremium
                      ? () { setState(() { _selectedBgIndex = _basicBackgrounds.length; _basicBackgrounds.add(bg); }); Navigator.pop(ctx); }
                      : () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Доступно в Premium'), backgroundColor: Color(0xFFFFD700))); },
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                        color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (!isPremium) Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.lock, color: Colors.white38, size: 14))),
                  ]),
                );
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Шрифт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            ..._fontOptions.map((f) => ListTile(
              title: Text(f['label']!, style: TextStyle(fontFamily: f['name'], color: Colors.white, fontSize: 16)),
              trailing: _fontPair == f['name'] ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
              onTap: () { setState(() => _fontPair = f['name']!); Navigator.pop(ctx); },
            )),
          ]),
        ),
      ),
    );
  }

  void _export() {
    _saveAll();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Экспорт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 16),
            ListTile(leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954)), title: const Text('PPTX', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком', style: const TextStyle(color: Colors.grey)), onTap: () { Navigator.pop(ctx); ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium); }),
            ListTile(leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey), title: const Text('PDF', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Доступно' : 'Premium', style: const TextStyle(color: Colors.grey)), onTap: isPremium ? () { Navigator.pop(ctx); ExportService.exportToPDF(presentation: _presentation, isPremium: true); } : null),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (var c in _titleControllers) { c.dispose(); }
    for (var list in _contentControllers) { for (var c in list) { c.dispose(); } }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(_presentation.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _showFontPicker, icon: const Icon(Icons.text_fields, color: Color(0xFF1DB954), size: 18), tooltip: 'Шрифт'),
          IconButton(onPressed: _showBgPicker, icon: const Icon(Icons.palette, color: Color(0xFF1DB954), size: 18), tooltip: 'Фон'),
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1DB954), size: 22), tooltip: 'Добавить'),
          IconButton(onPressed: _export, icon: const Icon(Icons.download, color: Colors.white70, size: 20), tooltip: 'Экспорт'),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: _presentation.slides.length,
        itemBuilder: (context, index) => _buildSlideCard(index),
      ),
    );
  }

  Widget _buildSlideCard(int index) {
    final dark = _isDark;
    final hasImage = _slideImages.containsKey(index) && _slideImages[index] != null;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          color: const Color(0xFF1E1E1E),
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Превью слайда
              AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final slideWidth = constraints.maxWidth;
                    final slideHeight = constraints.maxHeight;
                    final imgSize = (_imageSizes[index] ?? 0.3) * slideWidth;
                    final imgPos = _imagePositions[index] ?? const Offset(0.6, 0.08);
                    // Границы чтобы картинка не выходила за слайд
                    final clampedX = imgPos.dx.clamp(0.0, 1.0 - (_imageSizes[index] ?? 0.3));
                    final clampedY = imgPos.dy.clamp(0.0, 1.0 - (_imageSizes[index] ?? 0.3) * (16 / 9));
                    final imgLeft = clampedX * slideWidth;
                    final imgTop = clampedY * slideHeight;

                    return Container(
                      decoration: _getSlideDecoration(),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(children: [
                        // Контент
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: dark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text('${index + 1}/${_presentation.slides.length}', style: TextStyle(fontSize: 8, color: dark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                _titleControllers[index].text.isEmpty ? 'Заголовок' : _titleControllers[index].text,
                                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, fontFamily: _fontPair, color: dark ? Colors.white : const Color(0xFF1A1A2E), height: 1.2),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              ..._contentControllers[index].take(3).map((ctrl) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.h, right: 4.w),
                                      child: Container(width: 3.w, height: 3.w, decoration: BoxDecoration(color: dark ? const Color(0xFF1DB954) : const Color(0xFF169C46), shape: BoxShape.circle)),
                                    ),
                                    Expanded(
                                      child: Text(
                                        ctrl.text.isEmpty ? 'Пункт...' : ctrl.text,
                                        style: TextStyle(fontSize: 9.sp, fontFamily: _fontPair, color: dark ? Colors.white.withOpacity(0.8) : const Color(0xFF444444), height: 1.3),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                );
                              }),
                            ],
                          ),
                        ),
                        // Перетаскиваемая картинка
                        if (hasImage)
                          Positioned(
                            left: imgLeft,
                            top: imgTop,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  final newDx = (imgLeft + details.delta.dx) / slideWidth;
                                  final newDy = (imgTop + details.delta.dy) / slideHeight;
                                  final maxDx = 1.0 - _imageSizes[index]!;
                                  final maxDy = 1.0 - _imageSizes[index]! * (16 / 9);
                                  _imagePositions[index] = Offset(
                                    newDx.clamp(0.0, maxDx),
                                    newDy.clamp(0.0, maxDy),
                                  );
                                });
                              },
                              child: Stack(children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    _slideImages[index]!,
                                    width: imgSize,
                                    height: imgSize * 0.7,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                                // Рамка при перетаскивании
                                Container(
                                  width: imgSize,
                                  height: imgSize * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.6), width: 1),
                                  ),
                                ),
                                // Маркер изменения размера (тянуть за правый нижний угол)
                                Positioned(
                                  right: 0, bottom: 0,
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        final newSize = (_imageSizes[index]! * slideWidth + details.delta.dx) / slideWidth;
                                        _imageSizes[index] = newSize.clamp(0.15, 0.55);
                                        // Проверяем границы после изменения размера
                                        final pos = _imagePositions[index]!;
                                        final maxDx = 1.0 - _imageSizes[index]!;
                                        final maxDy = 1.0 - _imageSizes[index]! * (16 / 9);
                                        _imagePositions[index] = Offset(
                                          pos.dx.clamp(0.0, maxDx),
                                          pos.dy.clamp(0.0, maxDy),
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: 14.w, height: 14.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1DB954),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: Colors.white, width: 1.5),
                                      ),
                                      child: const Icon(Icons.drag_indicator, size: 10, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                      ]),
                    );
                  },
                ),
              ),
              // Редактор
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF169C46)]), borderRadius: BorderRadius.circular(4)),
                      child: Text('Слайд ${index + 1}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 9)),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () => _improveSlide(index), icon: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF1DB954)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    IconButton(onPressed: () => _duplicateSlide(index), icon: const Icon(Icons.copy, size: 14, color: Colors.white54), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    IconButton(onPressed: () => _deleteSlide(index), icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ]),
                  TextField(
                    controller: _titleControllers[index],
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    decoration: InputDecoration(hintText: 'Заголовок', hintStyle: TextStyle(color: Colors.white24, fontSize: 11), border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                  ),
                  ..._contentControllers[index].asMap().entries.map((entry) {
                    final i = entry.key;
                    final ctrl = entry.value;
                    return Row(children: [
                      Padding(padding: EdgeInsets.only(right: 4.w), child: Container(width: 3.w, height: 3.w, decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle))),
                      Expanded(child: TextField(controller: ctrl, style: TextStyle(fontSize: 10, color: Colors.white70), decoration: InputDecoration(hintText: 'Пункт ${i + 1}', hintStyle: TextStyle(color: Colors.white12, fontSize: 10), border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true))),
                      IconButton(onPressed: () => _removeContentItem(index, i), icon: const Icon(Icons.close, size: 10, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                    ]);
                  }),
                  TextButton.icon(
                    onPressed: () => _addContentItem(index),
                    icon: const Icon(Icons.add, size: 10, color: Color(0xFF1DB954)),
                    label: const Text('Пункт', style: TextStyle(color: Color(0xFF1DB954), fontSize: 9)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}