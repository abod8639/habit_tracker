import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/ai_chat_repository.dart';

class GetChatHistoryUseCase {
  final AiChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call() {
    return repository.getChatHistory();
  }
}
