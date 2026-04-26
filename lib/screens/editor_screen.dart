import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/presentation.dart';
import '../providers/user_provider.dart';
import '../services/export_service.dart';

class EditorScreen extends StatefulWidget {
  final Presentation presentation;
  const EditorScreen({super.key, required this.presentation});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late Presentation _presentation;
  int _currentSlideIndex = 0;
  bool _isEditing = false;

  // Контроллеры для редактирования
  final _titleController = TextEditingController();
  final List<TextEditingController> _contentControllers = [];

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
    _loadSlideData();
  }

  void _loadSlideData() {
    final slide = _currentSlide;
    _titleController.text = slide.title;
    _contentControllers.clear();
    for (final item in slide.content) {
      _contentControllers.add(TextEditingController(text: item));
    }
  }

  Slide get _currentSlide => _presentation.slides[_currentSlideIndex];

  void _goToSlide(int index) {
    _saveCurrentSlide();
    setState(() {
      _currentSlideIndex = index;
      _loadSlideData();
    });
  }

  void _saveCurrentSlide() {
    final slide = _currentSlide;
    slide.title = _titleController.text;
    slide.content = _contentControllers.map((c) => c.text).toList();
  }

  void _addSlide() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_presentation.slides.length >= userProvider.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Максимум ${userProvider.maxSlidesPerPresentation} слайдов')),
      );
      return;
    }
    
    _saveCurrentSlide();
    setState(() {
      _presentation.slides.add(Slide(
        title: 'Новый слайд',
        content: ['Введите текст'],
      ));
      _currentSlideIndex = _presentation.slides.length - 1;
      _loadSlideData();
    });
  }

  void _deleteSlide() {
    if (_presentation.slides.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Должен быть хотя бы один слайд')),
      );
      return;
    }
    
    setState(() {
      _presentation.slides.removeAt(_currentSlideIndex);
      if (_currentSlideIndex >= _presentation.slides.length) {
        _currentSlideIndex = _presentation.slides.length - 1;
      }
      _loadSlideData();
    });
  }

  void _duplicateSlide() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isPremium) {
      _showPremiumNudge('Дублирование слайдов');
      return;
    }
    
    _saveCurrentSlide();
    final original = _currentSlide;
    setState(() {
      _presentation.slides.insert(_currentSlideIndex + 1, Slide(
        title: '${original.title} (копия)',
        subtitle: original.subtitle,
        content: List.from(original.content),
        imageUrl: original.imageUrl,
        imageKeywords: original.imageKeywords,
      ));
    });
  }

  void _moveSlide(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final slide = _presentation.slides.removeAt(oldIndex);
      _presentation.slides.insert(newIndex, slide);
      _currentSlideIndex = newIndex;
      _loadSlideData();
    });
  }

  void _addContentItem() {
    setState(() {
      _contentControllers.add(TextEditingController(text: 'Новый пункт'));
    });
  }

  void _removeContentItem(int index) {
    if (_contentControllers.length <= 1) return;
    setState(() {
      _contentControllers.removeAt(index);
    });
  }

  void _moveContentItem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _contentControllers.removeAt(oldIndex);
      _contentControllers.insert(newIndex, item);
    });
  }

  void _exportPresentation() async {
    _saveCurrentSlide();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.isPremium;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                SizedBox(height: 24.h),
                Text('Экспорт презентации', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 24.h),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Color(0xFF4F46E5)),
                  title: const Text('PPTX (PowerPoint)'),
                  subtitle: Text(isPremium ? 'Без водяного знака' : 'С водяным знаком'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () { Navigator.pop(context); ExportService.exportToPPTX(presentation: _presentation, isPremium: isPremium); },
                ),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf, color: isPremium ? Colors.red : Colors.grey),
                  title: const Text('PDF'),
                  subtitle: Text(isPremium ? 'Доступно' : 'Premium'),
                  trailing: isPremium ? const Icon(Icons.chevron_right) : const Icon(Icons.lock),
                  onTap: isPremium ? () { Navigator.pop(context); ExportService.exportToPDF(presentation: _presentation, isPremium: true); } : null,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPremiumNudge(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Icon(Icons.crown, color: Colors.amber[700]), SizedBox(width: 8.w), const Text('Premium')]),
        content: Text('$feature доступно в Premium версии.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Позже')),
          ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)), child: const Text('Оформить Premium')),
        ],
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
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(_presentation.title),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(onPressed: _addSlide, icon: const Icon(Icons.add_circle_outline), tooltip: 'Добавить слайд'),
          IconButton(onPressed: _exportPresentation, icon: const Icon(Icons.download), tooltip: 'Скачать'),
        ],
      ),
      body: Row(
        children: [
          // Боковая панель с перетаскиваемыми слайдами
          _buildSlidesSidebar(),
          
          // Основная область
          Expanded(
            child: Column(
              children: [
                // Предпросмотр слайда
                Expanded(
                  flex: 3,
                  child: _buildSlidePreview(_currentSlide, isDark),
                ),
                
                // Разделитель
                Container(
                  height: 4,
                  color: Colors.grey.withOpacity(0.1),
                  child: Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  ),
                ),
                
                // Редактор
                Expanded(
                  flex: 2,
                  child: _buildEditor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidesSidebar() {
    return Container(
      width: 240.w,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2)))),
            child: Row(
              children: [
                Text('Слайды (${_presentation.slides.length})', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
                const Spacer(),
                IconButton(onPressed: _addSlide, icon: const Icon(Icons.add, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _presentation.slides.length,
              onReorder: _moveSlide,
              itemBuilder: (context, index) {
                final slide = _presentation.slides[index];
                final isSelected = index == _currentSlideIndex;
                
                return _SlideThumbnail(
                  key: ValueKey(index),
                  slide: slide,
                  index: index,
                  isSelected: isSelected,
                  onTap: () => _goToSlide(index),
                  onDelete: _presentation.slides.length > 1 ? () { _goToSlide(index); _deleteSlide(); } : null,
                  onDuplicate: () { _goToSlide(index); _duplicateSlide(); },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidePreview(Slide slide, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isEditing = !_isEditing),
      child: Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              if (slide.imageUrl != null)
                Positioned.fill(
                  child: Image.network(slide.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                ),
              if (slide.imageUrl != null)
                Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)]))),
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slide.title, style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: slide.imageUrl != null ? Colors.white : Colors.black87)),
                    if (slide.subtitle != null) ...[SizedBox(height: 8.h), Text(slide.subtitle!, style: TextStyle(fontSize: 18.sp, color: slide.imageUrl != null ? Colors.white70 : Colors.grey[700]))],
                    SizedBox(height: 20.h),
                    ...slide.content.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(margin: EdgeInsets.only(top: 6.h, right: 12.w), width: 8.w, height: 8.w, decoration: BoxDecoration(color: slide.imageUrl != null ? Colors.white : const Color(0xFF4F46E5), shape: BoxShape.circle)),
                          Expanded(child: Text(item, style: TextStyle(fontSize: 14.sp, height: 1.5, color: slide.imageUrl != null ? Colors.white : Colors.black87))),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Icon(Icons.title, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text('Заголовок слайда', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _titleController,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Введите заголовок',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Содержание
          Row(
            children: [
              Icon(Icons.list, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text('Содержание', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[600])),
              const Spacer(),
              TextButton.icon(
                onPressed: _addContentItem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contentControllers.length,
            onReorder: _moveContentItem,
            itemBuilder: (context, index) {
              return Padding(
                key: ValueKey(index),
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    // Ручка для перетаскивания
                    Icon(Icons.drag_handle, color: Colors.grey[400], size: 20),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _contentControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Пункт ${index + 1}',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                    ),
                    if (_contentControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeContentItem(index),
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Виджет миниатюры слайда в боковой панели
class _SlideThumbnail extends StatelessWidget {
  final Slide slide;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const _SlideThumbnail({
    super.key,
    required this.slide,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.withOpacity(0.2), width: isSelected ? 2 : 1),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 28.w, height: 28.w,
          decoration: BoxDecoration(color: const Color(0xFF4F46E5), shape: BoxShape.circle),
          child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold))),
        ),
        title: Text(slide.title, style: TextStyle(fontSize: 13.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDuplicate != null)
              InkWell(onTap: onDuplicate, child: Icon(Icons.copy, size: 16, color: Colors.grey[500])),
            if (onDelete != null)
              InkWell(onTap: onDelete, child: Icon(Icons.delete_outline, size: 16, color: Colors.red[300])),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}