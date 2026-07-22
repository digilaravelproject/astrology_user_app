import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/ashtakvarga_model.dart';

class AshtakvargaRepository {
  final AstrologyApiClient _client;

  AshtakvargaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<AshtakvargaModel?> getAshtakvargaDetails({
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

      final response = await _client.getAshtakavarga(payload);

      if (response.statusCode == 200) {
        return AshtakvargaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching ashtakvarga details', error: e);
    }
    return null;
  }
}
