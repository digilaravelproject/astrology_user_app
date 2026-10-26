import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/home/domain/repositories/remedy_repository.dart';

class RemedyService {
  final RemedyRepository repository;

  RemedyService(this.repository);

  Future<ResponseModel> getRemedies() async {
    return await repository.getRemedies();
  }

  Future<ResponseModel> getRemedyById(int id) async {
    return await repository.getRemedyById(id);
  }
}
