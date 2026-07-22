import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/remedies_model.dart';

class RemediesRepository {
  final AstrologyApiClient _client;

  RemediesRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<RemediesModel?> getGemstoneRemedies({
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

      final response = await _client.getGemstoneRemedies(payload);

      if (response.statusCode == 200) {
        return RemediesModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching gemstone remedies', error: e);
    }
    return null;
  }
}
