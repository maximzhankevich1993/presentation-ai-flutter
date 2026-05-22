class User {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final int freeGenerationsLeft;
  final int monthlyGenerationsLeft;
  final DateTime? premiumExpiry;
  final bool isVip;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    required this.freeGenerationsLeft,
    required this.monthlyGenerationsLeft,
    this.premiumExpiry,
    this.isVip = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      isPremium: json['isPremium'] ?? false,
      freeGenerationsLeft: json['freeGenerationsLeft'] ?? 5,
      monthlyGenerationsLeft: json['monthlyGenerationsLeft'] ?? 5,
      premiumExpiry: json['premiumExpiry'] != null 
          ? DateTime.tryParse(json['premiumExpiry']) 
          : null,
      isVip: json['isVip'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isPremium': isPremium,
      'freeGenerationsLeft': freeGenerationsLeft,
      'monthlyGenerationsLeft': monthlyGenerationsLeft,
      'premiumExpiry': premiumExpiry?.toIso8601String(),
      'isVip': isVip,
    };
  }
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? isPremium,
    int? freeGenerationsLeft,
    int? monthlyGenerationsLeft,
    DateTime? premiumExpiry,
    bool? isVip,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isPremium: isPremium ?? this.isPremium,
      freeGenerationsLeft: freeGenerationsLeft ?? this.freeGenerationsLeft,
      monthlyGenerationsLeft: monthlyGenerationsLeft ?? this.monthlyGenerationsLeft,
      premiumExpiry: premiumExpiry ?? this.premiumExpiry,
      isVip: isVip ?? this.isVip,
    );
  }
}