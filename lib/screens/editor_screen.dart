import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';
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

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _loadSlideData();
  }

  Slide get _currentSlide => _presentation.slides[_currentSlideIndex];

  void _loadSlideData() {
    final slide = _currentSlide;
    _titleController.text = slide.title;
    _contentControllers = slide.content.map((e) => TextEditingController(text: e)).toList();
  }

  void _saveCurrentSlide() {
    final slide = _currentSlide;
    slide.title = _titleController.text;
    slide.content = _contentControllers.map((c) => c.text).toList();
  }

  void _goToSlide(int index) {
    _saveCurrentSlide();
    setState(() { _currentSlideIndex = index; _loadSlideData(); });
  }

  void _addSlide() {
    final up = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= up.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Максимум ${up.maxSlidesPerPresentation} слайдов')));
      return;
    }
    _saveCurrentSlide();
    setState(() {
      _presentation.slides.add(Slide(title: 'Новый слайд', content: ['Введите текст']));
      _currentSlideIndex = _presentation.slides.length - 1;
      _loadSlideData();
    });
  }

  void _deleteSlide() {
    if (_presentation.slides.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Должен быть хотя бы один слайд')));
      return;
    }
    setState(() {
      _presentation.slides.removeAt(_currentSlideIndex);
      if (_currentSlideIndex >= _presentation.slides.length) _currentSlideIndex = _presentation.slides.length - 1;
      _loadSlideData();
    });
  }

  void _addContentItem() {
    setState(() { _contentControllers.add(TextEditingController(text: 'Новый пункт')); });
  }

  void _removeContentItem(int index) {
    if (_contentControllers.length <= 1) return;
    setState(() { _contentControllers[index].dispose(); _contentControllers.removeAt(index); });
  }

  void _exportPresentation() {
    _saveCurrentSlide();
    final isPremium = Provider.of<UserProvider>(context, listen: false).isPremium;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 24.h),
            Text('Экспорт', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),
            ListTile(leading: const Icon(Icons.insert_drive_file, color: Color(0xFF6366F1)), title: const Text('PPTX'), subtitle: Text(isPremium ? 'Без знака' : 'С водяным знаком'), onTap: () { Navigator.pop(ctx); ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium); }),
            ListTile(leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey), title: const Text('PDF'), subtitle: Text(isPremium ? 'Доступно' : 'Premium'), onTap: isPremium ? () { Navigator.pop(ctx); ExportService.exportToPDF(presentation: _presentation, isPremium: true); } : null),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveCurrentSlide();
    _titleController.dispose();
    for (final c in _contentControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = const Color(0xFF0F0F1A);
    final cardColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    const accent = Color(0xFF6366F1);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Text(_presentation.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white70), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline, color: Colors.white70)),
          IconButton(onPressed: _exportPresentation, icon: const Icon(Icons.download, color: Colors.white70)),
        ],
      ),
      body: Column(children: [
        // ПРЕДПРОСМОТР СЛАЙДА
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(children: [
                if (_currentSlide.imageUrl != null)
                  Positioned.fill(child: Image.network(_currentSlide.imageUrl!, fit: BoxFit.cover)),
                if (_currentSlide.imageUrl != null)
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)]))),
                Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Spacer(),
                    Text(_currentSlide.title, style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: _currentSlide.imageUrl != null ? Colors.white : Colors.black87)),
                    SizedBox(height: 20.h),
                    ..._currentSlide.content.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(margin: EdgeInsets.only(top: 8.h, right: 16.w), width: 10.w, height: 10.w, decoration: BoxDecoration(color: _currentSlide.imageUrl != null ? Colors.white : accent, shape: BoxShape.circle)),
                        Expanded(child: Text(item, style: TextStyle(fontSize: 16.sp, height: 1.5, color: _currentSlide.imageUrl != null ? Colors.white : Colors.black87))),
                      ]),
                    )),
                    const Spacer(),
                  ]),
                ),
              ]),
            ),
          ),
        ),

        // РЕДАКТОР
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Заголовок
                Text('Заголовок', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[400])),
                SizedBox(height: 8.h),
                TextField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Введите заголовок',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true, fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
                SizedBox(height: 20.h),

                // Пункты
                Row(children: [
                  Text('Содержание', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[400])),
                  const Spacer(),
                  TextButton.icon(onPressed: _addContentItem, icon: Icon(Icons.add, size: 18, color: accent), label: Text('Добавить', style: TextStyle(color: accent, fontSize: 13.sp))),
                ]),
                SizedBox(height: 8.h),
                ..._contentControllers.asMap().entries.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(children: [
                    Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        style: TextStyle(fontSize: 15.sp, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Пункт ${e.key + 1}',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true, fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        ),
                      ),
                    ),
                    if (_contentControllers.length > 1)
                      IconButton(onPressed: () => _removeContentItem(e.key), icon: Icon(Icons.close, size: 18, color: Colors.red[300])),
                  ]),
                )),

                SizedBox(height: 20.h),

                // Навигация
                Row(children: [
                  _navBtn(Icons.arrow_back, 'Назад', _currentSlideIndex > 0, () => _goToSlide(_currentSlideIndex - 1), accent),
                  SizedBox(width: 12.w),
                  _navBtn(Icons.arrow_forward, 'Вперёд', _currentSlideIndex < _presentation.slides.length - 1, () => _goToSlide(_currentSlideIndex + 1), accent),
                  const Spacer(),
                  Text('${_currentSlideIndex + 1}/${_presentation.slides.length}', style: TextStyle(color: Colors.grey[500], fontSize: 14.sp)),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _navBtn(IconData icon, String label, bool enabled, VoidCallback onTap, Color accent) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: enabled ? accent.withOpacity(0.1) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: enabled ? accent.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: enabled ? accent : Colors.grey[700]),
          SizedBox(width: 8.w),
          Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: enabled ? accent : Colors.grey[700])),
        ]),
      ),
    );
  }
}