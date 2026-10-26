import 'package:get/get.dart';
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String? type;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    this.type,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? json['description'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      type: json['type']?.toString(),
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'is_read': isRead ? 1 : 0,
      'type': type,
      'created_at': createdAt,
    };
  }
}
