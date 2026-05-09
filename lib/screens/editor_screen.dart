import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/image_service.dart';

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
  late List<String?> _customImages;
  late List<String?> _customBackgrounds;
  late List<double> _customFontSizes;
  late List<String> _customFonts;

  String _fontPair = 'Inter';
  int _selectedBgIndex = 0;
  int _imageUploadsUsed = 0;

  final Map<int, String?> _autoImages = {};

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
    _customImages = List.filled(_presentation.slides.length, null);
    _customBackgrounds = List.filled(_presentation.slides.length, null);
    _customFontSizes = List.filled(_presentation.slides.length, 9.0);
    _customFonts = List.filled(_presentation.slides.length, 'Inter');
    _initControllers();
    _loadAutoImages();
    _countUploads();
  }

  void _initControllers() {
    _titleControllers = _presentation.slides.map((s) => TextEditingController(text: s.title)).toList();
    _contentControllers = _presentation.slides.map((s) => s.content.map((c) => TextEditingController(text: c)).toList()).toList();
  }

  void _countUploads() {
    _imageUploadsUsed = _customImages.where((img) => img != null).length;
  }

  Future<void> _loadAutoImages() async {
    for (int i = 0; i < _presentation.slides.length; i++) {
      final query = _titleControllers[i].text.isNotEmpty ? _titleControllers[i].text : _presentation.title;
      _autoImages[i] = await ImageService.searchImage(query);
    }
    if (mounted) setState(() {});
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Максимум ${up.maxSlidesPerPresentation} слайдов')));
      return;
    }
    setState(() {
      _presentation.slides.add(Slide(title: 'Новый слайд', content: ['Введите текст']));
      _titleControllers.add(TextEditingController(text: 'Новый слайд'));
      _contentControllers.add([TextEditingController(text: 'Введите текст')]);
      _customImages.add(null);
      _customBackgrounds.add(null);
      _customFontSizes.add(9.0);
      _customFonts.add('Inter');
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
      _customImages.removeAt(index);
      _customBackgrounds.removeAt(index);
      _customFontSizes.removeAt(index);
      _customFonts.removeAt(index);
      _autoImages.remove(index);
    });
    _countUploads();
  }

  void _duplicateSlide(int index) {
    setState(() {
      _presentation.slides.insert(index + 1, Slide(title: '${_presentation.slides[index].title} (копия)', content: List.from(_presentation.slides[index].content)));
      _titleControllers.insert(index + 1, TextEditingController(text: '${_titleControllers[index].text} (копия)'));
      _contentControllers.insert(index + 1, _contentControllers[index].map((c) => TextEditingController(text: c.text)).toList());
      _customImages.insert(index + 1, _customImages[index]);
      _customBackgrounds.insert(index + 1, _customBackgrounds[index]);
      _customFontSizes.insert(index + 1, _customFontSizes[index]);
      _customFonts.insert(index + 1, _customFonts[index]);
    });
    _countUploads();
  }

  void _addContentItem(int i) => setState(() => _contentControllers[i].add(TextEditingController(text: 'Новый пункт')));

  void _removeContentItem(int slide, int item) {
    if (_contentControllers[slide].length <= 1) return;
    setState(() { _contentControllers[slide][item].dispose(); _contentControllers[slide].removeAt(item); });
  }

  Future<void> _improveSlide(int index) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))));
    try {
      final t = await AiImproveService.improveText(_titleControllers[index].text);
      final c = <String>[];
      for (final cc in _contentControllers[index]) { c.add(await AiImproveService.improveText(cc.text)); }
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        _titleControllers[index].text = t;
        for (int i = 0; i < c.length && i < _contentControllers[index].length; i++) { _contentControllers[index][i].text = c[i]; }
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Текст улучшен!'), backgroundColor: Color(0xFF1DB954)));
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _uploadImage(int index) async {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    if (!isPremium && _imageUploadsUsed >= 10 && _customImages[index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('10 бесплатных загрузок использованы. Premium — безлимитно.'), backgroundColor: Color(0xFFFFD700)));
      return;
    }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoad.listen((_) {
          setState(() {
            _customImages[index] = reader.result as String;
            if (!isPremium) _imageUploadsUsed++;
          });
        });
      }
    });
  }

  Future<void> _uploadBackground(int index) async {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    final bgUploadsUsed = _customBackgrounds.where((bg) => bg != null).length;
    if (!isPremium && bgUploadsUsed >= 10 && _customBackgrounds[index] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('10 фонов бесплатно. Premium — безлимитно.'), backgroundColor: Color(0xFFFFD700)));
      return;
    }
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((e) {
      final file = input.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoad.listen((_) {
          setState(() => _customBackgrounds[index] = reader.result as String);
        });
      }
    });
  }

  Decoration _getDecoration(int index) {
    final r = BorderRadius.circular(8);
    if (_customBackgrounds[index] != null) {
      return BoxDecoration(
        image: DecorationImage(image: NetworkImage(_customBackgrounds[index]!), fit: BoxFit.cover),
        borderRadius: r,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      );
    }
    final bg = _basicBackgrounds[_selectedBgIndex];
    if (bg['type'] == 'gradient') {
      return BoxDecoration(gradient: LinearGradient(colors: bg['colors'] as List<Color>), borderRadius: r, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]);
    }
    return BoxDecoration(color: bg['color'] as Color, borderRadius: r, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]);
  }

  bool _isDark(int index) {
    if (_customBackgrounds[index] != null) return true;
    final bg = _basicBackgrounds[_selectedBgIndex];
    if (bg['type'] == 'solid') return (bg['color'] as Color).computeLuminance() < 0.5;
    return true;
  }

  void _showBgPicker() {
    final p = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A), isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(initialChildSize: 0.5, maxChildSize: 0.8, expand: false,
        builder: (_, sc) => ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
          Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          const Text('Выбор фона', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text('Бесплатные', style: TextStyle(fontSize: 11, color: Colors.white38)),
          const SizedBox(height: 6),
          GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1,
            children: _basicBackgrounds.asMap().entries.map((e) {
              final i = e.key; final bg = e.value;
              return GestureDetector(
                onTap: () { setState(() { _selectedBgIndex = i; _customBackgrounds = List.filled(_presentation.slides.length, null); }); Navigator.pop(ctx); },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null,
                    color: bg['type'] == 'solid' ? bg['color'] as Color : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: i == _selectedBgIndex && _customBackgrounds.every((b) => b == null) ? const Color(0xFF1DB954) : Colors.white10, width: 2),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Row(children: [Icon(Icons.star, color: Color(0xFFFFD700), size: 14), SizedBox(width: 4), Text('Premium', style: TextStyle(fontSize: 11, color: Color(0xFFFFD700)))]),
          const SizedBox(height: 6),
          GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 6, crossAxisSpacing: 6, childAspectRatio: 1,
            children: _premiumBackgrounds.map((bg) => GestureDetector(
              onTap: p ? () { setState(() { _selectedBgIndex = _basicBackgrounds.length; _basicBackgrounds.add(bg); _customBackgrounds = List.filled(_presentation.slides.length, null); }); Navigator.pop(ctx); } : () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Доступно в Premium'), backgroundColor: Color(0xFFFFD700))); },
              child: Stack(children: [
                Container(decoration: BoxDecoration(gradient: bg['type'] == 'gradient' ? LinearGradient(colors: bg['colors'] as List<Color>) : null, color: bg['type'] == 'solid' ? bg['color'] as Color : null, borderRadius: BorderRadius.circular(8))),
                if (!p) Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: const Center(child: Icon(Icons.lock, color: Colors.white38, size: 14))),
              ]),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('Шрифт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        ..._fontOptions.map((f) => ListTile(
          title: Text(f['label']!, style: TextStyle(fontFamily: f['name'], color: Colors.white, fontSize: 16)),
          trailing: _fontPair == f['name'] ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
          onTap: () { setState(() { _fontPair = f['name']!; for (int i = 0; i < _customFonts.length; i++) { _customFonts[i] = f['name']!; } }); Navigator.pop(ctx); },
        )),
      ])),
    );
  }

  void _showFontSizePicker(int index) {
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Размер шрифта: ${_customFontSizes[index].toInt()} sp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        Slider(
          value: _customFontSizes[index],
          min: 6, max: 18, divisions: 12,
          activeColor: const Color(0xFF1DB954), inactiveColor: Colors.white24,
          onChanged: (v) => setState(() => _customFontSizes[index] = v),
        ),
        if (!isPremium)
          Padding(padding: const EdgeInsets.only(top: 4), child: Text('10 слайдов бесплатно, дальше Premium', style: TextStyle(fontSize: 9, color: Colors.white38))),
        SizedBox(height: 8.h),
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Готово', style: TextStyle(color: Color(0xFF1DB954)))),
      ])),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _customImages[index] = null;
      _countUploads();
    });
  }

  void _export() {
    _saveAll();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('Экспорт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 16),
        ListTile(leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954)), title: const Text('PPTX', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком', style: const TextStyle(color: Colors.grey)), onTap: () { Navigator.pop(ctx); ExportService.exportToPPTX(context: context, presentation: _presentation, isPremium: isPremium); }),
        ListTile(leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey), title: const Text('PDF', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Доступно' : 'Premium', style: const TextStyle(color: Colors.grey)), onTap: isPremium ? () { Navigator.pop(ctx); ExportService.exportToPDF(context: context, presentation: _presentation, isPremium: true); } : null),
      ])),
    );
  }

  @override
  void dispose() {
    _saveAll();
    for (var c in _titleControllers) { c.dispose(); }
    for (var l in _contentControllers) { for (var c in l) { c.dispose(); } }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_presentation.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          if (_imageUploadsUsed > 0) ...[
            const SizedBox(width: 6),
            Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), decoration: BoxDecoration(color: _imageUploadsUsed >= 10 ? Colors.orange : const Color(0xFF1DB954), borderRadius: BorderRadius.circular(8)), child: Text('🖼 $_imageUploadsUsed/10', style: TextStyle(fontSize: 9, color: Colors.black))),
          ],
        ]),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _showFontPicker, icon: const Icon(Icons.text_fields, color: Color(0xFF1DB954), size: 18)),
          IconButton(onPressed: _showBgPicker, icon: const Icon(Icons.palette, color: Color(0xFF1DB954), size: 18)),
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1DB954), size: 22)),
          IconButton(onPressed: _export, icon: const Icon(Icons.download, color: Colors.white70, size: 20)),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        itemCount: _presentation.slides.length,
        itemBuilder: (_, index) => _slideCard(index),
      ),
    );
  }

  Widget _slideCard(int index) {
    final dark = _isDark(index);
    final currentImage = _customImages[index] ?? _autoImages[index];
    final hasImage = currentImage != null;
    final sw = MediaQuery.of(context).size.width;
    final cw = sw * 0.78;
    final usedFont = _customFonts[index] != 'Inter' ? _customFonts[index] : _fontPair;
    final usedSize = _customFontSizes[index];

    return Center(
      child: SizedBox(
        width: cw,
        child: Card(
          color: const Color(0xFF1E1E1E),
          margin: EdgeInsets.only(bottom: 10.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: _getDecoration(index),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Текст
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${index + 1}/${_presentation.slides.length}', style: TextStyle(fontSize: 8, color: dark ? Colors.white38 : Colors.black38)),
                        SizedBox(height: 6.h),
                        Text(_titleControllers[index].text.isEmpty ? 'Заголовок' : _titleControllers[index].text,
                            style: TextStyle(fontSize: (usedSize + 4).sp, fontWeight: FontWeight.w700, fontFamily: usedFont, color: dark ? Colors.white : const Color(0xFF1A1A2E)),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4.h),
                        ..._contentControllers[index].take(4).map((c) => Padding(
                          padding: EdgeInsets.only(bottom: 1.h),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: EdgeInsets.only(top: usedSize.sp * 0.4, right: 4.w), child: Container(width: 3.w, height: 3.w, decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle))),
                            Expanded(child: Text(c.text.isEmpty ? 'Пункт' : c.text, style: TextStyle(fontSize: usedSize.sp, fontFamily: usedFont, color: dark ? Colors.white70 : const Color(0xFF444444)), maxLines: 3, overflow: TextOverflow.ellipsis)),
                          ]),
                        )),
                      ]),
                    ),
                    // Картинка
                    if (hasImage) ...[
                      SizedBox(width: 8.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(currentImage!, width: cw * 0.28, height: cw * 0.19, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                      ),
                    ],
                  ]),
                ),
              ),
            ),
            // Редактор
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF169C46)]), borderRadius: BorderRadius.circular(4)), child: Text('Слайд ${index + 1}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 9))),
                  const Spacer(),
                  _iconBtn(Icons.image, () => _uploadImage(index), tooltip: 'Своя картинка'),
                  _iconBtn(Icons.wallpaper, () => _uploadBackground(index), tooltip: 'Свой фон'),
                  _iconBtn(Icons.format_size, () => _showFontSizePicker(index), tooltip: 'Размер шрифта'),
                  _iconBtn(Icons.auto_awesome, () => _improveSlide(index)),
                  _iconBtn(Icons.copy, () => _duplicateSlide(index)),
                  _iconBtn(Icons.delete_outline, () => _deleteSlide(index), red: true),
                ]),
                if (_customImages[index] != null)
                  TextButton.icon(onPressed: () => _removeImage(index), icon: const Icon(Icons.close, size: 10, color: Color(0xFFFF3B30)), label: Text('Убрать свою картинку', style: TextStyle(fontSize: 9, color: Colors.white38)), style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                TextField(controller: _titleControllers[index], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white), decoration: const InputDecoration(hintText: 'Заголовок', hintStyle: TextStyle(color: Colors.white24, fontSize: 10), border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true)),
                ..._contentControllers[index].asMap().entries.map((e) => Row(children: [
                  Padding(padding: EdgeInsets.only(right: 4.w), child: Container(width: 3.w, height: 3.w, decoration: const BoxDecoration(color: Color(0xFF1DB954), shape: BoxShape.circle))),
                  Expanded(child: TextField(controller: e.value, style: TextStyle(fontSize: 10, color: Colors.white70), decoration: InputDecoration(hintText: 'Пункт ${e.key + 1}', hintStyle: const TextStyle(color: Colors.white12, fontSize: 10), border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true))),
                  IconButton(onPressed: () => _removeContentItem(index, e.key), icon: const Icon(Icons.close, size: 10, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ])),
                TextButton.icon(
                  onPressed: () => _addContentItem(index),
                  icon: const Icon(Icons.add, size: 10, color: Color(0xFF1DB954)),
                  label: const Text('Пункт', style: TextStyle(color: Color(0xFF1DB954), fontSize: 9)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool red = false, String? tooltip}) =>
      IconButton(icon: Icon(icon, size: 14, color: red ? const Color(0xFFFF3B30) : const Color(0xFF1DB954)), onPressed: onTap, padding: EdgeInsets.zero, constraints: const BoxConstraints(), tooltip: tooltip);
}