import 'wallet_model.dart';

class WalletTopUpResponseModel {
  final String status;
  final String message;
  final WalletTopUpData data;

  WalletTopUpResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WalletTopUpResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return WalletTopUpResponseModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: WalletTopUpData.fromJson(json['data'] ?? {}),
      );
    } catch (e, stackTrace) {
      print('[PCB_APP] [DEBUG] | Error parsing WalletTopUpResponseModel: $e');
      print('[PCB_APP] [DEBUG] | StackTrace: $stackTrace');
      rethrow;
    }
  }
}

class WalletTopUpData {
  final WalletModel wallet;
  final TransactionModel transaction;

  WalletTopUpData({
    required this.wallet,
    required this.transaction,
  });

  factory WalletTopUpData.fromJson(Map<String, dynamic> json) {
    return WalletTopUpData(
      wallet: WalletModel.fromJson(json['wallet'] ?? {}),
      transaction: TransactionModel.fromJson(json['transaction'] ?? {}),
    );
  }
}

class TransactionModel {
  final int id;
  final int walletId;
  final String transactionType;
  final String amount;
  final String status;
  final String paymentProvider;
  final String providerOrderId;
  final String description;
  final String updatedAt;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.paymentProvider,
    required this.providerOrderId,
    required this.description,
    required this.updatedAt,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      transactionType: json['transaction_type'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status'] ?? '',
      paymentProvider: json['payment_provider'] ?? '',
      providerOrderId: json['provider_order_id'] ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
