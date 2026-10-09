import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/chat_message_entity.dart';

abstract class AiChatRepository {
  /// Fetches stored conversation history.
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory();

  /// Persists recent chat messages.
  Future<Either<Failure, void>> saveChatHistory(List<ChatMessageEntity> messages);

  /// Clears stored chat history.
  Future<Either<Failure, void>> clearChatHistory();

  /// Initializes the conversational session with context and history.
  void initChatSession({
    required String systemInstruction,
    required List<ChatMessageEntity> history,
  });

  /// Sends a message and receives streaming chunks from the AI model.
  Stream<String> sendMessageStream(String message);
}
