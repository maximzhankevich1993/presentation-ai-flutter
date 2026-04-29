class Presentation {
  final String id;
  final String title;
  final List<Slide> slides;
  final DateTime createdAt;
  String? fontPair;
  String? themeId;
  String transitionType;

  Presentation({
    required this.id,
    required this.title,
    required this.slides,
    required this.createdAt,
    this.fontPair,
    this.themeId,
    this.transitionType = 'fade',
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    final slidesList = (json['slides'] as List?)
            ?.map((s) => Slide.fromJson(s))
            .toList() ??
        [];

    return Presentation(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Без названия',
      slides: slidesList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      fontPair: json['fontPair']?.toString(),
      themeId: json['themeId']?.toString(),
      transitionType: json['transitionType']?.toString() ?? 'fade',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'slides': slides.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'fontPair': fontPair,
        'themeId': themeId,
        'transitionType': transitionType,
      };
}

class Slide {
  String title;
  String? subtitle;
  List<String> content;
  String? imageUrl;
  String? imageKeywords;
  bool useCustomImage;
  Map<String, dynamic>? background;

  Slide({
    required this.title,
    this.subtitle,
    this.content = const [],
    this.imageUrl,
    this.imageKeywords,
    this.useCustomImage = false,
    this.background,
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      content: (json['content'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString(),
      imageKeywords: json['imageKeywords']?.toString() ??
          json['image_keywords']?.toString(),
      useCustomImage: json['useCustomImage'] ?? false,
      background: json['background'] is Map<String, dynamic>
          ? json['background']
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'content': content,
        'imageUrl': imageUrl,
        'imageKeywords': imageKeywords,
        'useCustomImage': useCustomImage,
        'background': background,
      };
}