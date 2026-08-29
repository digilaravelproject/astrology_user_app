import 'dart:convert';

/*class UserModel {
  final int id;
  final String name;
  final String mobile;
  final String otp;
  final String date;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final bool? profileCompleted;
  final String? profilePhoto;
  final List<String>? languages;
  final int? planId;
  final String? planStartedAt;
  final String? planExpiresAt;
  final bool? isMatrimony;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.otp,
   // required this.status,
    required this.date,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    this.profileCompleted,
    this.profilePhoto,
    this.languages,
    this.planId,
    this.planStartedAt,
    this.planExpiresAt,
    this.isMatrimony,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name'] ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      otp: json['otp'] ?? '',
     // status: json['status'] ?? '',
      date: json['date'] ?? '',
      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      timeOfBirth: json['time_of_birth']?.toString(),
      placeOfBirth: json['place_of_birth']?.toString(),
      profilePhoto: json['profile_photo']?.toString(),
      profileCompleted: json['profile_completed'] == true || json['profile_completed'] == 1 || json['profile_completed'] == '1',
      languages: json['languages'] != null && json['languages'] is List 
          ? List<String>.from(json['languages'].map((x) => x.toString())) 
          : null,
      planId: json['plan_id'] != null ? int.parse(json['plan_id'].toString()) : null,
      planStartedAt: json['plan_started_at']?.toString(),
      planExpiresAt: json['plan_expires_at']?.toString(),
      isMatrimony: (() {
        final value = json['is_matrimony'];
        print('UserModel.fromJson: is_matrimony=$value (type: ${value?.runtimeType})');

        if (value == null) return false;

        final normalized = value.toString().toLowerCase().trim();

        return normalized == 'true' || normalized == '1';
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'otp': otp,
     // 'status': status,
      'date': date,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      'place_of_birth': placeOfBirth,
      'profile_photo': profilePhoto,
      'profile_completed': profileCompleted,
      'languages': languages,
      'plan_id': planId,
      'plan_started_at': planStartedAt,
      'plan_expires_at': planExpiresAt,
      'is_matrimony': isMatrimony,
    };
  }
  // Added this method to convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Added this static method to create from JSON string
  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}*/

class SendOtpModel {
  final String phone;
  final int userId;
  final String otp;
  final DateTime expiresAt;

  SendOtpModel({
    required this.phone,
    required this.userId,
    required this.otp,
    required this.expiresAt,
  });

  factory SendOtpModel.fromJson(Map<String, dynamic> json) {
    return SendOtpModel(
      phone: json['phone']?.toString() ?? '',
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      otp: json['otp']?.toString() ?? '',
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'].toString())
              : DateTime.now(),
    );
  }
}

bool _parseBool(dynamic value) {
  print('_parseBool: value=$value (type: ${value?.runtimeType})');
  if (value == null) return false;
  if (value is bool) return value;
  if (value == 1 || value == '1' || value == 'true') return true;
  if (value == 0 || value == '0' || value == 'false') return false;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}

class UserModel {
  final int id;
  final String name;
  final String mobile;
  final String otp;
  final String date;
  final String? gender;
  final String? dateOfBirth;
  final String? timeOfBirth;
  final String? placeOfBirth;
  final bool profileCompleted;
  final String? profilePhoto;
  final List<String>? languages;
  final int? planId;
  final String? planStartedAt;
  final String? planExpiresAt;
  final bool isMatrimony;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.otp,
    required this.date,
    this.gender,
    this.dateOfBirth,
    this.timeOfBirth,
    this.placeOfBirth,
    required this.profileCompleted,
    this.profilePhoto,
    this.languages,
    this.planId,
    this.planStartedAt,
    this.planExpiresAt,
    required this.isMatrimony,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? mobile,
    String? otp,
    String? date,
    String? gender,
    String? dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
    bool? profileCompleted,
    String? profilePhoto,
    List<String>? languages,
    int? planId,
    String? planStartedAt,
    String? planExpiresAt,
    bool? isMatrimony,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      otp: otp ?? this.otp,
      date: date ?? this.date,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      timeOfBirth: timeOfBirth ?? this.timeOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      languages: languages ?? this.languages,
      planId: planId ?? this.planId,
      planStartedAt: planStartedAt ?? this.planStartedAt,
      planExpiresAt: planExpiresAt ?? this.planExpiresAt,
      isMatrimony: isMatrimony ?? this.isMatrimony,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
      mobile: json['mobile']?.toString() ?? json['phone']?.toString() ?? '',
      otp: json['otp']?.toString() ?? '',
      date: json['date'] ?? '',

      gender: json['gender']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      timeOfBirth: json['time_of_birth']?.toString(),
      placeOfBirth: json['place_of_birth']?.toString(),
      profilePhoto: json['profile_photo']?.toString(),

      profileCompleted: _parseBool(json['profile_completed']),
      isMatrimony: _parseBool(json['isMatrimony']),

      languages:
          json['languages'] is List
              ? List<String>.from(json['languages'].map((e) => e.toString()))
              : null,

      planId: int.tryParse(json['plan_id']?.toString() ?? ''),
      planStartedAt: json['plan_started_at']?.toString(),
      planExpiresAt: json['plan_expires_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'otp': otp,
      'date': date,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'time_of_birth': timeOfBirth,
      'place_of_birth': placeOfBirth,
      'profile_photo': profilePhoto,
      'profile_completed': profileCompleted,
      'languages': languages,
      'plan_id': planId,
      'plan_started_at': planStartedAt,
      'plan_expires_at': planExpiresAt,
      'isMatrimony': isMatrimony,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static UserModel? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }
}
