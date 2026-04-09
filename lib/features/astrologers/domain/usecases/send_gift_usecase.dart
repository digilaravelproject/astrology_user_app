import '../../../../core/services/network/response_model.dart';
import '../services/gift_service.dart';

class SendGiftUseCase {
  final GiftService service;

  SendGiftUseCase({required this.service});

  Future<ResponseModel> execute(int giftId, int astrologerId, {String paymentMethod = 'wallet'}) async {
    return await service.sendGift(giftId, astrologerId, paymentMethod);
  }
}
