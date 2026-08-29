import 'package:astro_user/core/constants/app_urls.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
  final bool isBusy;
  final String availabilityStatus;

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
    this.isBusy = false,
    this.availabilityStatus = 'Offline',
  });

  factory AstrologerModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    
    return AstrologerModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      yearsOfExperience: int.tryParse(json['years_of_experience']?.toString() ?? json['experience']?.toString() ?? '') ?? 0,
      areasOfExpertise: List<String>.from(json['areas_of_expertise'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      profilePhoto: json['profile_photo'],
      bio: json['bio'] ?? '',
      chatRate: json['chat_rate_per_minute']?.toString(),
      callRate: json['call_rate_per_minute']?.toString(),
      videoCallRate: (json['video_call_rate_per_minute'] ?? json['video_call_rate'])?.toString(),
      name: (userData['name']?.toString() ?? 'Unknown').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
      phone: userData['phone'],
      email: userData['email'],
      isChatEnabled: json['is_chat_enabled'] == true || json['is_chat_enabled'] == 1 || json['is_chat_enabled']?.toString() == '1' || json['is_chat_enabled']?.toString() == 'true' || json['chat_enabled'] == true || json['chat_enabled'] == 1 || json['chat_enabled']?.toString() == '1' || json['chat_enabled']?.toString() == 'true',
      isCallEnabled: json['is_call_enabled'] == true || json['is_call_enabled'] == 1 || json['is_call_enabled']?.toString() == '1' || json['is_call_enabled']?.toString() == 'true' || json['call_enabled'] == true || json['call_enabled'] == 1 || json['call_enabled']?.toString() == '1' || json['call_enabled']?.toString() == 'true',
      isOnline: json['is_online'] == 1 || json['is_online'] == true || json['is_online']?.toString() == '1' || json['is_online']?.toString() == 'true',
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? json['orders_count']?.toString() ?? json['completed_orders_count']?.toString() ?? '0') ?? 0,
      isFollowed: json['is_followed'] == 1 || json['is_followed'] == true || json['is_followed']?.toString() == '1' || json['is_followed']?.toString() == 'true',
      isBlocked: json['is_blocked'] == 1 || json['is_blocked'] == true || json['is_blocked']?.toString() == '1' || json['is_blocked']?.toString() == 'true',
      isReviewEligible: json['is_review_eligible'] == 1 || json['is_review_eligible'] == true || json['is_review_eligible']?.toString() == '1' || json['is_review_eligible']?.toString() == 'true',
      originalChatRatePerMinute: json['original_chat_rate_per_minute']?.toString(),
      originalCallRatePerMinute: json['original_call_rate_per_minute']?.toString(),
      hasOffer: json['has_offer'] == true,
      discountPercentage: json['offer_details']?['discount_percentage']?.toString(),
      packagePrice: json['package_details']?['price'] != null ? int.tryParse(json['package_details']['price'].toString()) : null,
      packageDuration: json['package_details']?['duration'] != null ? int.tryParse(json['package_details']['duration'].toString()) : null,
      isPurchase: json['package_details']?['is_purchase'] == true,
      remainingTime: json['package_details']?['remaining_time'] != null ? int.tryParse(json['package_details']['remaining_time'].toString()) : null,
      isBusy: json['is_busy'] == 1 || json['is_busy'] == true,
      availabilityStatus: json['availability_status'] ?? (json['is_online'] == 1 || json['is_online'] == true ? 'Online' : 'Offline'),
    );
  }

  String get fullProfilePhoto => profilePhoto != null ? '${AppUrls.baseImageUrl}$profilePhoto' : '';

  bool get isAvailableOnline => !isBusy && isOnline && (isChatEnabled || isCallEnabled);

  Map<String, dynamic> get statusBadge {
    switch (availabilityStatus) {
      case 'Engaged':
        return { 'text': 'Engaged', 'color': Colors.orange, 'buttonText': 'Busy' };
      case 'Online':
        return { 'text': 'Online', 'color': Colors.green, 'buttonText': 'Call / Chat' };
      case 'Offline':
      default:
        return { 'text': 'Offline', 'color': Colors.grey, 'buttonText': 'Offline' };
    }
  }

  AstrologerModel copyWith({
    int? id,
    int? userId,
    int? yearsOfExperience,
    List<String>? areasOfExpertise,
    List<String>? languages,
    String? profilePhoto,
    String? bio,
    String? chatRate,
    String? callRate,
    String? videoCallRate,
    String? name,
    String? phone,
    String? email,
    bool? isChatEnabled,
    bool? isCallEnabled,
    double? rating,
    bool? isOnline,
    bool? isFollowed,
    bool? isBlocked,
    bool? isReviewEligible,
    int? totalOrders,
    String? originalChatRatePerMinute,
    String? originalCallRatePerMinute,
    bool? hasOffer,
    String? discountPercentage,
    int? packagePrice,
    int? packageDuration,
    bool? isPurchase,
    int? remainingTime,
    bool? isBusy,
    String? availabilityStatus,
  }) {
    return AstrologerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      areasOfExpertise: areasOfExpertise ?? this.areasOfExpertise,
      languages: languages ?? this.languages,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      chatRate: chatRate ?? this.chatRate,
      callRate: callRate ?? this.callRate,
      videoCallRate: videoCallRate ?? this.videoCallRate,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      isCallEnabled: isCallEnabled ?? this.isCallEnabled,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      isFollowed: isFollowed ?? this.isFollowed,
      isBlocked: isBlocked ?? this.isBlocked,
      isReviewEligible: isReviewEligible ?? this.isReviewEligible,
      originalChatRatePerMinute: originalChatRatePerMinute ?? this.originalChatRatePerMinute,
      originalCallRatePerMinute: originalCallRatePerMinute ?? this.originalCallRatePerMinute,
      hasOffer: hasOffer ?? this.hasOffer,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      packagePrice: packagePrice ?? this.packagePrice,
      packageDuration: packageDuration ?? this.packageDuration,
      isPurchase: isPurchase ?? this.isPurchase,
      remainingTime: remainingTime ?? this.remainingTime,
      isBusy: isBusy ?? this.isBusy,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }

  String get packageSessionText {
    if (packagePrice == null || packageDuration == null) {
      return '${'Session'.tr} (1 hr) @ ₹500';
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
      return '${'Session'.tr} ($remainingTimeStr)';
    }
    final int seconds = packageDuration!;
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    
    String durationStr;
    if (hours > 0 && minutes > 0) {
      durationStr = '$hours ${"hr".tr} $minutes ${"min".tr}';
    } else if (hours > 0) {
      durationStr = '$hours ${"hr".tr}';
    } else {
      durationStr = '$minutes ${"min".tr}';
    }
    
    return '${'Session'.tr} ($durationStr) @ ₹$packagePrice';
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


