import '../repositories/wallet_repository.dart';
import '../models/wallet_model.dart';
import '../models/wallet_top_up_response_model.dart';

abstract class WalletServiceInterface {
  Future<WalletModel?> getWallet();
  Future<WalletTopUpResponseModel?> topUpWallet(double amount);
  Future<WalletTopUpResponseModel?> verifyTopUp({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  });
}

class WalletService implements WalletServiceInterface {
  final WalletRepositoryInterface repository;

  WalletService({required this.repository});

  @override
  Future<WalletModel?> getWallet() {
    return repository.getWallet();
  }

  @override
  Future<WalletTopUpResponseModel?> topUpWallet(double amount) {
    return repository.topUpWallet(amount);
  }

  @override
  Future<WalletTopUpResponseModel?> verifyTopUp({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) {
    return repository.verifyTopUp(
      providerOrderId: providerOrderId,
      providerPaymentId: providerPaymentId,
      signature: signature,
    );
  }
}
