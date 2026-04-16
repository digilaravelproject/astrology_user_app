import 'package:dio/dio.dart';
import '../../domain/repositories/matching_repository.dart';
import '../models/matching_request_model.dart';
import '../models/matching_response_model.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final Dio _dio;

  MatchingRepositoryImpl() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.vedika.io/sandbox';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<MatchingResponseModel> getMatching(MatchingRequestModel request) async {
    try {
      print('[MATCHING_APP] [DEBUG] Repository: Fetching matching data');
      print('[MATCHING_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await _dio.post(
        '/astrology/ashtakoota',
        data: request.toJson(),
      );

      print('[MATCHING_APP] [DEBUG] Repository: Response status: ${response.statusCode}');
      print('[MATCHING_APP] [DEBUG] Repository: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final model = MatchingResponseModel.fromJson(response.data as Map<String, dynamic>);
        print('[MATCHING_APP] [DEBUG] Repository: Model created successfully');
        print('[MATCHING_APP] [DEBUG] Repository: Compatibility: ${model.data.compatibilityScore}/${model.data.maxScore}');
        return model;
      } else {
        throw Exception('Failed to load matching data: ${response.statusCode}');
      }
    } catch (e) {
      print('[MATCHING_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching matching: $e');
    }
  }
}
