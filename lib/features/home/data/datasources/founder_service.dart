import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/home/domain/repositories/founder_repository.dart';

class FounderService {
  final FounderRepository repository;

  FounderService(this.repository);

  Future<ResponseModel> getFounderWords() async {
    return await repository.getFounderWords();
  }
}
