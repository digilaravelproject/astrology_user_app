import '../../../../core/services/network/response_model.dart';
import '../repositories/plan_repository.dart';

class PlanService {
  final PlanRepository repository;

  PlanService(this.repository);

  Future<ResponseModel> getPlans() async {
    return await repository.getPlans();
  }

  Future<ResponseModel> getPlanById(int id) async {
    return await repository.getPlanById(id);
  }

  Future<ResponseModel> upgradePlan(int planId) async {
    return await repository.upgradePlan(planId);
  }

  Future<ResponseModel> verifyUpgrade({
    required String providerOrderId,
    required String providerPaymentId,
    required String signature,
  }) async {
    return await repository.verifyUpgrade(
      providerOrderId: providerOrderId,
      providerPaymentId: providerPaymentId,
      signature: signature,
    );
  }
}
