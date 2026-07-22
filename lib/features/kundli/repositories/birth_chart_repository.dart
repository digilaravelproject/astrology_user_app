import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/birth_chart_model.dart';

class BirthChartRepository {
  final AstrologyApiClient _client;

  BirthChartRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<BirthChartModel?> getBirthChart({
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

      final response = await _client.getBirthChart(payload);

      if (response.statusCode == 200) {
        return BirthChartModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching birth chart', error: e);
    }
    return null;
  }
}
