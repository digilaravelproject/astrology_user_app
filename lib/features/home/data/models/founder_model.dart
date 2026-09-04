import 'package:astro_user/core/constants/app_urls.dart';

class FounderModel {
  final int id;
  final String title;
  final String message;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? image;

  FounderModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.image,
  });

  bool get hasImage {
    if (image == null || image!.isEmpty || image == "null") return false;
    // Check if the URL is just a directory path or suspicious placeholder
    if (image!.endsWith('/') || image!.endsWith('/storage') || image!.endsWith('/founder_words')) return false;
    if (image!.contains('/null')) return false;
    return true;
  }

  factory FounderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FounderModel(
        id: 0,
        title: '',
        message: '',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    // Construct the full image URL using baseImageUrl and image_path for better reliability
    String? fullImageUrl;
    if (json['image_path'] != null && json['image_path'].toString().isNotEmpty && json['image_path'].toString() != "null") {
      final path = json['image_path'].toString();
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;
      fullImageUrl = '${AppUrls.baseImageUrl}$cleanPath';
    } else {
      // Fallback to 'image' field if 'image_path' is missing
      fullImageUrl = (json['image'] == null || 
              json['image'].toString() == "null" || 
              json['image'].toString().isEmpty || 
              json['image'].toString().endsWith('/null')) 
          ? null 
          : json['image'].toString();
    }

    return FounderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      image: fullImageUrl, 
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'is_active': isActive,
      'image': image,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
