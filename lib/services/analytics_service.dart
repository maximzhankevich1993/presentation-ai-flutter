import 'dart:math';

class SlideAnalytics {
  final int slideIndex;
  final int views;
  final double avgTimeSpent;
  final double attentionScore;
  final List<String> hotZones;

  const SlideAnalytics({
    required this.slideIndex,
    required this.views,
    required this.avgTimeSpent,
    required this.attentionScore,
    required this.hotZones,
  });
}

class PresentationStats {
  final int totalViews;
  final int uniqueViewers;
  final double avgTimePerSlide;
  final double completionRate;
  final List<SlideAnalytics> slideAnalytics;
  final String mostEngagingSlide;
  final String leastEngagingSlide;

  const PresentationStats({
    required this.totalViews,
    required this.uniqueViewers,
    required this.avgTimePerSlide,
    required this.completionRate,
    required this.slideAnalytics,
    required this.mostEngagingSlide,
    required this.leastEngagingSlide,
  });
}

class AnalyticsService {
  static final Random _random = Random();

  static PresentationStats getDemoStats(int slideCount) {
    final slideAnalytics = <SlideAnalytics>[];
    
    for (int i = 0; i < slideCount; i++) {
      slideAnalytics.add(SlideAnalytics(
        slideIndex: i,
        views: 100 + _random.nextInt(200),
        avgTimeSpent: 5.0 + _random.nextDouble() * 20,
        attentionScore: 50.0 + _random.nextDouble() * 50,
        hotZones: ['Заголовок', 'Изображение', 'Первый буллет'],
      ));
    }

    final sorted = List<SlideAnalytics>.from(slideAnalytics)
      ..sort((a, b) => b.attentionScore.compareTo(a.attentionScore));

    return PresentationStats(
      totalViews: 250 + _random.nextInt(500),
      uniqueViewers: 80 + _random.nextInt(120),
      avgTimePerSlide: 8.0 + _random.nextDouble() * 10,
      completionRate: 60.0 + _random.nextDouble() * 35,
      slideAnalytics: slideAnalytics,
      mostEngagingSlide: 'Слайд ${sorted.first.slideIndex + 1}',
      leastEngagingSlide: 'Слайд ${sorted.last.slideIndex + 1}',
    );
  }

  static List<String> getRecommendations(PresentationStats stats) {
    final recommendations = <String>[];
    
    if (stats.completionRate < 70) {
      recommendations.add('Только ${stats.completionRate.toInt()}% зрителей досматривают до конца. Попробуйте сократить презентацию.');
    }
    
    if (stats.avgTimePerSlide < 5) {
      recommendations.add('Зрители проводят мало времени на слайдах. Добавьте больше визуального контента.');
    }
    
    final lowAttentionSlides = stats.slideAnalytics.where((s) => s.attentionScore < 60).toList();
    if (lowAttentionSlides.isNotEmpty) {
      final slideNumbers = lowAttentionSlides.map((s) => 'Слайд ${s.slideIndex + 1}').join(', ');
      recommendations.add('Слайды с низким вниманием: $slideNumbers. Добавьте изображения или измените текст.');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Отличные показатели! Презентация хорошо удерживает внимание аудитории.');
    }
    
    return recommendations;
  }

  static Map<String, int> getHeatMap(int slideIndex) {
    final random = Random();
    return {
      'Заголовок': 50 + random.nextInt(50),
      'Изображение': 30 + random.nextInt(70),
      'Верхний буллет': 40 + random.nextInt(60),
      'Нижний буллет': 20 + random.nextInt(40),
    };
  }
}