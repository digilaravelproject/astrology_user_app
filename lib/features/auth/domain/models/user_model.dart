import 'dart:convert';

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
  final bool? profileCompleted;
  final String? profilePhoto;
  final List<String>? languages;

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
}




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
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'].toString()) : DateTime.now(),
    );
  }
}
