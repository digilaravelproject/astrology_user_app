class GiftHistoryModel {
  final int astrologerId;
  final String astrologerName;
  final List<GiftHistoryItem> gifts;

  GiftHistoryModel({
    required this.astrologerId,
    required this.astrologerName,
    required this.gifts,
  });

  factory GiftHistoryModel.fromJson(Map<String, dynamic> json) {
    return GiftHistoryModel(
      astrologerId: json['astrologer_id'] ?? 0,
      astrologerName: (json['astrologer_name']?.toString() ?? '').split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' '),
      gifts: (json['gifts'] as List? ?? [])
          .map((i) => GiftHistoryItem.fromJson(i))
          .toList(),
    );
  }
}

class GiftHistoryItem {
  final int id;
  final int userId;
  final int astrologerId;
  final int giftId;
  final String amount;
  final String status;
  final DateTime createdAt;
  final GiftDetails? gift;
  final String? senderName;

  GiftHistoryItem({
    required this.id,
    required this.userId,
    required this.astrologerId,
    required this.giftId,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.gift,
    this.senderName,
  });

  factory GiftHistoryItem.fromJson(Map<String, dynamic> json) {
    return GiftHistoryItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      astrologerId: json['astrologer_id'] ?? 0,
      giftId: json['gift_id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      gift: json['gift'] != null ? GiftDetails.fromJson(json['gift']) : null,
      senderName: json['meta'] != null ? json['meta']['sender_name'] : null,
    );
  }
}

class GiftDetails {
  final int id;
  final String title;
  final String iconUrl;
  final String price;

  GiftDetails({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.price,
  });

  factory GiftDetails.fromJson(Map<String, dynamic> json) {
    return GiftDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      price: json['price']?.toString() ?? '0.00',
    );
  }
}
