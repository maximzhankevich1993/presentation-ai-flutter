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

  // ─── LOAD / SAVE ──────────────────────────────────────────────────────────

  Slide get _currentSlide => _presentation.slides[_currentSlideIndex];

  void _loadSlideData() {
    final slide = _currentSlide;
    _titleController.text = slide.title;
    _contentControllers = slide.content
        .map((e) => TextEditingController(text: e))
        .toList();
  }

  void _saveCurrentSlide() {
    final slide = _currentSlide;
    slide.title = _titleController.text;
    slide.content = _contentControllers.map((c) => c.text).toList();
  }

  // ─── NAVIGATION ───────────────────────────────────────────────────────────

  void _goToSlide(int index) {
    _saveCurrentSlide();
    setState(() {
      _currentSlideIndex = index;
      _loadSlideData();
    });
  }

  // ─── SLIDES ───────────────────────────────────────────────────────────────

  void _addSlide() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (_presentation.slides.length >= userProvider.maxSlidesPerPresentation) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Максимум ${userProvider.maxSlidesPerPresentation} слайдов'),
        ),
      );
      return;
    }

    _saveCurrentSlide();

    setState(() {
      _presentation.slides.add(
        Slide(title: 'Новый слайд', content: ['Введите текст']),
      );
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
      _presentation.slides.insert(
        _currentSlideIndex + 1,
        Slide(
          title: '${original.title} (копия)',
          subtitle: original.subtitle,
          content: List.from(original.content),
          imageUrl: original.imageUrl,
          imageKeywords: original.imageKeywords,
        ),
      );
      _currentSlideIndex++;
      _loadSlideData();
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

  // ─── CONTENT ──────────────────────────────────────────────────────────────

  void _addContentItem() {
    setState(() {
      _contentControllers = [..._contentControllers];
      _contentControllers.add(TextEditingController(text: 'Новый пункт'));
    });
  }

  void _removeContentItem(int index) {
    if (_contentControllers.length <= 1) return;
    setState(() {
      _contentControllers[index].dispose();
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

  // ─── EXPORT ───────────────────────────────────────────────────────────────

  void _exportPresentation() {
    _saveCurrentSlide();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isPremium = userProvider.isPremium;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Экспорт презентации',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24.h),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Color(0xFF4F46E5)),
                  title: const Text('PPTX (PowerPoint)'),
                  subtitle: Text(isPremium ? 'Без водяного знака' : 'С водяным знаком'),
                  onTap: () {
                    Navigator.pop(context);
                    ExportService.exportToPPTX(
                      presentation: _presentation,
                      isPremium: isPremium,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.picture_as_pdf,
                    color: isPremium ? Colors.red : Colors.grey,
                  ),
                  title: const Text('PDF'),
                  subtitle: Text(isPremium ? 'Доступно' : 'Premium'),
                  onTap: isPremium
                      ? () {
                          Navigator.pop(context);
                          ExportService.exportToPDF(
                            presentation: _presentation,
                            isPremium: true,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── NAVIGATION SCREENS ───────────────────────────────────────────────────

  void _showShare() {
    _saveCurrentSlide();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareScreen(
          presentationId: _presentation.id,
          presentationTitle: _presentation.title,
        ),
      ),
    );
  }

  void _showAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalyticsScreen(
          presentationTitle: _presentation.title,
          slideCount: _presentation.slides.length,
        ),
      ),
    );
  }

  // ─── PREMIUM ──────────────────────────────────────────────────────────────

  void _showPremiumNudge(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[700]),
            SizedBox(width: 8.w),
            const Text('Premium'),
          ],
        ),
        content: Text('$feature доступно в Premium версии.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Оформить'),
          ),
        ],
      ),
    );
  }

  // ─── DISPOSE ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _saveCurrentSlide();
    _titleController.dispose();
    for (final c in _contentControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA);
    final cardColor = isDark ? const Color(0xFF2A2A3A) : Colors.white;
    const accent = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A3A) : Colors.white,
        elevation: 0,
        title: Text(
          _presentation.title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAnalytics,
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Аналитика',
          ),
          IconButton(
            onPressed: _showShare,
            icon: const Icon(Icons.share),
            tooltip: 'Поделиться',
          ),
          IconButton(
            onPressed: _addSlide,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Добавить слайд',
          ),
          IconButton(
            onPressed: _exportPresentation,
            icon: const Icon(Icons.download),
            tooltip: 'Экспорт',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Полоса миниатюр слайдов ────────────────────────────────────
          _buildSlideStrip(isDark: isDark, accent: accent, cardColor: cardColor),

          // ── Область редактирования ─────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSlidePreviewCard(isDark: isDark, cardColor: cardColor, accent: accent),
                  SizedBox(height: 16.h),
                  _buildContentEditor(isDark: isDark, cardColor: cardColor, accent: accent),
                  SizedBox(height: 16.h),
                  _buildSlideNavButtons(isDark: isDark, accent: accent),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Полоса миниатюр ──────────────────────────────────────────────────────

  Widget _buildSlideStrip({
    required bool isDark,
    required Color accent,
    required Color cardColor,
  }) {
    return Container(
      height: 80.h,
      color: isDark ? const Color(0xFF252535) : const Color(0xFFF0F0F7),
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        itemCount: _presentation.slides.length,
        onReorder: _moveSlide,
        itemBuilder: (context, index) {
          final isSelected = index == _currentSlideIndex;
          final slide = _presentation.slides[index];

          return GestureDetector(
            key: ValueKey('strip_$index'),
            onTap: () => _goToSlide(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 96.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected ? accent : cardColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? accent : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 8)]
                    : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      slide.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Карточка заголовка слайда ────────────────────────────────────────────

  Widget _buildSlidePreviewCard({
    required bool isDark,
    required Color cardColor,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Бейдж номера слайда
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Слайд ${_currentSlideIndex + 1} из ${_presentation.slides.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _duplicateSlide,
                icon: Icon(Icons.copy_outlined, color: accent, size: 20.r),
                tooltip: 'Дублировать',
              ),
              IconButton(
                onPressed: _deleteSlide,
                icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20.r),
                tooltip: 'Удалить слайд',
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Заголовок слайда',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _titleController,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Введите заголовок',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF5F5FB),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: accent, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Редактор пунктов ─────────────────────────────────────────────────────

  Widget _buildContentEditor({
    required bool isDark,
    required Color cardColor,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Содержимое',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addContentItem,
                icon: Icon(Icons.add, size: 16.r, color: accent),
                label: Text(
                  'Добавить пункт',
                  style: TextStyle(fontSize: 13.sp, color: accent),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    side: BorderSide(color: accent.withOpacity(0.4)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contentControllers.length,
            onReorder: _moveContentItem,
            itemBuilder: (context, index) {
              return _buildContentItem(
                key: ValueKey('content_${index}_${_currentSlideIndex}'),
                index: index,
                isDark: isDark,
                accent: accent,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentItem({
    required Key key,
    required int index,
    required bool isDark,
    required Color accent,
  }) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Маркер-кружок
          Container(
            width: 7.w,
            height: 7.w,
            margin: EdgeInsets.only(right: 10.w),
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),

          // Поле ввода пункта
          Expanded(
            child: TextField(
              controller: _contentControllers[index],
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Пункт ${index + 1}',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF5F5FB),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
            ),
          ),

          // Удалить пункт
          if (_contentControllers.length > 1)
            IconButton(
              onPressed: () => _removeContentItem(index),
              icon: Icon(Icons.close, size: 18.r, color: Colors.red[300]),
              tooltip: 'Удалить пункт',
            ),

          // Ручка перетаскивания
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Icon(Icons.drag_handle, size: 20.r, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Кнопки навигации слайдов ─────────────────────────────────────────────

  Widget _buildSlideNavButtons({required bool isDark, required Color accent}) {
    return Row(
      children: [
        Expanded(
          child: _NavButton(
            icon: Icons.arrow_back_ios_rounded,
            label: 'Назад',
            enabled: _currentSlideIndex > 0,
            onTap: () => _goToSlide(_currentSlideIndex - 1),
            isDark: isDark,
            accent: accent,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _NavButton(
            icon: Icons.arrow_forward_ios_rounded,
            label: 'Вперёд',
            enabled: _currentSlideIndex < _presentation.slides.length - 1,
            onTap: () => _goToSlide(_currentSlideIndex + 1),
            isDark: isDark,
            accent: accent,
          ),
        ),
      ],
    );
  }
}

// ─── Кнопка навигации ────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDark;
  final Color accent;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? accent
        : (isDark ? Colors.white24 : Colors.black26);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: enabled
              ? accent.withOpacity(0.1)
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: enabled ? accent.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.r, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}