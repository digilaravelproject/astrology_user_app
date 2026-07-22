import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/navamsha_model.dart';

class NavamshaRepository {
  final AstrologyApiClient _client;

  NavamshaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<NavamshaModel?> getNavamsha({
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

      final response = await _client.getDivisionalChart('d9', payload);

      if (response.statusCode == 200) {
        return NavamshaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching navamsha', error: e);
    }
    return null;
  }
}
