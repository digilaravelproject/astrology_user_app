import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../../matrimony/controllers/matrimony_controller.dart';
import '../../matrimony/domain/repositories/matrimony_repository.dart';
import '../../matrimony/domain/services/matrimony_service.dart';
import '../../matrimony/domain/usecases/save_matrimony_profile_usecase.dart';
import '../../home/domain/repositories/remedy_repository.dart';
import '../../home/domain/services/remedy_service.dart';
import '../../home/domain/usecases/get_remedies_usecase.dart';
import '../../home/domain/usecases/get_remedy_by_id_usecase.dart';
import '../../home/domain/repositories/blog_repository.dart';
import '../../home/domain/services/blog_service.dart';
import '../../home/domain/usecases/get_blogs_usecase.dart';
import '../../home/domain/usecases/get_blog_by_id_usecase.dart';
import '../../home/controllers/remedy_controller.dart';
import '../../home/controllers/blog_controller.dart';
import '../../astrologers/domain/repositories/astrologer_repository.dart';
import '../../astrologers/domain/services/astrologer_service.dart';
import '../../astrologers/domain/usecases/get_astrologers_usecase.dart';
import '../../astrologers/domain/usecases/get_astrologer_by_id_usecase.dart';
import '../../astrologers/domain/usecases/block_astrologer_usecase.dart';
import '../../astrologers/domain/usecases/report_astrologer_usecase.dart';
import '../../astrologers/domain/usecases/post_review_usecase.dart';
import '../../astrologers/domain/usecases/get_reviews_usecase.dart';
import '../../astrologers/domain/usecases/follow_astrologer_usecase.dart';
import '../../astrologers/controllers/astrologer_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Matrimony
    Get.lazyPut<MatrimonyRepositoryInterface>(() => MatrimonyRepository(apiClient: Get.find()));
    Get.lazyPut<MatrimonyServiceInterface>(() => MatrimonyService(repository: Get.find()));
    Get.lazyPut(() => SaveMatrimonyProfileUseCase(service: Get.find()));
    Get.lazyPut(() => MatrimonyController(saveMatrimonyProfileUseCase: Get.find()));

    // Home (Remedy & Blog)
    Get.lazyPut(() => RemedyRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => RemedyService(Get.find<RemedyRepository>()));
    Get.lazyPut(() => GetRemediesUseCase(Get.find<RemedyService>()));
    Get.lazyPut(() => GetRemedyByIdUseCase(Get.find<RemedyService>()));
    Get.lazyPut(() => RemedyController(
      getRemediesUseCase: Get.find<GetRemediesUseCase>(),
      getRemedyByIdUseCase: Get.find<GetRemedyByIdUseCase>(),
    ));

    Get.lazyPut(() => BlogRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => BlogService(Get.find<BlogRepository>()));
    Get.lazyPut(() => GetBlogsUseCase(Get.find<BlogService>()));
    Get.lazyPut(() => GetBlogByIdUseCase(Get.find<BlogService>()));
    Get.lazyPut(() => BlogController(
      getBlogsUseCase: Get.find<GetBlogsUseCase>(),
      getBlogByIdUseCase: Get.find<GetBlogByIdUseCase>(),
    ));

    // Astrologers
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
