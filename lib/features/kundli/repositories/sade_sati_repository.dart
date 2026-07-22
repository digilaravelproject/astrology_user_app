import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/sade_sati_model.dart';

class SadeSatiRepository {
  final AstrologyApiClient _client;

  SadeSatiRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<SadeSatiModel?> getSadeSati({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getSadeSatiDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<SadeSatiModel?> getSadeSatiDetails({
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

      final response = await _client.getSadhesatiStatus(payload);

      if (response.statusCode == 200) {
        return SadeSatiModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching Sade Sati details', error: e);
    }
    return null;
  }
}
