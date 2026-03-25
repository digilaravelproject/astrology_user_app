import '../models/remedy_model.dart';
import '../services/remedy_service.dart';

class GetRemedyByIdUseCase {
  final RemedyService _remedyService;

  GetRemedyByIdUseCase(this._remedyService);

  Future<RemedyModel?> execute(int id) async {
    final response = await _remedyService.getRemedyById(id);

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        final Map<String, dynamic> remedyJson = bodyMap['remedy'] as Map<String, dynamic>;
        return RemedyModel.fromJson(remedyJson);
      } catch (e) {
        print('Error parsing remedy detail: $e');
      }
    }

    return null;
  }
}
