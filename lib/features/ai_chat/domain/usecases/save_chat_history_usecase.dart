import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

class SaveChatHistoryUseCase {
  final AiChatRepository repository;

  SaveChatHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call(List<ChatMessageEntity> messages) {
    return repository.saveChatHistory(messages);
  }
}
