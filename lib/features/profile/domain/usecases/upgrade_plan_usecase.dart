import '../services/plan_service.dart';
import '../../../../core/services/network/response_model.dart';

class UpgradePlanUseCase {
  final PlanService _planService;

  UpgradePlanUseCase(this._planService);

  Future<ResponseModel> execute(int planId) async {
    return await _planService.upgradePlan(planId);
  }
}
