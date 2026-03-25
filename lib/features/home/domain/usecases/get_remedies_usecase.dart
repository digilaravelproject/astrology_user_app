import '../models/remedy_model.dart';
import '../services/remedy_service.dart';

class GetRemediesUseCase {
  final RemedyService _remedyService;

  GetRemediesUseCase(this._remedyService);

  Future<List<RemedyModel>> execute() async {
    final response = await _remedyService.getRemedies();

    if (response.isSuccess && response.body != null) {
      try {
        final Map<String, dynamic> bodyMap = response.body as Map<String, dynamic>;
        final List<dynamic> list = bodyMap['remedies'] ?? [];
        return list.map((e) => RemedyModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        print('Error parsing remedies: $e');
      }
    }

    return [];
  }
}
