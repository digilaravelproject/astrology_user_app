import '../../../../core/services/network/response_model.dart';
import '../repositories/founder_repository.dart';

class FounderService {
  final FounderRepository repository;

  FounderService(this.repository);

  Future<ResponseModel> getFounderWords() async {
    return await repository.getFounderWords();
  }
}
