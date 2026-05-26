import '../../data/models/create_kundli_request_model.dart';
import '../../data/models/create_kundli_response_model.dart';
import '../repositories/kundli_repository.dart';

class UpdateKundliUseCase {
  final KundliRepository repository;

  UpdateKundliUseCase({required this.repository});

  Future<CreateKundliResponseModel> call(int id, CreateKundliRequestModel request) async {
    return await repository.updateKundli(id, request);
  }
}
