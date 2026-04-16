import '../../data/models/kundli_request_model.dart';
import '../../data/models/kundli_response_model.dart';

abstract class KundliRepository {
  Future<KundliResponseModel> getBirthChart(KundliRequestModel request);
}
