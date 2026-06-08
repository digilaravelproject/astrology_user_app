import 'package:astro_user/core/constants/app_urls.dart';

class AstrologerModel {
  final int id;
  final int userId;
  final int yearsOfExperience;
  final List<String> areasOfExpertise;
  final List<String> languages;
  final String? profilePhoto;
  final String bio;
  final String? chatRate;
  final String? callRate;
  final String? videoCallRate;
  final String name;
  final String? phone;
  final String? email;
  final bool isChatEnabled;
  final bool isCallEnabled;
  final bool isVideoCallEnabled;
  final double rating;
  final bool isOnline;
  final bool isFollowed;
  final bool isBlocked;
  final int totalOrders;

  AstrologerModel({
    required this.id,
    required this.userId,
    required this.yearsOfExperience,
    required this.areasOfExpertise,
    required this.languages,
    this.profilePhoto,
    required this.bio,
    this.chatRate,
    this.callRate,
    this.videoCallRate,
    required this.name,
    this.phone,
    this.email,
    this.isChatEnabled = false,
    this.isCallEnabled = false,
    this.isVideoCallEnabled = false,
    this.isOnline = false,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.isFollowed = false,
    this.isBlocked = false,
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    
    return AstrologerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      yearsOfExperience: json['years_of_experience'] ?? 0,
      areasOfExpertise: List<String>.from(json['areas_of_expertise'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      profilePhoto: json['profile_photo'],
      bio: json['bio'] ?? '',
      chatRate: json['chat_rate_per_minute'],
      callRate: json['call_rate_per_minute'],
      videoCallRate: json['video_call_rate'],
      name: (userData['name']?.toString() ?? 'Unknown').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
      phone: userData['phone'],
      email: userData['email'],
      isChatEnabled: json['is_chat_enabled'] == true,
      isCallEnabled: json['is_call_enabled'] == true,
      isVideoCallEnabled: json['is_video_call_enabled'] == true,
      isOnline: json['is_online'] == 1 || json['is_online'] == true,
      rating: double.tryParse(json['reviews_avg_rating']?.toString() ?? json['avg_rating']?.toString() ?? '0') ?? 0.0,
      totalOrders: json['total_orders'] ?? 0,
      isFollowed: json['is_followed'] == 1 || json['is_followed'] == true,
      isBlocked: json['is_blocked'] == 1 || json['is_blocked'] == true,
    );
  }

  String get fullProfilePhoto => profilePhoto != null ? '${AppUrls.baseImageUrl}$profilePhoto' : '';

  bool get isAvailableOnline => isChatEnabled || isCallEnabled || isVideoCallEnabled;
}
