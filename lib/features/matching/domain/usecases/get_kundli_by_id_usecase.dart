import '../../data/models/kundli_detail_response_model.dart';
import '../repositories/kundli_repository.dart';

class GetKundliByIdUseCase {
  final KundliRepository repository;

  GetKundliByIdUseCase({required this.repository});

  Future<KundliDetailResponseModel> call(int id) async {
    return await repository.getKundliById(id);
  }
}
