import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/data/models/astrologer_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/astrologer_service.dart';

class PaginatedAstrologersResult {
  final List<AstrologerModel> astrologers;
  final int currentPage;
  final int total;
  final int lastPage;
  final bool hasMore;

  PaginatedAstrologersResult({
    required this.astrologers,
    this.currentPage = 1,
    this.total = 0,
    this.lastPage = 1,
    this.hasMore = false,
  });
}

class GetAstrologersUseCase {
  final AstrologerService service;

  GetAstrologersUseCase({required this.service});

  Future<List<AstrologerModel>> execute({Map<String, dynamic>? params}) async {
    final result = await executeWithPagination(params: params);
    return result.astrologers;
  }

  Future<PaginatedAstrologersResult> executeWithPagination({Map<String, dynamic>? params}) async {
    try {
      final response = await service.getAstrologers(queryParameters: params);
      if (response.isSuccess && response.body != null) {
        final body = response.body;
        List<dynamic>? dataList;
        int currentPage = 1;
        int total = 0;
        int lastPage = 1;
        bool hasMore = false;

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

          final pagination = (body['data'] is Map && body['data']['pagination'] is Map)
              ? body['data']['pagination']
              : (body['pagination'] is Map ? body['pagination'] : null);

          if (pagination != null) {
            currentPage = int.tryParse(pagination['current_page']?.toString() ?? '1') ?? 1;
            total = int.tryParse(pagination['total']?.toString() ?? '0') ?? 0;
            lastPage = int.tryParse(pagination['last_page']?.toString() ?? '1') ?? 1;
            hasMore = pagination['has_more'] == true ||
                pagination['has_more']?.toString() == '1' ||
                pagination['has_more']?.toString().toLowerCase() == 'true' ||
                currentPage < lastPage;
          }
        }

        if (dataList != null) {
          final list = dataList.map((json) => AstrologerModel.fromJson(json)).toList();
          return PaginatedAstrologersResult(
            astrologers: list,
            currentPage: currentPage,
            total: total,
            lastPage: lastPage,
            hasMore: hasMore,
          );
        }
      }
    } catch (e) {
      print('Error in GetAstrologersUseCase: $e');
    }
    return PaginatedAstrologersResult(astrologers: []);
  }
}
