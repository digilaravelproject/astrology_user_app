import 'package:astro_user/core/services/network/response_model.dart';
import 'package:astro_user/features/profile/data/datasources/profile_service.dart';

class SubmitFeedbackUseCase {
  final ProfileService service;

  SubmitFeedbackUseCase(this.service);

  Future<ResponseModel> execute(int rating, String comment) async {
    return await service.submitFeedback(rating, comment);
  }
}
