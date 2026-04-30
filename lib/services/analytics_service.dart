import 'dart:math';

class AnalyticsService {
  static final Random _random = Random();

  static PresentationStats getDemoStats(int slideCount) {
    final slideAnalytics = <SlideAnalytics>[];

    int totalViews = 0;
    double totalTime = 0;

    for (int i = 0; i < slideCount; i++) {
      final views = 100 + _random.nextInt(200);
      final avgTime = 3.0 + _random.nextDouble() * 25;

      final attention = _calculateAttention(views, avgTime, i, slideCount);

      totalViews += views;
      totalTime += avgTime;

      slideAnalytics.add(SlideAnalytics(
        slideIndex: i,
        views: views,
        avgTimeSpent: avgTime,
        attentionScore: attention,
        hotZones: _generateHotZones(attention),
      ));
    }

    final sortedByEngagement = List<SlideAnalytics>.from(slideAnalytics)
      ..sort((a, b) {
        final scoreA = _engagementScore(a);
        final scoreB = _engagementScore(b);
        return scoreB.compareTo(scoreA);
      });

    final completionRate =
        _calculateCompletionRate(slideAnalytics, slideCount);

    return PresentationStats(
      totalViews: totalViews,
      uniqueViewers: (totalViews * 0.6).toInt(),
      avgTimePerSlide: totalTime / slideCount,
      completionRate: completionRate,
      slideAnalytics: slideAnalytics,
      mostEngagingSlide:
          'Слайд ${sortedByEngagement.first.slideIndex + 1}',
      leastEngagingSlide:
          'Слайд ${sortedByEngagement.last.slideIndex + 1}',
    );
  }

  static double _calculateAttention(
    int views,
    double time,
    int index,
    int total,
  ) {
    final positionFactor = 1.0 - (index / total) * 0.3;
    final timeFactor = min(time / 15.0, 1.0);
    final noise = _random.nextDouble() * 10;

    return ((views / 10) * 0.3 +
            timeFactor * 50 +
            positionFactor * 30 +
            noise)
        .clamp(0, 100);
  }

  static double _engagementScore(SlideAnalytics s) {
    return (s.attentionScore * 0.5) +
        (s.avgTimeSpent * 2) +
        (s.views * 0.1);
  }

  static double _calculateCompletionRate(
    List<SlideAnalytics> slides,
    int total,
  ) {
    final lastSlide = slides.last;
    final retentionFactor = lastSlide.views /
        max(slides.first.views, 1);

    return (retentionFactor * 100).clamp(0, 100);
  }

  static List<String> _generateHotZones(double attention) {
    if (attention > 80) {
      return ['Заголовок', 'CTA', 'Изображение'];
    } else if (attention > 50) {
      return ['Заголовок', 'Первый буллет'];
    } else {
      return ['Заголовок'];
    }
  }

  static List<String> getRecommendations(PresentationStats stats) {
    final recommendations = <String>[];

    if (stats.completionRate < 70) {
      recommendations.add(
        'Низкое удержание (${stats.completionRate.toInt()}%) — сократите структуру',
      );
    }

    if (stats.avgTimePerSlide < 6) {
      recommendations.add(
        'Слабое вовлечение — добавьте визуальные элементы',
      );
    }

    final lowAttention = stats.slideAnalytics
        .where((s) => s.attentionScore < 60)
        .toList();

    if (lowAttention.isNotEmpty) {
      recommendations.add(
        'Проблемные слайды: ${lowAttention.map((s) => s.slideIndex + 1).join(', ')}',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Отличная презентация — высокая вовлечённость аудитории',
      );
    }

    return recommendations;
  }

  static Map<String, int> getHeatMap(int slideIndex) {
    return {
      'Заголовок': 60 + _random.nextInt(40),
      'Изображение': 40 + _random.nextInt(60),
      'Текст': 30 + _random.nextInt(50),
      'CTA': 20 + _random.nextInt(70),
    };
  }
}