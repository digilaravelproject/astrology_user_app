import 'package:astro_user/features/wallet/data/datasources/wallet_service.dart';
import 'package:astro_user/features/wallet/data/models/wallet_model.dart';

class GetWalletUseCase {
  final WalletServiceInterface service;

  GetWalletUseCase({required this.service});

  Future<WalletModel?> execute() {
    return service.getWallet();
  }
}
