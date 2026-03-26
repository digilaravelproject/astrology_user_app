class ReviewModel {
  final int id;
  final int astrologerId;
  final int userId;
  final double rating;
  final String review;
  final String? reply;
  final DateTime? replyAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;

  ReviewModel({
    required this.id,
    required this.astrologerId,
    required this.userId,
    required this.rating,
    required this.review,
    this.reply,
    this.replyAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    
    return ReviewModel(
      id: json['id'] ?? 0,
      astrologerId: json['astrologer_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      review: json['review'] ?? '',
      reply: json['reply'],
      replyAt: json['reply_at'] != null ? DateTime.parse(json['reply_at']!) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']!) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']!) : DateTime.now(),
      user: userData.isNotEmpty ? UserModel.fromJson(userData) : null,
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? city;
  final String? country;
  final String? profilePhoto;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final List<String> languages;
  final bool profileCompleted;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.city,
    this.country,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    required this.languages,
    required this.profileCompleted,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      email: json['email'],
      phone: json['phone'],
      city: json['city'],
      country: json['country'],
      profilePhoto: json['profile_photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      timeOfBirth: json['time_of_birth'],
      placeOfBirth: json['place_of_birth'],
      languages: List<String>.from(json['languages'] ?? []),
      profileCompleted: json['profile_completed'] == true,
    );
  }
}
