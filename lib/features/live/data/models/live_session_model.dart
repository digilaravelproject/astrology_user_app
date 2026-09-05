class LiveSessionModel {
  final int id;
  final int? astrologerId;
  final String title;
  final String? description;
  final String sessionType;
  final String? status;
  final String? streamUrl;
  final int viewerCount;
  final DateTime? startedAt;
  final LiveAstrologerModel? astrologer;
  final bool isBroadcasting;
  final bool isCameraOn;
  final bool isAudioOn;

  LiveSessionModel({
    required this.id,
    this.astrologerId,
    required this.title,
    this.description,
    required this.sessionType,
    this.status,
    this.streamUrl,
    required this.viewerCount,
    this.startedAt,
    this.astrologer,
    this.isBroadcasting = false,
    this.isCameraOn = true,
    this.isAudioOn = true,
  });

  factory LiveSessionModel.fromJson(Map<String, dynamic> json) {
    return LiveSessionModel(
      id: json['id'],
      astrologerId: json['astrologer_id'] ?? json['astrologer']?['id'],
      title: json['title'] ?? '',
      description: json['description'],
      sessionType: json['session_type'] ?? 'public',
      status: json['status'],
      streamUrl: json['stream_url'],
      viewerCount: json['viewer_count'] ?? 0,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      astrologer: json['astrologer'] != null ? LiveAstrologerModel.fromJson(json['astrologer']) : null,
      isBroadcasting: json['is_broadcasting'] ?? false,
      isCameraOn: json['is_camera_on'] ?? true,
      isAudioOn: json['is_audio_on'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'session_type': sessionType,
      'status': status,
      'stream_url': streamUrl,
      'viewer_count': viewerCount,
      'started_at': startedAt?.toIso8601String(),
      'astrologer': astrologer?.toJson(),
      'is_broadcasting': isBroadcasting,
      'is_camera_on': isCameraOn,
      'is_audio_on': isAudioOn,
    };
  }

}

class LiveAstrologerModel {
  final int id;
  final int? userId;
  final String name;
  final String? profilePhoto;
  final String? gender;
  final String? dateOfBirth;

  LiveAstrologerModel({
    required this.id,
    this.userId,
    required this.name,
    this.profilePhoto,
    this.gender,
    this.dateOfBirth,
  });

  factory LiveAstrologerModel.fromJson(Map<String, dynamic> json) {
    return LiveAstrologerModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'profile_photo': profilePhoto,
      'gender': gender,
      'date_of_birth': dateOfBirth,
    };
  }
}

class LiveCommentModel {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final DateTime createdAt;
  final bool isSystem;
  final String? giftIconUrl;

  LiveCommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    required this.createdAt,
    this.isSystem = false,
    this.giftIconUrl,
  });

  factory LiveCommentModel.fromJson(Map<String, dynamic> json) {
    return LiveCommentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'User',
      userAvatar: json['user_avatar'] ?? json['user_image'],
      message: json['message'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      isSystem: json['is_system'] ?? false,
      giftIconUrl: json['gift'] != null ? json['gift']['icon_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_system': isSystem,
    };
  }
}
