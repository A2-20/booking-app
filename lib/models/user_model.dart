class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String language;
  final List<String> bookingIds;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    this.language = 'ar',
    this.bookingIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: (json['userId'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      language: json['language'] as String? ?? 'ar',
      bookingIds:
          (json['bookingIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'country': country,
      'language': language,
      'bookingIds': bookingIds,
    };
  }

  UserModel copyWith({
    String? userId,
    String? fullName,
    String? email,
    String? phone,
    String? country,
    String? language,
    List<String>? bookingIds,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      language: language ?? this.language,
      bookingIds: bookingIds ?? this.bookingIds,
    );
  }
}
