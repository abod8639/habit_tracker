import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
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
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory() async {
    try {
      final models = await localDataSource.getChatHistory();
      return Right(models);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveChatHistory(
    List<ChatMessageEntity> messages,
  ) async {
    try {
      final models = messages.map(ChatMessageModel.fromEntity).toList();
      await localDataSource.saveChatHistory(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearChatHistory() async {
    try {
      await localDataSource.clearChatHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
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
  Stream<String> sendMessageStream(String message) {
    return remoteDataSource.sendMessageStream(message);
  }
}
