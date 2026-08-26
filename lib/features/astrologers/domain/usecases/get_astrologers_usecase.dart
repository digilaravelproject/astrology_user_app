import '../../../../core/services/network/response_model.dart';
import '../models/astrologer_model.dart';
import '../services/astrologer_service.dart';

class GetAstrologersUseCase {
  final AstrologerService service;

  GetAstrologersUseCase({required this.service});

  Future<List<AstrologerModel>> execute({Map<String, dynamic>? params}) async {
    try {
      final response = await service.getAstrologers(queryParameters: params);
      if (response.isSuccess && response.body != null) {
        final body = response.body;
        List<dynamic>? dataList;

        if (body is List) {
          dataList = body;
        } else if (body is Map) {
          if (body['astrologers'] is List) {
            dataList = body['astrologers'];
          } else if (body['data'] is List) {
            dataList = body['data'];
          } else if (body['data'] is Map && body['data']['astrologers'] is List) {
            dataList = body['data']['astrologers'];
          } else if (body['data'] is Map && body['data']['data'] is List) {
            dataList = body['data']['data'];
          } else if (body['list'] is List) {
            dataList = body['list'];
          }
        }

        if (dataList != null) {
          return dataList.map((json) => AstrologerModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error in GetAstrologersUseCase: $e');
    }
    return [];
  }
}
