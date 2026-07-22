import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/shadbala_model.dart';

class ShadbalaRepository {
  final AstrologyApiClient _client;

  ShadbalaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<ShadbalaModel?> getShadbalaDetails({
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

      final response = await _client.getShadbala(payload);

      if (response.statusCode == 200) {
        return ShadbalaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching shadbala details', error: e);
    }
    return null;
  }
}
