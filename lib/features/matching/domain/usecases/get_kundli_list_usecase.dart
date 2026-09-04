import 'package:astro_user/features/matching/data/models/kundli_list_response_model.dart';
import 'package:astro_user/features/matching/domain/repositories/kundli_repository.dart';

class GetKundliListUseCase {
  final KundliRepository repository;

  GetKundliListUseCase({required this.repository});

  Future<KundliListResponseModel> call({int perPage = 15}) async {
    return await repository.getKundliList(perPage: perPage);
  }
}
