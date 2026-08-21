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
  final String? razorpayKey;

  WalletTopUpData({
    required this.wallet,
    required this.transaction,
    this.razorpayKey,
  });

  factory WalletTopUpData.fromJson(Map<String, dynamic> json) {
    // If the response is flat (e.g. {"order_id": "...", "amount": 10000}), fallback to root json
    final transactionJson = json['transaction'] ?? json;
    return WalletTopUpData(
      wallet: WalletModel.fromJson(json['wallet'] ?? {}),
      transaction: TransactionModel.fromJson(transactionJson),
      razorpayKey: json['razorpay_order']?['key_id'],
    );
  }
}

class TransactionModel {
  final int id;
  final int walletId;
  final String transactionType;
  final String amount;
  final String baseAmount;
  final String gstPercent;
  final String gstAmount;
  final String totalAmount;
  final String invoiceNumber;
  final String status;
  final String paymentProvider;
  final String providerOrderId;
  final String providerPaymentId;
  final String description;
  final String updatedAt;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.baseAmount,
    required this.gstPercent,
    required this.gstAmount,
    required this.totalAmount,
    required this.invoiceNumber,
    required this.status,
    required this.paymentProvider,
    required this.providerOrderId,
    required this.providerPaymentId,
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
      baseAmount: json['base_amount']?.toString() ?? json['amount']?.toString() ?? '0.00',
      gstPercent: json['gst_percent']?.toString() ?? '18.00',
      gstAmount: json['gst_amount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? json['amount']?.toString() ?? '0.00',
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      status: json['status'] ?? '',
      paymentProvider: json['payment_provider'] ?? '',
      providerOrderId: json['provider_order_id'] ?? json['razorpay_order_id'] ?? json['order_id'] ?? '',
      providerPaymentId: json['provider_payment_id']?.toString() ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}

class WalletTransactionsResponseModel {
  final String status;
  final WalletTransactionsData data;

  WalletTransactionsResponseModel({
    required this.status,
    required this.data,
  });

  factory WalletTransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsResponseModel(
      status: json['status'] ?? '',
      data: WalletTransactionsData.fromJson(json['data'] ?? {}),
    );
  }
}

class WalletTransactionsData {
  final WalletModel wallet;
  final List<TransactionModel> transactions;

  WalletTransactionsData({
    required this.wallet,
    required this.transactions,
  });

  factory WalletTransactionsData.fromJson(Map<String, dynamic> json) {
    var list = json['transactions'] as List?;
    List<TransactionModel> transactionsList = list != null
        ? list.map((i) => TransactionModel.fromJson(i)).toList()
        : [];
    return WalletTransactionsData(
      wallet: WalletModel.fromJson(json['wallet'] ?? {}),
      transactions: transactionsList,
    );
  }
}
