import 'package:astro_user/features/matching/data/models/kundli_request_model.dart';
import 'package:astro_user/features/matching/data/models/kundli_response_model.dart';
import 'package:astro_user/features/matching/domain/repositories/kundli_repository.dart';

class GetBirthChartUseCase {
  final KundliRepository repository;

  GetBirthChartUseCase({required this.repository});

  Future<KundliResponseModel> call(KundliRequestModel request) async {
    return await repository.getBirthChart(request);
  }
}
