import 'package:get/get.dart';
import '../../../../core/services/network/api_client.dart';
import '../domain/repositories/notification_repository.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationRepository(apiClient: Get.find<ApiClient>()));
    Get.lazyPut(() => NotificationController(repository: Get.find<NotificationRepository>()));
  }
}
