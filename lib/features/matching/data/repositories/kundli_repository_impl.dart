import 'package:dio/dio.dart';
import '../../domain/repositories/kundli_repository.dart';
import '../models/kundli_request_model.dart';
import '../models/kundli_response_model.dart';

class KundliRepositoryImpl implements KundliRepository {
  final Dio _dio;

  KundliRepositoryImpl() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.vedika.io/sandbox';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<KundliResponseModel> getBirthChart(KundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching birth chart');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await _dio.post(
        '/kundali/birth-chart',
        data: request.toJson(),
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response status: ${response.statusCode}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final model = KundliResponseModel.fromJson(response.data as Map<String, dynamic>);
        print('[KUNDLI_APP] [DEBUG] Repository: Model created successfully');
        return model;
      } else {
        throw Exception('Failed to load kundli data: ${response.statusCode}');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching kundli: $e');
    }
  }
}
