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
  final bool isReviewEligible;
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
    this.isReviewEligible = false,
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
      isReviewEligible: json['is_review_eligible'] == 1 || json['is_review_eligible'] == true,
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

  String get packageSessionTimeOnly {
    final text = packageSessionText;
    if (text.contains(' @ ')) {
      return text.split(' @ ')[0];
    }
    return text;
  }
  
  String? get packageSessionPriceOnly {
    final text = packageSessionText;
    if (text.contains(' @ ')) {
      return text.split(' @ ')[1];
    }
    return null;
  }
}

class PackageSubSession {
  final int id;
  final int packagePurchaseId;
  final String mode; // 'chat' | 'call'
  final int? chatSessionId; // Use this ID for chat API calls
  final int? callSessionId; // Use this ID for call/Agora signaling
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationUsed;

  PackageSubSession({
    required this.id,
    required this.packagePurchaseId,
    required this.mode,
    this.chatSessionId,
    this.callSessionId,
    required this.startedAt,
    this.endedAt,
    required this.durationUsed,
  });

  factory PackageSubSession.fromJson(Map<String, dynamic> json) {
    return PackageSubSession(
      id: json['id'] ?? 0,
      packagePurchaseId: json['package_purchase_id'] ?? 0,
      mode: json['mode'] ?? '',
      chatSessionId: json['chat_session_id'],
      callSessionId: json['call_session_id'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : DateTime.now(),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      durationUsed: json['duration_used'] ?? 0,
    );
  }
}

class PackageChatSession {
  final int id;
  final int consumerId;
  final int providerId;
  final String status;

  PackageChatSession({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.status,
  });

  factory PackageChatSession.fromJson(Map<String, dynamic> json) {
    return PackageChatSession(
      id: json['id'] ?? 0,
      consumerId: json['consumer_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      status: json['status'] ?? '',
    );
  }
}

class PackageCallSession {
  final int id;
  final int consumerId;
  final int providerId;
  final String status;
  final String callType;

  PackageCallSession({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.status,
    required this.callType,
  });

  factory PackageCallSession.fromJson(Map<String, dynamic> json) {
    return PackageCallSession(
      id: json['id'] ?? 0,
      consumerId: json['consumer_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      status: json['status'] ?? '',
      callType: json['call_type'] ?? 'audio',
    );
  }
}

class ActiveStatusResponse {
  final bool hasActivePackage;
  final PackagePurchase? purchase;
  final PackageSubSession? activeSubSession;

  ActiveStatusResponse({
    required this.hasActivePackage,
    this.purchase,
    this.activeSubSession,
  });
}

class StartSubSessionResult {
  final PackageSubSession subSession;
  final int remainingDuration;
  final PackageChatSession? linkedChatSession;
  final PackageCallSession? linkedCallSession;

  StartSubSessionResult({
    required this.subSession,
    required this.remainingDuration,
    this.linkedChatSession,
    this.linkedCallSession,
  });
}

class EndSubSessionResult {
  final PackageSubSession subSession;
  final int remainingDuration;

  EndSubSessionResult({
    required this.subSession,
    required this.remainingDuration,
  });
}

class PackagePurchase {
  final int id;
  final int consumerId;
  final int providerId;
  final int totalDuration;
  final int remainingDuration;
  final double price;
  final String status;

  PackagePurchase({
    required this.id,
    required this.consumerId,
    required this.providerId,
    required this.totalDuration,
    required this.remainingDuration,
    required this.price,
    required this.status,
  });

  factory PackagePurchase.fromJson(Map<String, dynamic> json) {
    return PackagePurchase(
      id: json['id'] ?? 0,
      consumerId: json['consumer_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      totalDuration: json['total_duration'] ?? 0,
      remainingDuration: json['remaining_duration'] ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
    );
  }
}


