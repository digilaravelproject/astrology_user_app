import 'package:astro_user/features/matching/data/models/create_kundli_request_model.dart';
import 'package:astro_user/features/matching/data/models/create_kundli_response_model.dart';
import 'package:astro_user/features/matching/domain/repositories/kundli_repository.dart';

class CreateKundliUseCase {
  final KundliRepository repository;

  CreateKundliUseCase({required this.repository});

  Future<CreateKundliResponseModel> call(CreateKundliRequestModel request) async {
    return await repository.createKundli(request);
  }
}
