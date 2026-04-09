import '../models/gift_history_model.dart';
import '../services/gift_service.dart';

class GetGiftHistoryUseCase {
  final GiftService service;

  GetGiftHistoryUseCase({required this.service});

  Future<List<GiftHistoryItem>> execute(int astrologerId) async {
    final response = await service.getGiftHistory(astrologerId);
    if (response.isSuccess && response.body != null) {
      try {
        final body = response.body;
        // The ApiClient already unwraps the 'data' field, so body is the data map
        if (body is Map && body['gifts'] != null) {
          final List<dynamic> giftsData = body['gifts'];
          return giftsData.map((json) => GiftHistoryItem.fromJson(json)).toList();
        }
      } catch (e, stack) {
        print('Error parsing gift history: $e');
        print('Stack trace: $stack');
      }
    }
    return [];
  }
}
