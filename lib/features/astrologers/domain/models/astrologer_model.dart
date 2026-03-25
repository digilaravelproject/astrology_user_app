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
      chatRate: json['chat_rate'],
      callRate: json['call_rate'],
      videoCallRate: json['video_call_rate'],
      name: userData['name'] ?? 'Unknown',
      phone: userData['phone'],
      email: userData['email'],
      isChatEnabled: json['is_chat_enabled'] == 1,
      isCallEnabled: json['is_call_enabled'] == 1,
    );
  }
}
