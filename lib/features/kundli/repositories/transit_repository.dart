import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/transit_model.dart';

class TransitRepository {
  final AstrologyApiClient _client;

  TransitRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<TransitModel?> getTransit({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getTransitDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<TransitModel?> getTransitDetails({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    try {
      final payload = _client.buildBirthPayload(
        datetime: datetime,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );

      final response = await _client.getPlanetPositions(payload);

      if (response.statusCode == 200) {
        return TransitModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching transit details', error: e);
    }
    return null;
  }
}
