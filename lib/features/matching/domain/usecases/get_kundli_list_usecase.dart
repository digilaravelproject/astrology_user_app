import '../../data/models/kundli_list_response_model.dart';
import '../repositories/kundli_repository.dart';

class GetKundliListUseCase {
  final KundliRepository repository;

  GetKundliListUseCase({required this.repository});

  Future<KundliListResponseModel> call({int perPage = 15}) async {
    return await repository.getKundliList(perPage: perPage);
  }
}
