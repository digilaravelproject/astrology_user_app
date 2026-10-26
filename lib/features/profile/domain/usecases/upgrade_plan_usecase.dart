import 'package:astro_user/features/profile/data/datasources/plan_service.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class UpgradePlanUseCase {
  final PlanService _planService;

  UpgradePlanUseCase(this._planService);

  Future<ResponseModel> execute(int planId) async {
    return await _planService.upgradePlan(planId);
  }
}
