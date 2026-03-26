import '../services/plan_service.dart';
import '../../../../core/services/network/response_model.dart';

class GetPlanByIdUseCase {
  final PlanService _planService;

  GetPlanByIdUseCase(this._planService);

  Future<ResponseModel> execute(int id) async {
    return await _planService.getPlanById(id);
  }
}
