import '../../data/models/kundli_request_model.dart';
import '../../data/models/kundli_response_model.dart';
import '../repositories/kundli_repository.dart';

class GetBirthChartUseCase {
  final KundliRepository repository;

  GetBirthChartUseCase({required this.repository});

  Future<KundliResponseModel> call(KundliRequestModel request) async {
    return await repository.getBirthChart(request);
  }
}
