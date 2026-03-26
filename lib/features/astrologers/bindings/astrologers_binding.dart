import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../domain/repositories/astrologer_repository.dart';
import '../domain/services/astrologer_service.dart';
import '../domain/usecases/get_astrologers_usecase.dart';
import '../domain/usecases/get_astrologer_by_id_usecase.dart';
import '../domain/usecases/block_astrologer_usecase.dart';
import '../domain/usecases/report_astrologer_usecase.dart';
import '../domain/usecases/post_review_usecase.dart';
import '../domain/usecases/get_reviews_usecase.dart';
import '../domain/usecases/follow_astrologer_usecase.dart';
import '../controllers/astrologer_controller.dart';

class AstrologersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AstrologerRepository(apiClient: Get.find()));
    Get.lazyPut(() => AstrologerService(repository: Get.find()));
    Get.lazyPut(() => GetAstrologersUseCase(service: Get.find()));
    Get.lazyPut(() => GetAstrologerByIdUseCase(service: Get.find()));
    Get.lazyPut(() => BlockAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => ReportAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => PostReviewUseCase(service: Get.find()));
    Get.lazyPut(() => GetReviewsUseCase(service: Get.find()));
    Get.lazyPut(() => FollowAstrologerUseCase(service: Get.find()));
    Get.lazyPut(() => AstrologerController(
      getAstrologersUseCase: Get.find(),
      getAstrologerByIdUseCase: Get.find(),
      blockAstrologerUseCase: Get.find(),
      reportAstrologerUseCase: Get.find(),
      postReviewUseCase: Get.find(),
      getReviewsUseCase: Get.find(),
      followAstrologerUseCase: Get.find(),
    ));
  }
}
