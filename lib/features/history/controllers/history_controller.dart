import 'package:get/get.dart';
import 'package:astro_user/features/history/domain/models/chat_session_model.dart';
import 'package:astro_user/features/call/domain/models/call_session_model.dart';
import 'package:astro_user/features/history/domain/usecases/get_chat_sessions_usecase.dart';
import 'package:astro_user/features/history/domain/usecases/get_call_sessions_usecase.dart';

class HistoryController extends GetxController {
  final GetChatSessionsUseCase _getChatSessionsUseCase;
  final GetCallSessionsUseCase _getCallSessionsUseCase;

  HistoryController({
    required GetChatSessionsUseCase getChatSessionsUseCase,
    required GetCallSessionsUseCase getCallSessionsUseCase,
  }) : _getChatSessionsUseCase = getChatSessionsUseCase,
       _getCallSessionsUseCase = getCallSessionsUseCase;

  // Chat Sessions
  final RxList<ChatSessionModel> chatSessions = <ChatSessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // Call Sessions
  final RxList<CallSessionModel> callSessions = <CallSessionModel>[].obs;
  final RxBool isCallLoading = false.obs;
  final RxString callError = ''.obs;
  int _currentCallPage = 1;
  bool _hasMoreCalls = true;
  bool get hasMoreCalls => _hasMoreCalls;

  @override
  void onInit() {
    super.onInit();
    fetchChatSessions();
    fetchCallSessions();
  }

  Future<void> fetchChatSessions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      chatSessions.clear();
      error.value = '';
    }

    if (!_hasMore || isLoading.value) return;

    try {
      isLoading.value = true;
      final response = await _getChatSessionsUseCase.execute(
        page: _currentPage,
      );

      if (response.data.isNotEmpty) {
        chatSessions.addAll(response.data);
        _currentPage++;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCallSessions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentCallPage = 1;
      _hasMoreCalls = true;
      callSessions.clear();
      callError.value = '';
    }

    if (!_hasMoreCalls || isCallLoading.value) return;

    try {
      isCallLoading.value = true;
      final response = await _getCallSessionsUseCase.execute(
        page: _currentCallPage,
      );

      if (response.data.isNotEmpty) {
        callSessions.addAll(response.data);
        _currentCallPage++;
      } else {
        _hasMoreCalls = false;
      }
    } catch (e) {
      callError.value = e.toString();
    } finally {
      isCallLoading.value = false;
    }
  }
}
