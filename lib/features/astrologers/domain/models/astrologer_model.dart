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
  final String? originalChatRatePerMinute;
  final String? originalCallRatePerMinute;
  final bool hasOffer;
  final String? discountPercentage;
  final int? packagePrice;
  final int? packageDuration;
  final bool? isPurchase;
  final int? remainingTime;

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
    this.originalChatRatePerMinute,
    this.originalCallRatePerMinute,
    this.hasOffer = false,
    this.discountPercentage,
    this.packagePrice,
    this.packageDuration,
    this.isPurchase,
    this.remainingTime,
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
      videoCallRate: json['video_call_rate_per_minute'] ?? json['video_call_rate'],
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
      originalChatRatePerMinute: json['original_chat_rate_per_minute']?.toString(),
      originalCallRatePerMinute: json['original_call_rate_per_minute']?.toString(),
      hasOffer: json['has_offer'] == true,
      discountPercentage: json['offer_details']?['discount_percentage']?.toString(),
      packagePrice: json['package_details']?['price'] != null ? int.tryParse(json['package_details']['price'].toString()) : null,
      packageDuration: json['package_details']?['duration'] != null ? int.tryParse(json['package_details']['duration'].toString()) : null,
      isPurchase: json['package_details']?['is_purchase'] == true,
      remainingTime: json['package_details']?['remaining_time'] != null ? int.tryParse(json['package_details']['remaining_time'].toString()) : null,
    );
  }

  String get fullProfilePhoto => profilePhoto != null ? '${AppUrls.baseImageUrl}$profilePhoto' : '';

  bool get isAvailableOnline => isChatEnabled || isCallEnabled || isVideoCallEnabled;

  String get packageSessionText {
    if (packagePrice == null || packageDuration == null) {
      return 'Session (1 hr) @ ₹500';
    }
    if (isPurchase == true && remainingTime != null) {
      final int remainingSeconds = remainingTime!;
      String remainingTimeStr;
      if (remainingSeconds < 60) {
        remainingTimeStr = '$remainingSeconds sec';
      } else if (remainingSeconds < 3600) {
        final int mins = remainingSeconds ~/ 60;
        remainingTimeStr = '$mins min';
      } else {
        final int remainingMinutes = remainingSeconds ~/ 60;
        final int remDays = remainingMinutes ~/ 1440;
        final int remHours = (remainingMinutes % 1440) ~/ 60;
        final int remMins = remainingMinutes % 60;
        
        if (remDays > 0) {
          if (remHours > 0) {
            remainingTimeStr = '$remDays d $remHours hr';
          } else {
            remainingTimeStr = '$remDays d';
          }
        } else {
          if (remMins > 0) {
            remainingTimeStr = '$remHours hr $remMins min';
          } else {
            remainingTimeStr = '$remHours hr';
          }
        }
      }
      return 'Session ($remainingTimeStr)';
    }
    final int seconds = packageDuration!;
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    
    String durationStr;
    if (hours > 0 && minutes > 0) {
      durationStr = '$hours hr $minutes min';
    } else if (hours > 0) {
      durationStr = '$hours hr';
    } else {
      durationStr = '$minutes min';
    }
    
    return 'Session ($durationStr) @ ₹$packagePrice';
  }
}
