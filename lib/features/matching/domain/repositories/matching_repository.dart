import '../../data/models/matching_request_model.dart';
import '../../data/models/matching_response_model.dart';

abstract class MatchingRepository {
  Future<MatchingResponseModel> getMatching(MatchingRequestModel request);
}
