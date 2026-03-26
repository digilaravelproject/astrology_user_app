import '../models/wallet_top_up_response_model.dart';
import '../services/wallet_service.dart';

class GetTransactionsUseCase {
  final WalletServiceInterface service;

  GetTransactionsUseCase({required this.service});

  Future<WalletTransactionsResponseModel?> execute() async {
    return await service.getTransactions();
  }
}
