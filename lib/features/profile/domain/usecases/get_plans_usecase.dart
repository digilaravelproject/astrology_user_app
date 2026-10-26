import 'package:astro_user/features/profile/data/datasources/plan_service.dart';
import 'package:astro_user/core/services/network/response_model.dart';

class GetPlansUseCase {
  final PlanService _planService;

  GetPlansUseCase(this._planService);

  Future<ResponseModel> execute() async {
    return await _planService.getPlans();
  }
}
