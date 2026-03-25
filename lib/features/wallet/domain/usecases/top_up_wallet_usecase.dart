import '../models/wallet_top_up_response_model.dart';
import '../services/wallet_service.dart';

class TopUpWalletUseCase {
  final WalletServiceInterface service;

  TopUpWalletUseCase({required this.service});

  Future<WalletTopUpResponseModel?> execute(double amount) async {
    return await service.topUpWallet(amount);
  }
}
