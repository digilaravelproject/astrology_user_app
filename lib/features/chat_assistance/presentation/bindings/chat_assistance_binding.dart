import 'package:get/get.dart';
import '../controllers/chat_assistance_controller.dart';

class ChatAssistanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatAssistanceController>(() => ChatAssistanceController());
  }
}
