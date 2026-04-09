import '../../../../core/services/network/api_client.dart';
import '../../../../core/services/network/response_model.dart';
import '../../../../core/constants/app_urls.dart';

class GiftRepository {
  final ApiClient apiClient;

  GiftRepository({required this.apiClient});

  Future<ResponseModel> getGifts() async {
    return await apiClient.get(AppUrls.gifts);
  }

  Future<ResponseModel> sendGift(int giftId, int astrologerId, String paymentMethod) async {
    return await apiClient.post(AppUrls.sendGift, data: {
      'gift_id': giftId,
      'astrologer_id': astrologerId,
      'payment_method': paymentMethod,
    });
  }

  Future<ResponseModel> getGiftHistory(int astrologerId) async {
    return await apiClient.get(AppUrls.getGiftHistory(astrologerId));
  }
}
