import '../../../../core/services/network/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/wallet_model.dart';

import '../models/wallet_top_up_response_model.dart';

abstract class WalletRepositoryInterface {
  Future<WalletModel?> getWallet();
  Future<WalletTopUpResponseModel?> topUpWallet(double amount);
  Future<WalletTopUpResponseModel?> verifyTopUp({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  });
  Future<WalletTransactionsResponseModel?> getTransactions();
}

class WalletRepository implements WalletRepositoryInterface {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  @override
  Future<WalletModel?> getWallet() async {
    try {
      final response = await apiClient.get(AppUrls.wallet);
      if (response.isSuccess && response.body != null) {
        print('[PCB_APP] [DEBUG] | getWallet body: ${response.body}');
        final wallet = WalletModel.fromJson(response.body['wallet']);
        print('[PCB_APP] [DEBUG] | Parsed Wallet: ${wallet.balance}');
        return wallet;
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error getting wallet in Repo: $e');
    }
    return null;
  }

  @override
  Future<WalletTopUpResponseModel?> topUpWallet(double amount) async {
    try {
      final response = await apiClient.post(AppUrls.walletTopup, data: {
        'amount': amount,
      }, handleError: false, showToaster: false);
      print('[PCB_APP] [DEBUG] | topUpWallet Status: ${response.statusCode}');
      print('[PCB_APP] [DEBUG] | topUpWallet isSuccess: ${response.isSuccess}');

      if (response.isSuccess && response.body != null) {
        // Since apiClient returns only the 'data' part as body
        return WalletTopUpResponseModel(
          status: 'success',
          message: response.message,
          data: WalletTopUpData.fromJson(response.body),
        );
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error topping up wallet: $e');
    }
    return null;
  }

  @override
  Future<WalletTopUpResponseModel?> verifyTopUp({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    try {
      final response = await apiClient.post(AppUrls.walletTopupVerify, data: {
        'razorpay_order_id': providerOrderId,
        'razorpay_payment_id': providerPaymentId,
        'razorpay_signature': signature,
      });
      print('[PCB_APP] [DEBUG] | verifyTopUp Status: ${response.statusCode}');
      
      if (response.isSuccess && response.body != null) {
        return WalletTopUpResponseModel(
          status: 'success',
          message: response.message,
          data: WalletTopUpData.fromJson(response.body),
        );
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error verifying top-up: $e');
    }
    return null;
  }

  @override
  Future<WalletTransactionsResponseModel?> getTransactions() async {
    try {
      final response = await apiClient.get(AppUrls.walletTransactions);
      if (response.isSuccess && response.body != null) {
        return WalletTransactionsResponseModel(
          status: 'success',
          data: WalletTransactionsData.fromJson(response.body),
        );
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error fetching transactions: $e');
    }
    return null;
  }
}





