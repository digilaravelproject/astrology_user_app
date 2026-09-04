import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/matrimony/data/datasources/matrimony_service.dart';

class SearchMatrimonyProfilesUseCase {
  final MatrimonyServiceInterface _service;

  SearchMatrimonyProfilesUseCase(this._service);

  Future<ResponseModel> execute(String query) async {
    return await _service.searchMatrimonyProfiles(query);
  }
}
