import 'package:astro_user/core/services/network/astrology_api_client.dart';
import 'package:astro_user/core/utils/logger.dart';
import '../models/dasha_model.dart';
import '../models/yogini_dasha_model.dart';

class DashaRepository {
  final AstrologyApiClient _client;

  DashaRepository({AstrologyApiClient? client})
      : _client = client ?? AstrologyApiClient();

  Future<DashaModel?> getVimshottariDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getDashaDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }

  Future<DashaModel?> getDashaDetails({
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

      final response = await _client.getVimshottariDasha(payload);

      if (response.statusCode == 200) {
        return DashaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching Vimshottari dasha', error: e);
    }
    return null;
  }

  Future<YoginiDashaModel?> getYoginiDashaDetails({
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

      final response = await _client.getYoginiDasha(payload);

      if (response.statusCode == 200) {
        return YoginiDashaModel.fromJson(response.data);
      }
    } catch (e) {
      Logger.e('Error fetching Yogini dasha', error: e);
    }
    return null;
  }

  Future<DashaModel?> getYoginiDasha({
    required String datetime,
    required double latitude,
    required double longitude,
    required String timezone,
  }) async {
    return getDashaDetails(
      datetime: datetime,
      latitude: latitude,
      longitude: longitude,
      timezone: timezone,
    );
  }
}
