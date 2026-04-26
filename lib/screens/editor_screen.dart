import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/api_service.dart';

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

  void _goToSlide(int index) {
    setState(() => _currentSlideIndex = index);
  }

  void _nextSlide() {
    if (_currentSlideIndex < _presentation.slides.length - 1) {
      setState(() => _currentSlideIndex++);
    }
  }

  void _previousSlide() {
    if (_currentSlideIndex > 0) {
      setState(() => _currentSlideIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(_presentation.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Экспорт
            },
            icon: const Icon(Icons.download),
            tooltip: 'Скачать',
          ),
          IconButton(
            onPressed: () {
              // Поделиться
            },
            icon: const Icon(Icons.share),
            tooltip: 'Поделиться',
          ),
        ],
      ),
      body: Column(
        children: [
          // Предпросмотр слайда
          Expanded(
            child: _buildSlidePreview(_currentSlide, isDark),
          ),
          
          // Навигация по слайдам
          _buildSlideNavigation(),
          
          // Содержание слайда
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _buildSlideContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidePreview(Slide slide, bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Фоновое изображение
            if (slide.imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  slide.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            
            // Затемнение для читаемости
            if (slide.imageUrl != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            
            // Контент слайда
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Text(
                    slide.title,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: slide.imageUrl != null ? Colors.white : Colors.black87,
                    ),
                  ),
                  
                  if (slide.subtitle != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      slide.subtitle!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: slide.imageUrl != null ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                  
                  SizedBox(height: 20.h),
                  
                  // Буллеты
                  ...slide.content.map((item) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6.h, right: 12.w),
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: slide.imageUrl != null 
                                  ? Colors.white 
                                  : const Color(0xFF4F46E5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.5,
                                color: slide.imageUrl != null 
                                    ? Colors.white 
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
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
          // Предыдущий слайд
          IconButton(
            onPressed: _currentSlideIndex > 0 ? _previousSlide : null,
            icon: Icon(
              Icons.chevron_left,
              color: _currentSlideIndex > 0 ? const Color(0xFF4F46E5) : Colors.grey,
            ),
          ),
          
          // Индикатор
          Column(
            children: [
              Text(
                'Слайд ${_currentSlideIndex + 1} из $totalSlides',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalSlides, (index) {
                  return GestureDetector(
                    onTap: () => _goToSlide(index),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentSlideIndex
                            ? const Color(0xFF4F46E5)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          
          // Следующий слайд
          IconButton(
            onPressed: _currentSlideIndex < totalSlides - 1 ? _nextSlide : null,
            icon: Icon(
              Icons.chevron_right,
              color: _currentSlideIndex < totalSlides - 1 ? const Color(0xFF4F46E5) : Colors.grey,
            ),
          ),
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
          Row(
            children: [
              Icon(Icons.list, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8.w),
              Text(
                'Содержание слайда',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._currentSlide.content.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(fontSize: 14.sp, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}