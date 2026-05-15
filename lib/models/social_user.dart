class SocialUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String provider; // 'google', 'apple'

  SocialUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatarUrl': avatarUrl,
    'provider': provider,
  };

  factory SocialUser.fromJson(Map<String, dynamic> json) {
    return SocialUser(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
      provider: json['provider'],
    );
  }
}