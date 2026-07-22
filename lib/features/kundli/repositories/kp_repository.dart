import '../../../../core/services/network/astrology_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/kp_model.dart';

class KPRepository {
  final AstrologyApiClient _client;

  KPRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<KPFullReportModel?> getKPFullReport({
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

      final response = await _client.getKpPlanets(payload);

      if (response.statusCode == 200) {
        final dataMap = response.data is List ? {'planets': response.data} : response.data;
        return KPFullReportModel.fromJson(dataMap);
      }
    } catch (e) {
      Logger.e('Error fetching KP full report', error: e);
    }
    return null;
  }

  Future<KPFullReportModel?> getKpFullReport({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getKPFullReport(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}

typedef KpRepository = KPRepository;
