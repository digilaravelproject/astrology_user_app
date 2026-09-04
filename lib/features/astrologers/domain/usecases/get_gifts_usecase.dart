import 'package:astro_user/features/astrologers/data/models/gift_model.dart';
import 'package:astro_user/features/astrologers/data/datasources/gift_service.dart';

class GetGiftsUseCase {
  final GiftService service;

  GetGiftsUseCase({required this.service});

  Future<List<GiftModel>> execute() async {
    final response = await service.getGifts();
    if (response.isSuccess && response.body != null) {
      final List<dynamic> gifts = response.body['gifts'] ?? [];
      return gifts.map((json) => GiftModel.fromJson(json)).toList();
    }
    return [];
  }
}
