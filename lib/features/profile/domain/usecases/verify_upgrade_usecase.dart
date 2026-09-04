import 'package:astro_user/features/profile/data/datasources/plan_service.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class VerifyUpgradeUseCase {
  final PlanService _planService;

  VerifyUpgradeUseCase(this._planService);

  Future<ResponseModel> execute({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    return await _planService.verifyUpgrade(
      providerOrderId: providerOrderId,
      providerPaymentId: providerPaymentId,
      signature: signature,
    );
  }
}
