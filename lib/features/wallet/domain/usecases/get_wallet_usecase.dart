import '../services/wallet_service.dart';
import '../models/wallet_model.dart';

class GetWalletUseCase {
  final WalletServiceInterface service;

  GetWalletUseCase({required this.service});

  Future<WalletModel?> execute() {
    return service.getWallet();
  }
}
