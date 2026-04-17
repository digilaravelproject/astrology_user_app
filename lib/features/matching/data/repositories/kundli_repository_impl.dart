import 'package:astro_user/core/constants/app_urls.dart';

import '../../../../core/services/network/api_client.dart';
import '../../domain/repositories/kundli_repository.dart';
import '../models/kundli_request_model.dart';
import '../models/kundli_response_model.dart';
import '../models/create_kundli_request_model.dart';
import '../models/create_kundli_response_model.dart';
import '../models/kundli_list_response_model.dart';
import '../models/kundli_detail_response_model.dart';
import 'package:dio/dio.dart';

class KundliRepositoryImpl implements KundliRepository {
  final ApiClient apiClient;
  final Dio _vedikaApiDio;

  KundliRepositoryImpl({required this.apiClient}) : _vedikaApiDio = Dio() {
    // Vedika API configuration (for birth chart only)
    _vedikaApiDio.options.baseUrl = 'https://api.vedika.io/sandbox';
    _vedikaApiDio.options.connectTimeout = const Duration(seconds: 30);
    _vedikaApiDio.options.receiveTimeout = const Duration(seconds: 30);
    _vedikaApiDio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<KundliResponseModel> getBirthChart(KundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching birth chart');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await _vedikaApiDio.post(
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

  @override
  Future<CreateKundliResponseModel> createKundli(CreateKundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Creating kundli');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await apiClient.post(
        AppUrls.createKundali,
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (response.isSuccess) {
        final model = CreateKundliResponseModel.fromJson(response.body as Map<String, dynamic>);
        print('[KUNDLI_APP] [DEBUG] Repository: Kundli created successfully');
        return model;
      } else {
        throw Exception(response.message ?? 'Failed to create kundli');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error creating kundli: $e');
    }
  }

  @override
  Future<KundliListResponseModel> getKundliList({int perPage = 15}) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching kundli list');
      
      final response = await apiClient.get(
        '${AppUrls.getKundali}?per_page=$perPage',
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response isSuccess: ${response.isSuccess}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body type: ${response.body.runtimeType}');
      
      if (response.isSuccess && response.body != null) {
        try {
          // The response.body is already the pagination object (not wrapped in status/message)
          final model = KundliListResponseModel.fromJson(response.body as Map<String, dynamic>);
          print('[KUNDLI_APP] [DEBUG] Repository: Kundli list fetched successfully, count: ${model.data.length}');
          return model;
        } catch (e) {
          print('[KUNDLI_APP] [ERROR] Repository: JSON parsing error: $e');
          rethrow;
        }
      } else {
        throw Exception(response.message ?? 'Failed to fetch kundli list');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error fetching kundli list: $e');
    }
  }

  @override
  Future<KundliDetailResponseModel> getKundliById(int id) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Fetching kundli by id: $id');
      
      final response = await apiClient.get(
       // '/api/v1/kundli/$id',
        AppUrls.getKundaliById(id),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response isSuccess: ${response.isSuccess}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response message: ${response.message}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body: ${response.body}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response body type: ${response.body.runtimeType}');
      print('[KUNDLI_APP] [DEBUG] Repository: Response statusCode: ${response.statusCode}');
      
      if (response.isSuccess) {
        if (response.body != null) {
          final model = KundliDetailResponseModel.fromJson(response.body as Map<String, dynamic>);
          print('[KUNDLI_APP] [DEBUG] Repository: Kundli fetched successfully: ${model.data.name}');
          return model;
        } else {
          print('[KUNDLI_APP] [ERROR] Repository: Response body is null but isSuccess is true');
          throw Exception('Response body is null');
        }
      } else {
        throw Exception(response.message ?? 'Failed to fetch kundli');
      }
    } catch (e, stackTrace) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      print('[KUNDLI_APP] [ERROR] Stack trace: $stackTrace');
      throw Exception('Error fetching kundli: $e');
    }
  }

  @override
  Future<CreateKundliResponseModel> updateKundli(int id, CreateKundliRequestModel request) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Updating kundli id: $id');
      print('[KUNDLI_APP] [DEBUG] Repository: Request data: ${request.toJson()}');
      
      final response = await apiClient.put(
        //'/api/v1/kundli/$id',
        AppUrls.updateKundali(id),
        data: request.toJson(),
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (response.isSuccess) {
        final model = CreateKundliResponseModel.fromJson(response.body as Map<String, dynamic>);
        print('[KUNDLI_APP] [DEBUG] Repository: Kundli updated successfully');
        return model;
      } else {
        throw Exception(response.message ?? 'Failed to update kundli');
      }
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error updating kundli: $e');
    }
  }

  @override
  Future<void> deleteKundli(int id) async {
    try {
      print('[KUNDLI_APP] [DEBUG] Repository: Deleting kundli id: $id');
      
      final response = await apiClient.delete(
        AppUrls.deleteKundali(id),
       // '/api/v1/kundli/$id',
        handleError: false,
        showToaster: false,
      );

      print('[KUNDLI_APP] [DEBUG] Repository: Response: ${response.body}');
      
      if (!response.isSuccess) {
        throw Exception(response.message ?? 'Failed to delete kundli');
      }
      
      print('[KUNDLI_APP] [DEBUG] Repository: Kundli deleted successfully');
    } catch (e) {
      print('[KUNDLI_APP] [ERROR] Repository error: $e');
      throw Exception('Error deleting kundli: $e');
    }
  }
}