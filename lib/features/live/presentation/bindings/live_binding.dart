import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../../data/datasources/live_remote_data_source.dart';
import '../../data/repositories/live_repository_impl.dart';
import '../../domain/repositories/live_repository.dart';
import '../../domain/usecases/live_usecases.dart';
import '../controllers/live_controller.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<LiveRemoteDataSource>(
      () => LiveRemoteDataSource(Get.find<ApiClient>()),
    );

    // Repository
    Get.lazyPut<LiveRepository>(
      () => LiveRepositoryImpl(Get.find<LiveRemoteDataSource>()),
    );

    // Use Cases
    Get.lazyPut<GetActiveLiveSessionsUseCase>(
      () => GetActiveLiveSessionsUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<GetLiveSessionDetailUseCase>(
      () => GetLiveSessionDetailUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<JoinLiveSessionUseCase>(
      () => JoinLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<LeaveLiveSessionUseCase>(
      () => LeaveLiveSessionUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<SendLiveCommentUseCase>(
      () => SendLiveCommentUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<SendSuperChatUseCase>(
      () => SendSuperChatUseCase(Get.find<LiveRepository>()),
    );
    Get.lazyPut<GetLiveCommentsUseCase>(
      () => GetLiveCommentsUseCase(Get.find<LiveRepository>()),
    );

    // Controller
    Get.lazyPut<LiveController>(
      () => LiveController(
        Get.find<GetActiveLiveSessionsUseCase>(),
        Get.find<GetLiveSessionDetailUseCase>(),
        Get.find<JoinLiveSessionUseCase>(),
        Get.find<LeaveLiveSessionUseCase>(),
        Get.find<SendLiveCommentUseCase>(),
        Get.find<SendSuperChatUseCase>(),
        Get.find<GetLiveCommentsUseCase>(),
      ),
    );
  }
}
