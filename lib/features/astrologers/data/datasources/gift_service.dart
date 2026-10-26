import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/astrologers/domain/repositories/gift_repository.dart';

class GiftService {
  final GiftRepository repository;

  GiftService({required this.repository});

  Future<ResponseModel> getGifts() async {
    return await repository.getGifts();
  }

  Future<ResponseModel> sendGift(int giftId, int astrologerId, String paymentMethod) async {
    return await repository.sendGift(giftId, astrologerId, paymentMethod);
  }

  Future<ResponseModel> getGiftHistory(int astrologerId) async {
    return await repository.getGiftHistory(astrologerId);
  }
}
