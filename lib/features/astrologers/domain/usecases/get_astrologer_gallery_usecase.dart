import '../../../../core/services/network/response_model.dart';
import '../models/astrologer_gallery_model.dart';
import '../services/astrologer_service.dart';

class GetAstrologerGalleryUseCase {
  final AstrologerService service;

  GetAstrologerGalleryUseCase({required this.service});

  Future<List<AstrologerGalleryModel>> execute(int id) async {
    final ResponseModel response = await service.getAstrologerGallery(id);
    
    if (response.isSuccess) {
      if (response.body != null && response.body['gallery'] != null) {
        return (response.body['gallery'] as List)
            .map((e) => AstrologerGalleryModel.fromJson(e))
            .toList();
      }
      return [];
    } else {
      throw Exception(response.message);
    }
  }
}
