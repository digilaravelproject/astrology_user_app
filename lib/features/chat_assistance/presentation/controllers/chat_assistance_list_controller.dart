import 'package:get/get.dart';
import 'package:astro_user/core/services/network/api_client.dart';
import 'package:astro_user/core/constants/app_urls.dart';

class ChatAssistanceListController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  final RxList<dynamic> activeSessions = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    hasError.value = false;
    errorMsg.value = '';

    try {
      final response = await _apiClient.get(AppUrls.chatAssistanceSessions);
      if (response.isSuccess) {
        final data = response.body['data']['data'] as List;
        activeSessions.assignAll(data);
      } else {
        hasError.value = true;
        errorMsg.value = response.message;
      }
    } catch (e) {
      hasError.value = true;
      errorMsg.value = e.toString();
      print('Error fetching assistant chat sessions: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
