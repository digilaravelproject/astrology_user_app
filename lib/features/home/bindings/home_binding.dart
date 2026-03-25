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

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RemedyRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(RemedyService(Get.find<RemedyRepository>()), permanent: true);
    Get.put(GetRemediesUseCase(Get.find<RemedyService>()), permanent: true);
    Get.put(GetRemedyByIdUseCase(Get.find<RemedyService>()), permanent: true);
    Get.put(
      RemedyController(
        getRemediesUseCase: Get.find<GetRemediesUseCase>(),
        getRemedyByIdUseCase: Get.find<GetRemedyByIdUseCase>(),
      ),
      permanent: true,
    );

    // Blogs
    Get.put(BlogRepository(Get.find<ApiClient>()), permanent: true);
    Get.put(BlogService(Get.find<BlogRepository>()), permanent: true);
    Get.put(GetBlogsUseCase(Get.find<BlogService>()), permanent: true);
    Get.put(GetBlogByIdUseCase(Get.find<BlogService>()), permanent: true);
    Get.put(
      BlogController(
        getBlogsUseCase: Get.find<GetBlogsUseCase>(),
        getBlogByIdUseCase: Get.find<GetBlogByIdUseCase>(),
      ),
      permanent: true,
    );
  }
}
