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
    final slidesList = (json['slides'] as List)
        .map((s) => Slide.fromJson(s))
        .toList();
    
    return Presentation(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Без названия',
      slides: slidesList,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      fontPair: json['fontPair'],
      themeId: json['themeId'],
      transitionType: json['transitionType'] ?? 'fade',
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
      title: json['title'] ?? '',
      subtitle: json['subtitle'],
      content: List<String>.from(json['content'] ?? []),
      imageUrl: json['imageUrl'] ?? json['image_url'],
      imageKeywords: json['imageKeywords'] ?? json['image_keywords'],
      useCustomImage: json['useCustomImage'] ?? false,
      background: json['background'],
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