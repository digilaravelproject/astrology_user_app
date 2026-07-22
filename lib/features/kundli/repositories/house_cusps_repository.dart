import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/house_cusps_model.dart';

class HouseCuspsRepository {
  final AstrologyApiClient _client;

  HouseCuspsRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<HouseCuspsModel?> getHouseCusps({
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

      final response = await _client.getKpHouseCusps(payload);

      if (response.statusCode == 200) {
        return HouseCuspsModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching house cusps', error: e);
    }
    return null;
  }
}
