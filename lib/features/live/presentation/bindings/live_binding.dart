import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/live/data/datasources/live_remote_data_source.dart';
import 'package:astro_user/features/live/data/repositories/live_repository_impl.dart';
import 'package:astro_user/features/live/domain/repositories/live_repository.dart';
import 'package:astro_user/features/live/domain/usecases/live_usecases.dart';
import 'package:astro_user/features/live/presentation/controllers/live_controller.dart';

class LiveBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<LiveRemoteDataSource>(
      () => LiveRemoteDataSource(Get.find<ApiClient>()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<LiveRepository>(
      () => LiveRepositoryImpl(Get.find<LiveRemoteDataSource>()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut<GetActiveLiveSessionsUseCase>(
      () => GetActiveLiveSessionsUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetLiveSessionDetailUseCase>(
      () => GetLiveSessionDetailUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<JoinLiveSessionUseCase>(
      () => JoinLiveSessionUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<LeaveLiveSessionUseCase>(
      () => LeaveLiveSessionUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<SendLiveCommentUseCase>(
      () => SendLiveCommentUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<SendSuperChatUseCase>(
      () => SendSuperChatUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<GetLiveCommentsUseCase>(
      () => GetLiveCommentsUseCase(Get.find<LiveRepository>()),
      fenix: true,
    );
    Get.lazyPut<WatchLiveSessionUseCase>(
      () => WatchLiveSessionUseCase(Get.find<LiveRepository>()),
      fenix: true,
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
        Get.find<WatchLiveSessionUseCase>(),
      ),
      fenix: true,
    );
  }
}

