import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/ai_chat/data/datasources/ai_chat_local_datasource.dart';
import 'package:habit_tracker/features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:habit_tracker/features/ai_chat/data/repositories/ai_chat_repository_impl.dart';
import 'package:habit_tracker/features/ai_chat/domain/repositories/ai_chat_repository.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/clear_chat_history_usecase.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/save_chat_history_usecase.dart';

// Data Sources
final aiChatLocalDataSourceProvider = Provider<AiChatLocalDataSource>((ref) {
  return AiChatLocalDataSourceImpl();
});

final aiChatRemoteDataSourceProvider = Provider<AiChatRemoteDataSource>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return AiChatRemoteDataSourceImpl(geminiService: gemini);
});

// Repository
final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  final local = ref.watch(aiChatLocalDataSourceProvider);
  final remote = ref.watch(aiChatRemoteDataSourceProvider);
  return AiChatRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

// Use Cases
final getChatHistoryUseCaseProvider = Provider<GetChatHistoryUseCase>((ref) {
  return GetChatHistoryUseCase(ref.watch(aiChatRepositoryProvider));
});

final saveChatHistoryUseCaseProvider = Provider<SaveChatHistoryUseCase>((ref) {
  return SaveChatHistoryUseCase(ref.watch(aiChatRepositoryProvider));
});

final clearChatHistoryUseCaseProvider = Provider<ClearChatHistoryUseCase>((ref) {
  return ClearChatHistoryUseCase(ref.watch(aiChatRepositoryProvider));
});
