import '../../../../core/services/network/response_model.dart';
import '../repositories/astrologer_repository.dart';

class AstrologerService {
  final AstrologerRepository repository;

  AstrologerService({required this.repository});

  Future<ResponseModel> getAstrologers() async {
    return await repository.getAstrologers();
  }
}
