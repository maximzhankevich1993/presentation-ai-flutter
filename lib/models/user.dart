class User {
  final String id;
  final String email;
  final String name;
  final bool isPremium;
  final int freeGenerationsLeft;
  final int monthlyGenerationsLeft;
  final DateTime? premiumExpiry;
  final bool isVip;
  final bool hasBonusMonth;  // ← НОВОЕ ПОЛЕ

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.isPremium,
    required this.freeGenerationsLeft,
    required this.monthlyGenerationsLeft,
    this.premiumExpiry,
    this.isVip = false,
    this.hasBonusMonth = false,  // ← НОВОЕ ПОЛЕ
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
      hasBonusMonth: json['hasBonusMonth'] ?? false,  // ← НОВОЕ
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
      'hasBonusMonth': hasBonusMonth,  // ← НОВОЕ
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
    bool? hasBonusMonth,  // ← НОВОЕ
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
      hasBonusMonth: hasBonusMonth ?? this.hasBonusMonth,  // ← НОВОЕ
    );
  }
}