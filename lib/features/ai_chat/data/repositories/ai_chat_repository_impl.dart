import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../datasources/ai_chat_local_datasource.dart';
import '../datasources/ai_chat_remote_datasource.dart';
import '../models/chat_message_model.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatLocalDataSource localDataSource;
  final AiChatRemoteDataSource remoteDataSource;

  AiChatRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory() {
    return NetworkErrorHandler.guard(() async {
      final models = await localDataSource.getChatHistory();
      return models;
    });
  }

  @override
  Future<Either<Failure, void>> saveChatHistory(
    List<ChatMessageEntity> messages,
  ) {
    return NetworkErrorHandler.guard(() async {
      final models = messages.map(ChatMessageModel.fromEntity).toList();
      await localDataSource.saveChatHistory(models);
    });
  }

  @override
  Future<Either<Failure, void>> clearChatHistory() {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.clearChatHistory();
    });
  }

  @override
  void initChatSession({
    required String systemInstruction,
    required List<ChatMessageEntity> history,
  }) {
    remoteDataSource.startChatSession(
      systemInstruction: systemInstruction,
      history: history,
    );
  }

  @override
  Stream<Either<Failure, String>> sendMessageStream(String message) async* {
    try {
      final stream = remoteDataSource.sendMessageStream(message);
      await for (final chunk in stream) {
        yield Right(chunk);
      }
    } catch (e, stack) {
      final failure = NetworkErrorHandler.handle(e, stack);
      yield Left(failure);
    }
  }
}
