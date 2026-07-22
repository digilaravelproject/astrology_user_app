import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/divisional_chart_model.dart';

class DivisionalChartRepository {
  final AstrologyApiClient _client;

  DivisionalChartRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<DivisionalChartModel?> getDivisionalChart({
    dynamic division,
    String? chartType,
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

      final String typeStr = chartType ?? (division != null ? 'd$division' : 'd1');

      final response = await _client.getDivisionalChart(typeStr, payload);

      if (response.statusCode == 200) {
        return DivisionalChartModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching divisional chart', error: e);
    }
    return null;
  }
}
