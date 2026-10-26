import 'package:astro_user/features/profile/data/datasources/plan_service.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class GetPlanByIdUseCase {
  final PlanService _planService;

  GetPlanByIdUseCase(this._planService);

  Future<ResponseModel> execute(int id) async {
    return await _planService.getPlanById(id);
  }
}
