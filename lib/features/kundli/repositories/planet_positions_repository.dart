import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/planet_positions_model.dart';

class PlanetPositionsRepository {
  final AstrologyApiClient _client;

  PlanetPositionsRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<PlanetPositionsModel?> getPlanetPositions({
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
        return PlanetPositionsModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching planet positions', error: e);
    }
    return null;
  }
}
