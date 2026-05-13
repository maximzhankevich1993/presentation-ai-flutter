class User {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final int freeGenerationsLeft;
  final int maxSlidesPerPresentation;
  final DateTime? premiumUntil;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    required this.freeGenerationsLeft,
    required this.maxSlidesPerPresentation,
    this.premiumUntil,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isPremium: json['isPremium'] as bool? ?? false,
      freeGenerationsLeft: json['freeGenerationsLeft'] as int? ?? 5,
      maxSlidesPerPresentation: json['maxSlidesPerPresentation'] as int? ?? 10,
      premiumUntil: json['premiumUntil'] != null 
          ? DateTime.parse(json['premiumUntil'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isPremium': isPremium,
      'freeGenerationsLeft': freeGenerationsLeft,
      'maxSlidesPerPresentation': maxSlidesPerPresentation,
      'premiumUntil': premiumUntil?.toIso8601String(),
      'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    int? freeGenerationsLeft,
    int? maxSlidesPerPresentation,
    DateTime? premiumUntil,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      freeGenerationsLeft: freeGenerationsLeft ?? this.freeGenerationsLeft,
      maxSlidesPerPresentation: maxSlidesPerPresentation ?? this.maxSlidesPerPresentation,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}