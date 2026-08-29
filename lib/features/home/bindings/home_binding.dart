import 'package:get/get.dart';
import '../../../core/services/network/api_client.dart';
import '../controllers/remedy_controller.dart';
import '../domain/repositories/remedy_repository.dart';
import '../domain/services/remedy_service.dart';
import '../domain/usecases/get_remedies_usecase.dart';
import '../domain/usecases/get_remedy_by_id_usecase.dart';
import '../domain/repositories/blog_repository.dart';
import '../domain/services/blog_service.dart';
import '../domain/usecases/get_blogs_usecase.dart';
import '../domain/usecases/get_blog_by_id_usecase.dart';
import '../controllers/blog_controller.dart';
import '../domain/repositories/founder_repository.dart';
import '../domain/services/founder_service.dart';
import '../domain/usecases/get_founder_words_usecase.dart';
import '../controllers/founder_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemedyRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => RemedyService(Get.find<RemedyRepository>()));
    Get.lazyPut(() => GetRemediesUseCase(Get.find<RemedyService>()));
    Get.lazyPut(() => GetRemedyByIdUseCase(Get.find<RemedyService>()));
    Get.lazyPut(
      () => RemedyController(
        getRemediesUseCase: Get.find<GetRemediesUseCase>(),
        getRemedyByIdUseCase: Get.find<GetRemedyByIdUseCase>(),
      ),
    );

    Get.lazyPut(() => BlogRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => BlogService(Get.find<BlogRepository>()));
    Get.lazyPut(() => GetBlogsUseCase(Get.find<BlogService>()));
    Get.lazyPut(() => GetBlogByIdUseCase(Get.find<BlogService>()));
    Get.lazyPut(
      () => BlogController(
        getBlogsUseCase: Get.find<GetBlogsUseCase>(),
        getBlogByIdUseCase: Get.find<GetBlogByIdUseCase>(),
      ),
    );

    // Founder words
    Get.lazyPut(() => FounderRepository(Get.find<ApiClient>()));
    Get.lazyPut(() => FounderService(Get.find<FounderRepository>()));
    Get.lazyPut(() => GetFounderWordsUseCase(Get.find<FounderService>()));
    Get.lazyPut(
      () => FounderController(
        getFounderWordsUseCase: Get.find<GetFounderWordsUseCase>(),
      ),
    );
  }
}
