import 'package:dio/dio.dart';
import '../../domain/repositories/panchang_repository.dart';
import '../models/panchang_model.dart';

class PanchangRepositoryImpl implements PanchangRepository {
  final Dio _dio;

  PanchangRepositoryImpl() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.vedika.io/sandbox';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  @override
  Future<PanchangModel> getPanchangByDate(String date) async {
    try {
      print('[PCB_APP] [DEBUG] Repository: Fetching panchang for date: $date');
      print('[PCB_APP] [DEBUG] Repository: URL: https://api.vedika.io/sandbox/panchang/$date');
      
      final response = await _dio.get('/panchang/$date');

      print('[PCB_APP] [DEBUG] Repository: Response status: ${response.statusCode}');
      print('[PCB_APP] [DEBUG] Repository: Response data type: ${response.data.runtimeType}');
      print('[PCB_APP] [DEBUG] Repository: Response data: ${response.data}');
      
      if (response.statusCode == 200) {
        final model = PanchangModel.fromJson(response.data as Map<String, dynamic>);
        print('[PCB_APP] [DEBUG] Repository: Model created successfully');
        print('[PCB_APP] [DEBUG] Repository: Model success: ${model.success}');
        print('[PCB_APP] [DEBUG] Repository: Model location: ${model.data.location}');
        return model;
      } else {
        throw Exception('Failed to load panchang data: ${response.statusCode}');
      }
    } catch (e) {
      print('[PCB_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching panchang: $e');
    }
  }
}
