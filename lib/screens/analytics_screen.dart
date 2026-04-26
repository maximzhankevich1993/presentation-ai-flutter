import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final String presentationTitle;
  final int slideCount;

  const AnalyticsScreen({
    super.key,
    required this.presentationTitle,
    required this.slideCount,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late PresentationStats _stats;

  @override
  void initState() {
    super.initState();
    _stats = AnalyticsService.getDemoStats(widget.slideCount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('Аналитика'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.presentationTitle, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 24.h),

            // Ключевые метрики
            _buildMetricsGrid(),
            SizedBox(height: 32.h),

            // Аналитика по слайдам
            Text('По слайдам', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            ..._stats.slideAnalytics.map((slide) => _buildSlideAnalyticsCard(slide)),

            SizedBox(height: 32.h),

            // Рекомендации
            Text('Рекомендации', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            ...AnalyticsService.getRecommendations(_stats).map((rec) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFF4F46E5)),
                  SizedBox(width: 12.w),
                  Expanded(child: Text(rec, style: TextStyle(fontSize: 13.sp))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _buildMetricCard('👁', 'Просмотров', _stats.totalViews.toString()),
        _buildMetricCard('👥', 'Уникальных', _stats.uniqueViewers.toString()),
        _buildMetricCard('⏱', 'Среднее время', '${_stats.avgTimePerSlide.toStringAsFixed(1)}с'),
        _buildMetricCard('✅', 'Досмотрели', '${_stats.completionRate.toInt()}%'),
      ],
    );
  }

  Widget _buildMetricCard(String emoji, String label, String value) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 28.sp)),
          SizedBox(height: 8.h),
          Text(value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSlideAnalyticsCard(SlideAnalytics slide) {
    final attentionColor = slide.attentionScore > 75 
        ? Colors.green 
        : slide.attentionScore > 50 
            ? Colors.orange 
            : Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w, height: 40.w,
            decoration: BoxDecoration(color: const Color(0xFF4F46E5), shape: BoxShape.circle),
            child: Center(child: Text('${slide.slideIndex + 1}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('Внимание: ${slide.attentionScore.toInt()}%', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                SizedBox(width: 8.w),
                Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: attentionColor, shape: BoxShape.circle)),
              ]),
              SizedBox(height: 4.h),
              Text('${slide.views} просмотров • ${slide.avgTimeSpent.toStringAsFixed(1)}с в среднем', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
            ]),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}