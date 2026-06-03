import 'package:astro_user/features/chat/domain/repositories/chat_repository_interface.dart';

class SendAttachmentUseCase {
  final ChatRepositoryInterface _repository;
  const SendAttachmentUseCase(this._repository);

  /// Send an image (pass image_picker XFile as [file])
  Future<({int id, String url})?> executeImage({
    required int sessionId,
    required dynamic file,
  }) {
    return _repository.sendImageAttachment(sessionId: sessionId, xFile: file);
  }

  /// Send a document (pass file_picker FilePickerResult as [result])
  Future<({int id, String url})?> executeDocument({
    required int sessionId,
    required String fileName,
    required dynamic result,
  }) {
    return _repository.sendDocumentAttachment(
      sessionId: sessionId,
      fileName: fileName,
      pickerResult: result,
    );
  }
}
