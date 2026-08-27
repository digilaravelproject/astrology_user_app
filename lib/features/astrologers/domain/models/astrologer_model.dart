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
  final String? profilePhotoUrl;
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
  final String? ordersFormatted;
  final String? originalChatRatePerMinute;
  final String? originalCallRatePerMinute;
  final bool poAt5Enabled;
  final double? poAt5RatePerMinute;
  final int? poAt5Sessions;
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
    this.profilePhotoUrl,
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
    this.ordersFormatted,
    this.isFollowed = false,
    this.isBlocked = false,
    this.isReviewEligible = false,
    this.originalChatRatePerMinute,
    this.originalCallRatePerMinute,
    this.poAt5Enabled = false,
    this.poAt5RatePerMinute,
    this.poAt5Sessions,
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
    final userData = (json['user'] is Map) ? Map<String, dynamic>.from(json['user']) : <String, dynamic>{};
    final availData = (json['availability'] is Map) ? Map<String, dynamic>.from(json['availability']) : <String, dynamic>{};
    final offerDetails = (json['offer_details'] is Map) ? Map<String, dynamic>.from(json['offer_details']) : <String, dynamic>{};
    final packageDetails = (json['package_details'] is Map) ? Map<String, dynamic>.from(json['package_details']) : <String, dynamic>{};

    bool parseBool(dynamic val) {
      if (val == null) return false;
      return val == true || val == 1 || val.toString() == '1' || val.toString().toLowerCase() == 'true';
    }

    final bool isChat = parseBool(json['is_chat_enabled']) ||
                        parseBool(json['chat_enabled']) ||
                        parseBool(userData['is_chat_enabled']) ||
                        parseBool(userData['chat_enabled']) ||
                        parseBool(availData['is_chat_enabled']) ||
                        parseBool(availData['chat_enabled']);

    final bool isCall = parseBool(json['is_call_enabled']) ||
                        parseBool(json['call_enabled']) ||
                        parseBool(userData['is_call_enabled']) ||
                        parseBool(userData['call_enabled']) ||
                        parseBool(availData['is_call_enabled']) ||
                        parseBool(availData['call_enabled']);

    final bool isVideo = parseBool(json['is_video_call_enabled']) ||
                         parseBool(json['video_call_enabled']) ||
                         parseBool(userData['is_video_call_enabled']) ||
                         parseBool(userData['video_call_enabled']) ||
                         parseBool(availData['is_video_call_enabled']) ||
                         parseBool(availData['video_call_enabled']);

    final rawName = (json['name'] ?? userData['name'] ?? 'Astrologer').toString().trim();
    final formattedName = rawName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' ');

    return AstrologerModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      yearsOfExperience: int.tryParse(json['years_of_experience']?.toString() ?? json['experience']?.toString() ?? '') ?? 0,
      areasOfExpertise: (json['areas_of_expertise'] is List)
          ? (json['areas_of_expertise'] as List).map((e) => e.toString()).toList()
          : [],
      languages: (json['languages'] is List)
          ? (json['languages'] as List).map((e) => e.toString()).toList()
          : [],
      profilePhoto: json['profile_photo']?.toString(),
      profilePhotoUrl: json['profile_photo_url']?.toString() ?? userData['profile_photo_url']?.toString(),
      bio: json['bio']?.toString() ?? '',
      chatRate: json['chat_rate_per_minute']?.toString(),
      callRate: json['call_rate_per_minute']?.toString(),
      videoCallRate: (json['video_call_rate_per_minute'] ?? json['video_call_rate'])?.toString(),
      name: formattedName.isNotEmpty ? formattedName : 'Astrologer',
      phone: userData['phone']?.toString(),
      email: userData['email']?.toString(),
      isChatEnabled: isChat,
      isCallEnabled: isCall,
      isVideoCallEnabled: isVideo,
      isOnline: parseBool(json['is_online']) || json['availability_status']?.toString().toLowerCase() == 'online',
      rating: double.tryParse(json['avg_rating']?.toString() ?? json['reviews_avg_rating']?.toString() ?? json['rating']?.toString() ?? '0.0') ?? 0.0,
      totalOrders: int.tryParse(json['total_orders']?.toString() ?? json['orders_count']?.toString() ?? json['completed_orders_count']?.toString() ?? '0') ?? 0,
      ordersFormatted: json['orders_formatted']?.toString(),
      isFollowed: parseBool(json['is_followed']),
      isBlocked: parseBool(json['is_blocked']),
      isReviewEligible: parseBool(json['is_review_eligible']),
      originalChatRatePerMinute: json['original_chat_rate_per_minute']?.toString(),
      originalCallRatePerMinute: json['original_call_rate_per_minute']?.toString(),
      poAt5Enabled: parseBool(json['po_at_5_enabled']),
      poAt5RatePerMinute: double.tryParse(json['po_at_5_rate_per_minute']?.toString() ?? ''),
      poAt5Sessions: int.tryParse(json['po_at_5_sessions']?.toString() ?? ''),
      hasOffer: parseBool(json['has_offer']),
      discountPercentage: offerDetails['discount_percentage']?.toString(),
      packagePrice: packageDetails['price'] != null ? int.tryParse(packageDetails['price'].toString()) : null,
      packageDuration: packageDetails['duration'] != null ? int.tryParse(packageDetails['duration'].toString()) : null,
      isPurchase: parseBool(packageDetails['is_purchase']),
      remainingTime: packageDetails['remaining_time'] != null ? int.tryParse(packageDetails['remaining_time'].toString()) : null,
      isBusy: parseBool(json['is_busy']) || json['availability_status']?.toString().toLowerCase() == 'engaged' || json['availability_status']?.toString().toLowerCase() == 'busy',
      availabilityStatus: json['availability_status']?.toString() ?? (parseBool(json['is_online']) ? 'Online' : 'Offline'),
    );
  }

  String get fullProfilePhoto {
    if (profilePhotoUrl != null && profilePhotoUrl!.trim().isNotEmpty) {
      return profilePhotoUrl!.trim();
    }
    if (profilePhoto != null && profilePhoto!.trim().isNotEmpty) {
      if (profilePhoto!.startsWith('http')) return profilePhoto!.trim();
      return '${AppUrls.baseImageUrl}${profilePhoto!.startsWith('/') ? profilePhoto!.substring(1) : profilePhoto}';
    }
    return '';
  }

  String get formattedOrders => ordersFormatted ?? (totalOrders > 0 ? '$totalOrders+ orders' : '100+ orders');

  bool get isAvailableOnline => !isBusy && isOnline && (isChatEnabled || isCallEnabled);

  Map<String, dynamic> get statusBadge {
    if (isBusy || availabilityStatus.toLowerCase() == 'engaged' || availabilityStatus.toLowerCase() == 'busy') {
      return { 'text': 'Busy', 'color': const Color(0xFFEF4444), 'buttonText': 'Busy' };
    }
    if (!isOnline || (!isChatEnabled && !isCallEnabled) || availabilityStatus.toLowerCase() == 'offline') {
      return { 'text': 'Offline', 'color': const Color(0xFF94A3B8), 'buttonText': 'Offline' };
    }
    return { 'text': 'Online', 'color': const Color(0xFF22C55E), 'buttonText': 'Call / Chat' };
  }

  Color get statusColor => statusBadge['color'] as Color;

  AstrologerModel copyWith({
    int? id,
    int? userId,
    int? yearsOfExperience,
    List<String>? areasOfExpertise,
    List<String>? languages,
    String? profilePhoto,
    String? profilePhotoUrl,
    String? bio,
    String? chatRate,
    String? callRate,
    String? videoCallRate,
    String? name,
    String? phone,
    String? email,
    bool? isChatEnabled,
    bool? isCallEnabled,
    bool? isVideoCallEnabled,
    double? rating,
    bool? isOnline,
    bool? isFollowed,
    bool? isBlocked,
    bool? isReviewEligible,
    int? totalOrders,
    String? ordersFormatted,
    String? originalChatRatePerMinute,
    String? originalCallRatePerMinute,
    bool? poAt5Enabled,
    double? poAt5RatePerMinute,
    int? poAt5Sessions,
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
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      chatRate: chatRate ?? this.chatRate,
      callRate: callRate ?? this.callRate,
      videoCallRate: videoCallRate ?? this.videoCallRate,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isChatEnabled: isChatEnabled ?? this.isChatEnabled,
      isCallEnabled: isCallEnabled ?? this.isCallEnabled,
      isVideoCallEnabled: isVideoCallEnabled ?? this.isVideoCallEnabled,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      ordersFormatted: ordersFormatted ?? this.ordersFormatted,
      isFollowed: isFollowed ?? this.isFollowed,
      isBlocked: isBlocked ?? this.isBlocked,
      isReviewEligible: isReviewEligible ?? this.isReviewEligible,
      originalChatRatePerMinute: originalChatRatePerMinute ?? this.originalChatRatePerMinute,
      originalCallRatePerMinute: originalCallRatePerMinute ?? this.originalCallRatePerMinute,
      poAt5Enabled: poAt5Enabled ?? this.poAt5Enabled,
      poAt5RatePerMinute: poAt5RatePerMinute ?? this.poAt5RatePerMinute,
      poAt5Sessions: poAt5Sessions ?? this.poAt5Sessions,
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


