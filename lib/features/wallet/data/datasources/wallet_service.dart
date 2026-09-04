import 'package:astro_user/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:astro_user/features/wallet/data/models/wallet_model.dart';
import 'package:astro_user/features/wallet/data/models/wallet_top_up_response_model.dart';

abstract class WalletServiceInterface {
  Future<WalletModel?> getWallet();
  Future<WalletTopUpResponseModel?> topUpWallet(double amount);
  Future<WalletTopUpResponseModel?> verifyTopUp({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  });
  Future<WalletTransactionsResponseModel?> getTransactions();
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

  @override
  Future<WalletTransactionsResponseModel?> getTransactions() {
    return repository.getTransactions();
  }
}
