import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/support/data/models/faq_model.dart';
import 'package:astro_user/features/support/domain/repositories/support_repository.dart';

class GetTermsAndConditionsUseCase {
  final SupportRepository repository;

  GetTermsAndConditionsUseCase({required this.repository});

  Future<FAQModel?> execute() async {
    final response = await repository.getTermsAndConditions();
    if (response.isSuccess && response.body != null) {
      return FAQModel.fromJson(response.body);
    }
    return null;
  }
}
