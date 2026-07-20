import 'package:astro_user/features/chat/domain/entities/chat_message.dart';
import 'package:astro_user/features/chat/domain/entities/chat_session.dart';

abstract class IChatRepository {
  Future<({List<ChatMessage> messages, String? startedAt, int? peerId})> getChatHistory({
    required int sessionId,
    required int currentUserId,
  });
  Future<int?> sendTextMessage({
    required int sessionId,
    required String text,
  });
  Future<({int id, String url})?> sendImageAttachment({
    required int sessionId,
    required dynamic xFile,
  });
  Future<({int id, String url})?> sendDocumentAttachment({
    required int sessionId,
    required String fileName,
    required dynamic pickerResult,
  });
  Future<void> markMessagesRead(int sessionId);
  Future<void> syncMessageStatus({required int sessionId, required List<int> messageIds, required String status});
  Future<ChatSession?> endChatSession(int sessionId);
  Future<void> rejectChatSession(int sessionId);
}
