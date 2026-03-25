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
}

class WalletRepository implements WalletRepositoryInterface {
  final ApiClient apiClient;

  WalletRepository({required this.apiClient});

  @override
  Future<WalletModel?> getWallet() async {
    try {
      final response = await apiClient.get(AppUrls.wallet);
      if (response.statusCode == 200 && response.body['status'] == 'success') {
        return WalletModel.fromJson(response.body['data']['wallet']);
      }
    } catch (e) {
      print('Error getting wallet: $e');
    }
    return null;
  }

  @override
  Future<WalletTopUpResponseModel?> topUpWallet(double amount) async {
    try {
      final response = await apiClient.post(AppUrls.walletTopup, data: {
        'amount': amount,
      });
      print('[PCB_APP] [DEBUG] | topUpWallet Status: ${response.statusCode}');
      print('[PCB_APP] [DEBUG] | topUpWallet Body: ${response.body}');
      
      final isSuccess = (response.statusCode == 200 || response.statusCode == 201) && 
                       (response.body != null);
      
      print('[PCB_APP] [DEBUG] | topUpWallet isSuccess: $isSuccess');

      if (isSuccess) {
        return WalletTopUpResponseModel.fromJson(response.body);
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
        'provider_order_id': providerOrderId,
        'provider_payment_id': providerPaymentId,
        'signature': signature,
      });
      print('[PCB_APP] [DEBUG] | verifyTopUp Status: ${response.statusCode}');
      
      final isSuccess = (response.statusCode == 200 || response.statusCode == 201) && 
                       (response.body != null && response.body['status'] == 'success');

      if (isSuccess) {
        return WalletTopUpResponseModel.fromJson(response.body);
      }
    } catch (e) {
      print('[PCB_APP] [DEBUG] | Error verifying top-up: $e');
    }
    return null;
  }
}





