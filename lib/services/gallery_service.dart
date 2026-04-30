import 'dart:math';
import '../models/presentation.dart';

class GalleryItem {
  final String id;
  final String title;
  final String authorName;
  final int likes;
  final int views;
  final String category;
  final String thumbnailUrl;
  final int slideCount;
  final DateTime publishedAt;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.authorName,
    required this.likes,
    required this.views,
    required this.category,
    required this.thumbnailUrl,
    required this.slideCount,
    required this.publishedAt,
  });
}

class GalleryService {
  static final Random _random = Random();

  static final List<GalleryItem> _cache = [
    GalleryItem(
      id: '1',
      title: 'Будущее искусственного интеллекта',
      authorName: 'Анна М.',
      likes: 234,
      views: 1230,
      category: 'Технологии',
      thumbnailUrl: 'https://picsum.photos/300/200?1',
      slideCount: 12,
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    GalleryItem(
      id: '2',
      title: 'Стратегия развития стартапа',
      authorName: 'Дмитрий К.',
      likes: 187,
      views: 980,
      category: 'Бизнес',
      thumbnailUrl: 'https://picsum.photos/300/200?2',
      slideCount: 15,
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    GalleryItem(
      id: '3',
      title: 'Основы квантовой физики',
      authorName: 'Елена С.',
      likes: 312,
      views: 1560,
      category: 'Наука',
      thumbnailUrl: 'https://picsum.photos/300/200?3',
      slideCount: 20,
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    GalleryItem(
      id: '4',
      title: 'Маркетинг в социальных сетях',
      authorName: 'Максим Р.',
      likes: 156,
      views: 820,
      category: 'Маркетинг',
      thumbnailUrl: 'https://picsum.photos/300/200?4',
      slideCount: 10,
      publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    GalleryItem(
      id: '5',
      title: 'Здоровый образ жизни',
      authorName: 'Ольга В.',
      likes: 278,
      views: 1450,
      category: 'Здоровье',
      thumbnailUrl: 'https://picsum.photos/300/200?5',
      slideCount: 8,
      publishedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    GalleryItem(
      id: '6',
      title: 'Кибербезопасность в 2026',
      authorName: 'Игорь Л.',
      likes: 345,
      views: 2100,
      category: 'Технологии',
      thumbnailUrl: 'https://picsum.photos/300/200?6',
      slideCount: 18,
      publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];

  /// Демо-галерея (immutable)
  static List<GalleryItem> getDemoGallery() => List.unmodifiable(_cache);

  /// Топ по лайкам
  static List<GalleryItem> getTopRated({int limit = 10}) {
    final items = [..._cache];
    items.sort((a, b) => b.likes.compareTo(a.likes));
    return items.take(limit).toList();
  }

  /// Новые
  static List<GalleryItem> getNewest({int limit = 10}) {
    final items = [..._cache];
    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items.take(limit).toList();
  }

  /// Просмотры
  static List<GalleryItem> getMostViewed({int limit = 10}) {
    final items = [..._cache];
    items.sort((a, b) => b.views.compareTo(a.views));
    return items.take(limit).toList();
  }

  /// Категории (стабильный порядок)
  static List<String> getCategories() {
    final set = <String>{};
    for (final item in _cache) {
      set.add(item.category);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  /// Фильтр
  static List<GalleryItem> getByCategory(String category) {
    return _cache
        .where((item) => item.category == category)
        .toList();
  }

  /// Формат чисел
  static String formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}