import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/features/history/data/repositories/history_repository.dart';
import 'package:astro_user/features/history/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:astro_user/features/history/domain/usecases/get_call_sessions_usecase.dart';
import 'package:astro_user/features/history/presentation/controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryRepository>(() => HistoryRepositoryImpl(apiClient: Get.find<ApiClient>()));
    Get.lazyPut<GetChatSessionsUseCase>(() => GetChatSessionsUseCase(Get.find<HistoryRepository>()));
    Get.lazyPut<GetCallSessionsUseCase>(() => GetCallSessionsUseCase(Get.find<HistoryRepository>()));
    Get.lazyPut<HistoryController>(() => HistoryController(
      getChatSessionsUseCase: Get.find<GetChatSessionsUseCase>(),
      getCallSessionsUseCase: Get.find<GetCallSessionsUseCase>(),
    ));
  }
}
