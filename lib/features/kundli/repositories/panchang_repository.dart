import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/panchang_model.dart';

class PanchangRepository {
  final AstrologyApiClient _client;

  PanchangRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<PanchangModel?> getPanchangDetails({
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

      final response = await _client.getPanchang(payload);

      if (response.statusCode == 200) {
        return PanchangModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching panchang details', error: e);
    }
    return null;
  }
}
