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

  @override
  void initState() {
    super.initState();
    _presentation = widget.presentation;
  }

  Slide get _currentSlide => _presentation.slides[_currentSlideIndex];

  void _goToSlide(int index) => setState(() => _currentSlideIndex = index);

  void _exportPresentation() async {
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
                ListTile(
                  leading: Icon(Icons.image, color: isPremium ? Colors.green : Colors.grey),
                  title: const Text('PNG (изображения)'),
                  subtitle: Text(isPremium ? 'Все слайды как картинки' : 'Premium'),
                  trailing: isPremium ? const Icon(Icons.chevron_right) : const Icon(Icons.lock),
                  onTap: isPremium ? () { Navigator.pop(context); ExportService.exportToImages(presentation: _presentation, isPremium: true); } : null,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
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
          IconButton(onPressed: _exportPresentation, icon: const Icon(Icons.download), tooltip: 'Скачать'),
          IconButton(onPressed: () => ExportService.shareAsText(_presentation), icon: const Icon(Icons.share), tooltip: 'Поделиться'),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildSlidePreview(_currentSlide, isDark)),
          _buildSlideNavigation(),
          Container(
            height: 200.h,
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
            child: _buildSlideContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidePreview(Slide slide, bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            if (slide.imageUrl != null)
              Positioned.fill(child: Image.network(slide.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48, color: Colors.grey)))),
            if (slide.imageUrl != null)
              Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.1)]))),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(slide.title, style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: slide.imageUrl != null ? Colors.white : Colors.black87)),
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
    );
  }

  Widget _buildSlideNavigation() {
    final totalSlides = _presentation.slides.length;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: _currentSlideIndex > 0 ? () => _goToSlide(_currentSlideIndex - 1) : null, icon: Icon(Icons.chevron_left, color: _currentSlideIndex > 0 ? const Color(0xFF4F46E5) : Colors.grey)),
          Column(
            children: [
              Text('Слайд ${_currentSlideIndex + 1} из $totalSlides', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSlides, (index) => GestureDetector(
                  onTap: () => _goToSlide(index),
                  child: Container(width: 8.w, height: 8.w, margin: EdgeInsets.symmetric(horizontal: 4.w), decoration: BoxDecoration(shape: BoxShape.circle, color: index == _currentSlideIndex ? const Color(0xFF4F46E5) : Colors.grey.withOpacity(0.3))),
                )),
              ),
            ],
          ),
          IconButton(onPressed: _currentSlideIndex < totalSlides - 1 ? () => _goToSlide(_currentSlideIndex + 1) : null, icon: Icon(Icons.chevron_right, color: _currentSlideIndex < totalSlides - 1 ? const Color(0xFF4F46E5) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSlideContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.list, size: 18, color: Colors.grey[600]), SizedBox(width: 8.w), Text('Содержание слайда', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[600]))]),
          SizedBox(height: 12.h),
          ..._currentSlide.content.asMap().entries.map((entry) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(width: 24.w, height: 24.w, decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Center(child: Text('${entry.key + 1}', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600)))),
                SizedBox(width: 12.w),
                Expanded(child: Text(entry.value, style: TextStyle(fontSize: 14.sp, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}