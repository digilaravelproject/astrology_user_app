import '../models/wallet_top_up_response_model.dart';
import '../services/wallet_service.dart';

class VerifyTopUpUseCase {
  final WalletServiceInterface service;

  VerifyTopUpUseCase({required this.service});

  Future<WalletTopUpResponseModel?> execute({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    return await service.verifyTopUp(
      providerOrderId: providerOrderId,
      providerPaymentId: providerPaymentId,
      signature: signature,
    );
  }
}
