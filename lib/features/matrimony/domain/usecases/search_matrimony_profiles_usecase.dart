import '../../../../core/services/network/response_model.dart';
import '../services/matrimony_service.dart';

class SearchMatrimonyProfilesUseCase {
  final MatrimonyServiceInterface _service;

  SearchMatrimonyProfilesUseCase(this._service);

  Future<ResponseModel> execute(String query) async {
    return await _service.searchMatrimonyProfiles(query);
  }
}
