import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../repositories/ai_chat_repository.dart';

class ClearChatHistoryUseCase {
  final AiChatRepository repository;

  ClearChatHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.clearChatHistory();
  }
}
