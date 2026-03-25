class WalletModel {
  final int userId;
  final String balance;
  final String updatedAt;
  final String createdAt;
  final int id;

  WalletModel({
    required this.userId,
    required this.balance,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['user_id'] ?? 0,
      balance: json['balance']?.toString() ?? '0.00',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }
}
