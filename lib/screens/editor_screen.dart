import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
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

  // Базовые фоны (бесплатно)
  final List<Map<String, dynamic>> _basicBackgrounds = [
    {'type': 'solid', 'color': Colors.white, 'label': 'Белый'},
    {'type': 'gradient', 'colors': [Color(0xFF667eea), Color(0xFF764ba2)], 'label': 'Фиолетовый'},
    {'type': 'gradient', 'colors': [Color(0xFFf093fb), Color(0xFFf5576c)], 'label': 'Розовый'},
    {'type': 'gradient', 'colors': [Color(0xFF4facfe), Color(0xFF00f2fe)], 'label': 'Голубой'},
    {'type': 'solid', 'color': Color(0xFF0F0F1A), 'label': 'Тёмный'},
    {'type': 'gradient', 'colors': [Color(0xFF434343), Color(0xFF000000)], 'label': 'Чёрный'},
    {'type': 'gradient', 'colors': [Color(0xFFFFE000), Color(0xFF799F0C)], 'label': 'Зелёный'},
    {'type': 'solid', 'color': Color(0xFFFFF8E7), 'label': 'Кремовый'},
  ];

  // Премиум фоны
  final List<Map<String, dynamic>> _premiumBackgrounds = [
    {'type': 'gradient', 'colors': [Color(0xFF1DB954), Color(0xFF191414)], 'label': 'Spotify'},
    {'type': 'gradient', 'colors': [Color(0xFFFF416C), Color(0xFFFF4B2B)], 'label': 'Закат'},
    {'type': 'gradient', 'colors': [Color(0xFF00b4db), Color(0xFF0083B0)], 'label': 'Океан'},
    {'type': 'gradient', 'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)], 'label': 'Неон'},
    {'type': 'gradient', 'colors': [Color(0xFFDCE35B), Color(0xFF45B649)], 'label': 'Летний'},
    {'type': 'gradient', 'colors': [Color(0xFFFC5C7D), Color(0xFF6A82FB)], 'label': 'Синергия'},
    {'type': 'solid', 'color': Color(0xFF1A1A2E), 'label': 'Midnight'},
    {'type': 'gradient', 'colors': [Color(0xFFC33764), Color(0xFF1D2671)], 'label': 'Глубина'},
    {'type': 'gradient', 'colors': [Color(0xFFFEAC6E), Color(0xFFC779D0), Color(0xFF4BC0C8)], 'label': 'Триколор'},
    {'type': 'gradient', 'colors': [Color(0xFF11998e), Color(0xFF38ef7d)], 'label': 'Neo Mint'},
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
  }

  void _initControllers() {
    _titleControllers = _presentation.slides
        .map((s) => TextEditingController(text: s.title))
        .toList();
    _contentControllers = _presentation.slides
        .map((s) => s.content.map((c) => TextEditingController(text: c)).toList())
        .toList();
  }

  void _saveAll() {
    for (int i = 0; i < _presentation.slides.length; i++) {
      _presentation.slides[i].title = _titleControllers[i].text;
      _presentation.slides[i].content =
          _contentControllers[i].map((c) => c.text).toList();
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
    });
  }

  void _duplicateSlide(int index) {
    setState(() {
      final slide = _presentation.slides[index];
      _presentation.slides.insert(
        index + 1,
        Slide(title: '${slide.title} (копия)', content: List.from(slide.content)),
      );
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: bg['color'] as Color,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  bool get _isDark {
    final bg = _basicBackgrounds[_selectedBgIndex];
    if (bg['type'] == 'solid') {
      final color = bg['color'] as Color;
      return color.computeLuminance() < 0.5;
    }
    return true; // градиенты считаем тёмными для контраста
  }

  void _showBgPicker() {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.85,
        minChildSize: 0.35,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(16.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 12.h),
            Text('Выбор фона', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 12.h),

            // Базовые
            Text('Бесплатные', style: TextStyle(fontSize: 11, color: Colors.white38)),
            SizedBox(height: 6.h),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6.h,
              crossAxisSpacing: 6.w,
              childAspectRatio: 1,
              children: _basicBackgrounds.asMap().entries.map((entry) {
                final i = entry.key;
                final bg = entry.value;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBgIndex = i);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: bg['type'] == 'gradient'
                          ? LinearGradient(colors: bg['colors'] as List<Color>)
                          : null,
                      color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: i == _selectedBgIndex ? const Color(0xFF1DB954) : Colors.white10,
                        width: 2,
                      ),
                    ),
                    child: i == _selectedBgIndex
                        ? const Center(child: Icon(Icons.check, color: Color(0xFF1DB954)))
                        : null,
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 12.h),
            Row(children: [
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
              SizedBox(width: 4.w),
              const Text('Premium', style: TextStyle(fontSize: 11, color: Color(0xFFFFD700))),
            ]),
            SizedBox(height: 6.h),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6.h,
              crossAxisSpacing: 6.w,
              childAspectRatio: 1,
              children: _premiumBackgrounds.map((bg) {
                return GestureDetector(
                  onTap: isPremium
                      ? () {
                          setState(() {
                            _selectedBgIndex = _basicBackgrounds.length;
                            _basicBackgrounds.add(bg);
                          });
                          Navigator.pop(ctx);
                        }
                      : () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Доступно в Premium'),
                              backgroundColor: Color(0xFFFFD700),
                            ),
                          );
                        },
                  child: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: bg['type'] == 'gradient'
                            ? LinearGradient(colors: bg['colors'] as List<Color>)
                            : null,
                        color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (!isPremium)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Icon(Icons.lock, color: Colors.white38, size: 14)),
                      ),
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
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 16.h),
            Text('Шрифт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 12.h),
            ..._fontOptions.map((f) => ListTile(
              title: Text(f['label']!, style: TextStyle(fontFamily: f['name'], color: Colors.white, fontSize: 16)),
              trailing: _fontPair == f['name'] ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
              onTap: () {
                setState(() => _fontPair = f['name']!);
                Navigator.pop(ctx);
              },
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
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            SizedBox(height: 16.h),
            Text('Экспорт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954)),
              title: const Text('PPTX', style: TextStyle(color: Colors.white)),
              subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(ctx);
                ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium);
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey),
              title: const Text('PDF', style: TextStyle(color: Colors.white)),
              subtitle: Text(isPremium ? 'Доступно' : 'Premium', style: TextStyle(color: Colors.grey)),
              onTap: isPremium
                  ? () {
                      Navigator.pop(ctx);
                      ExportService.exportToPDF(presentation: _presentation, isPremium: true);
                    }
                  : null,
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (var c in _titleControllers) { c.dispose(); }
    for (var list in _contentControllers) {
      for (var c in list) { c.dispose(); }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(_presentation.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _showFontPicker, icon: const Icon(Icons.text_fields, color: Color(0xFF1DB954), size: 18), tooltip: 'Шрифт'),
          IconButton(onPressed: _showBgPicker, icon: const Icon(Icons.palette, color: Color(0xFF1DB954), size: 18), tooltip: 'Фон'),
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1DB954), size: 22), tooltip: 'Добавить слайд'),
          IconButton(onPressed: _export, icon: const Icon(Icons.download, color: Colors.white70, size: 20), tooltip: 'Экспорт'),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(12.w),
        itemCount: _presentation.slides.length,
        itemBuilder: (context, index) => _buildSlideCard(index),
      ),
    );
  }

  Widget _buildSlideCard(int index) {
    final dark = _isDark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Card(
        color: const Color(0xFF1E1E1E),
        margin: EdgeInsets.only(bottom: 16.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        shadowColor: const Color(0xFF1DB954).withOpacity(0.15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Превью слайда 16:9
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: _getSlideDecoration(),
              child: Stack(children: [
                // Декоративные круги
                Positioned(
                  top: -20, right: -20,
                  child: Container(
                    width: 80.w, height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.06), width: 20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30, left: -30,
                  child: Container(
                    width: 100.w, height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.04), width: 25),
                    ),
                  ),
                ),
                // Контент
                Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Номер слайда
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: dark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: dark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Заголовок
                      Text(
                        _titleControllers[index].text.isEmpty ? 'Заголовок слайда' : _titleControllers[index].text,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: _fontPair,
                          color: dark ? Colors.white : const Color(0xFF1A1A2E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Разделитель
                      Container(
                        width: 40.w,
                        height: 3.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Пункты
                      ..._contentControllers[index].take(4).map((ctrl) => Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            margin: EdgeInsets.only(top: 5.h, right: 8.w),
                            width: 5.w, height: 5.w,
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF1DB954) : const Color(0xFF169C46),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ctrl.text.isEmpty ? 'Пункт...' : ctrl.text,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: _fontPair,
                                color: dark ? Colors.white.withOpacity(0.85) : const Color(0xFF333333),
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      )),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          // Редактор
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF169C46)]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Редактировать', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _improveSlide(index),
                  icon: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF1DB954)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'AI',
                ),
                IconButton(
                  onPressed: () => _duplicateSlide(index),
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  onPressed: () => _deleteSlide(index),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFFF3B30)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ]),
              SizedBox(height: 8.h),
              TextField(
                controller: _titleControllers[index],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Заголовок слайда',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(height: 6.h),
              ..._contentControllers[index].asMap().entries.map((entry) {
                final i = entry.key;
                final ctrl = entry.value;
                return Row(children: [
                  Container(
                    width: 5.w, height: 5.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle),
                  ),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                      decoration: InputDecoration(
                        hintText: 'Пункт ${i + 1}',
                        hintStyle: TextStyle(color: Colors.white12),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeContentItem(index, i),
                    icon: const Icon(Icons.close, size: 14, color: Color(0xFFFF3B30)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ]);
              }),
              SizedBox(height: 4.h),
              TextButton.icon(
                onPressed: () => _addContentItem(index),
                icon: const Icon(Icons.add, size: 14, color: Color(0xFF1DB954)),
                label: const Text('Добавить пункт', style: TextStyle(color: Color(0xFF1DB954), fontSize: 11)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}