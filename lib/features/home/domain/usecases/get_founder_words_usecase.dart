import '../../../../core/services/network/response_model.dart';
import '../models/founder_model.dart';
import '../services/founder_service.dart';

class GetFounderWordsUseCase {
  final FounderService _service;

  GetFounderWordsUseCase(this._service);

  Future<List<FounderModel>> execute() async {
    try {
      final response = await _service.getFounderWords();
      if (response.isSuccess && response.body != null) {
        final dynamic body = response.body;
        final List<dynamic> data =
            body is Map ? (body['founders_words'] ?? []) : [];
        return data
            .where((json) => json != null && json is Map<String, dynamic>)
            .map((json) => FounderModel.fromJson(json as Map<String, dynamic>))
            .where((e) => e.isActive)
            .toList();
      }
    } catch (e) {
      print('[GetFounderWordsUseCase] Error: $e');
    }
    return [];
  }
}
