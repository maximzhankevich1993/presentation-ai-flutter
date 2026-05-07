import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
import '../services/ai_improve_service.dart';
import '../services/animation_service.dart';
import 'share_screen.dart';
import 'analytics_screen.dart';

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Presentation _presentation;
  int _currentSlideIndex = 0;
  final _titleController = TextEditingController();
  List<TextEditingController> _contentControllers = [];
  String _currentTransition = 'fade';
  Color _slideBg = Colors.white;
  String _fontPair = 'Inter';

  final List<Map<String, dynamic>> _bgOptions = [
    {'color': Colors.white, 'label': 'Белый'},
    {'color': const Color(0xFFF5F5F5), 'label': 'Серый'},
    {'color': const Color(0xFF0F0F1A), 'label': 'Тёмный'},
    {'color': const Color(0xFF1A1A2E), 'label': 'Ночной'},
    {'color': const Color(0xFFFFF8E7), 'label': 'Кремовый'},
    {'color': const Color(0xFFE8F5E9), 'label': 'Мятный'},
  ];

  final List<Map<String, String>> _fontOptions = [
    {'name': 'Inter', 'label': 'Современный'},
    {'name': 'Georgia', 'label': 'Элегантный'},
    {'name': 'Courier', 'label': 'Моноширинный'},
  ];

  final List<Map<String, dynamic>> _transitionOptions = [
    {'id': 'fade', 'name': 'Плавно', 'icon': Icons.opacity},
    {'id': 'slide', 'name': 'Сдвиг', 'icon': Icons.swap_horiz},
    {'id': 'zoom', 'name': 'Зум', 'icon': Icons.zoom_in},
    {'id': 'flip', 'name': 'Переворот', 'icon': Icons.flip},
  ];

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _loadSlide();
  }

  Slide get _currentSlide => _presentation.slides[_currentSlideIndex];

  void _loadSlide() {
    _titleController.text = _currentSlide.title;
    _contentControllers = _currentSlide.content.map((e) => TextEditingController(text: e)).toList();
    setState(() {});
  }

  void _saveSlide() {
    _currentSlide.title = _titleController.text;
    _currentSlide.content = _contentControllers.map((c) => c.text).toList();
  }

  void _goToSlide(int index) {
    _saveSlide();
    setState(() { _currentSlideIndex = index; _loadSlide(); });
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Максимум ${up.maxSlidesPerPresentation} слайдов')));
      return;
    }
    _saveSlide();
    setState(() {
      _presentation.slides.add(Slide(title: 'Новый слайд', content: ['Введите текст']));
      _currentSlideIndex = _presentation.slides.length - 1;
      _loadSlide();
    });
  }

  void _deleteSlide() {
    if (_presentation.slides.length <= 1) return;
    setState(() {
      _presentation.slides.removeAt(_currentSlideIndex);
      if (_currentSlideIndex >= _presentation.slides.length) _currentSlideIndex = _presentation.slides.length - 1;
      _loadSlide();
    });
  }

  void _duplicateSlide() {
    _saveSlide();
    setState(() {
      _presentation.slides.insert(_currentSlideIndex + 1, Slide(title: '${_currentSlide.title} (копия)', content: List.from(_currentSlide.content)));
      _currentSlideIndex++;
      _loadSlide();
    });
  }

  void _addContentItem() {
    setState(() => _contentControllers.add(TextEditingController(text: 'Новый пункт')));
  }

  void _removeContentItem(int index) {
    if (_contentControllers.length <= 1) return;
    setState(() { _contentControllers[index].dispose(); _contentControllers.removeAt(index); });
  }

  Future<void> _improveWithAI() async {
    _saveSlide();
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF1DB954))));
    try {
      final improvedTitle = await AiImproveService.improveText(_currentSlide.title);
      final improvedContent = <String>[];
      for (final c in _currentSlide.content) {
        improvedContent.add(await AiImproveService.improveText(c));
      }
      Navigator.pop(context);
      setState(() {
        _currentSlide.title = improvedTitle;
        _currentSlide.content = improvedContent;
        _loadSlide();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Текст улучшен!'), backgroundColor: Color(0xFF1DB954)));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red));
    }
  }

  void _export() {
    _saveSlide();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36.w, height: 4.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 16.h),
            Text('Экспорт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 16.h),
            ListTile(leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1DB954)), title: const Text('PPTX', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком', style: const TextStyle(color: Color(0xFFB3B3B3))), onTap: () { Navigator.pop(ctx); ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium); }),
            ListTile(leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey), title: const Text('PDF', style: TextStyle(color: Colors.white)), subtitle: Text(isPremium ? 'Доступно' : 'Premium', style: const TextStyle(color: Color(0xFFB3B3B3))), onTap: isPremium ? () { Navigator.pop(ctx); ExportService.exportToPDF(presentation: _presentation, isPremium: true); } : null),
          ]),
        ),
      ),
    );
  }

  void _showBgPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36.w, height: 4.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 16.h),
            Text('Фон слайда', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 12.h),
            Wrap(spacing: 10.w, runSpacing: 10.h, children: _bgOptions.map((bg) => GestureDetector(
              onTap: () { setState(() => _slideBg = bg['color'] as Color); Navigator.pop(ctx); },
              child: Container(width: 44.w, height: 44.w, decoration: BoxDecoration(color: bg['color'] as Color, borderRadius: BorderRadius.circular(10), border: Border.all(color: _slideBg == bg['color'] ? const Color(0xFF1DB954) : Colors.white.withOpacity(0.1), width: 2))),
            )).toList()),
            SizedBox(height: 20.h),
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
            Container(width: 36.w, height: 4.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 16.h),
            Text('Шрифт', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 12.h),
            ..._fontOptions.map((f) => ListTile(
              title: Text(f['label']!, style: TextStyle(fontFamily: f['name'], color: Colors.white)),
              trailing: _fontPair == f['name'] ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
              onTap: () { setState(() => _fontPair = f['name']!); Navigator.pop(ctx); },
            )),
          ]),
        ),
      ),
    );
  }

  void _showTransitionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36.w, height: 4.h, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 16.h),
            Text('Анимация', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: 12.h),
            ..._transitionOptions.map((t) => ListTile(
              leading: Icon(t['icon'] as IconData, color: Colors.white70),
              title: Text(t['name'] as String, style: const TextStyle(color: Colors.white)),
              trailing: _currentTransition == t['id'] ? const Icon(Icons.check, color: Color(0xFF1DB954)) : null,
              onTap: () { setState(() => _currentTransition = t['id'] as String); Navigator.pop(ctx); },
            )),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveSlide();
    _titleController.dispose();
    for (final c in _contentControllers) { c.dispose(); }
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
          IconButton(onPressed: () => _showTransitionPicker(), icon: const Icon(Icons.animation, color: Color(0xFF1DB954), size: 20), tooltip: 'Анимация'),
          IconButton(onPressed: () => _showFontPicker(), icon: const Icon(Icons.text_fields, color: Color(0xFF1DB954), size: 20), tooltip: 'Шрифт'),
          IconButton(onPressed: () => _showBgPicker(), icon: const Icon(Icons.palette, color: Color(0xFF1DB954), size: 20), tooltip: 'Фон'),
          IconButton(onPressed: _improveWithAI, icon: const Icon(Icons.auto_awesome, color: Color(0xFF1DB954), size: 20), tooltip: 'AI'),
          IconButton(onPressed: _export, icon: const Icon(Icons.download, color: Colors.white70, size: 20), tooltip: 'Экспорт'),
        ],
      ),
      body: Column(children: [
        // Превью слайда
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: _slideBg, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16)]),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_currentSlide.title, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: _fontPair, color: _slideBg == const Color(0xFF0F0F1A) || _slideBg == const Color(0xFF1A1A2E) ? Colors.white : Colors.black87)),
                SizedBox(height: 16.h),
                ..._currentSlide.content.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(margin: EdgeInsets.only(top: 6.h, right: 10.w), width: 6.w, height: 6.w, decoration: BoxDecoration(color: const Color(0xFF1DB954), shape: BoxShape.circle)),
                    Expanded(child: Text(item, style: TextStyle(fontSize: 13.sp, fontFamily: _fontPair, color: _slideBg == const Color(0xFF0F0F1A) || _slideBg == const Color(0xFF1A1A2E) ? Colors.white70 : Colors.black54))),
                  ]),
                )),
              ]),
            ),
          ),
        ),

        // Редактор
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Слайды
                SizedBox(
                  height: 44.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presentation.slides.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _goToSlide(i),
                      child: Container(
                        width: 44.w, margin: EdgeInsets.only(right: 6.w),
                        decoration: BoxDecoration(
                          color: i == _currentSlideIndex ? const Color(0xFF1DB954) : const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(child: Text('${i + 1}', style: TextStyle(color: i == _currentSlideIndex ? Colors.black : Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Row(children: [
                  _miniBtn(Icons.add, 'Слайд', _addSlide),
                  SizedBox(width: 8.w),
                  _miniBtn(Icons.copy, 'Копия', _duplicateSlide),
                  SizedBox(width: 8.w),
                  _miniBtn(Icons.delete_outline, 'Удалить', _deleteSlide),
                ]),
                SizedBox(height: 16.h),
                // Заголовок
                TextField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Заголовок',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: InputBorder.none,
                  ),
                ),
                SizedBox(height: 12.h),
                // Контент
                ..._contentControllers.asMap().entries.map((e) => Row(children: [
                  Container(width: 6.w, height: 6.w, margin: EdgeInsets.only(right: 8.w), decoration: BoxDecoration(color: const Color(0xFF1DB954), shape: BoxShape.circle)),
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                      decoration: InputDecoration(
                        hintText: 'Пункт ${e.key + 1}',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(onPressed: () => _removeContentItem(e.key), icon: const Icon(Icons.close, size: 16, color: Color(0xFFFF3B30)), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ])),
                SizedBox(height: 6.h),
                TextButton.icon(
                  onPressed: _addContentItem,
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF1DB954)),
                  label: const Text('Добавить пункт', style: TextStyle(color: Color(0xFF1DB954), fontSize: 12)),
                ),
                SizedBox(height: 16.h),
                // Кнопки навигации
                Row(children: [
                  _navBtn(Icons.arrow_back, 'Назад', _currentSlideIndex > 0, () => _goToSlide(_currentSlideIndex - 1)),
                  const Spacer(),
                  Text('${_currentSlideIndex + 1}/${_presentation.slides.length}', style: TextStyle(fontSize: 12, color: Colors.white38)),
                  const Spacer(),
                  _navBtn(Icons.arrow_forward, 'Вперёд', _currentSlideIndex < _presentation.slides.length - 1, () => _goToSlide(_currentSlideIndex + 1)),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: const Color(0xFF282828), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Colors.white70),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white70)),
      ]),
    ),
  );

  Widget _navBtn(IconData icon, String label, bool enabled, VoidCallback onTap) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Opacity(
      opacity: enabled ? 1 : 0.3,
      child: Row(children: [
        Icon(icon, size: 16, color: const Color(0xFF1DB954)),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 12, color: enabled ? const Color(0xFF1DB954) : Colors.white38)),
      ]),
    ),
  );
}