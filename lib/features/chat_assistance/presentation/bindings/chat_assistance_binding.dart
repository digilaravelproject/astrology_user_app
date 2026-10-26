import 'package:get/get.dart';
import 'package:astro_user/features/chat_assistance/presentation/controllers/chat_assistance_controller.dart';

class ChatAssistanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatAssistanceController>(() => ChatAssistanceController());
  }
}
