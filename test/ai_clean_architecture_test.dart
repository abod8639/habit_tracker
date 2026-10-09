import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/ai_chat/domain/entities/chat_message_entity.dart';
import 'package:habit_tracker/features/ai_chat/data/models/chat_message_model.dart';
import 'package:habit_tracker/features/ai_chat/data/datasources/ai_chat_local_datasource.dart';
import 'package:habit_tracker/features/ai_chat/data/datasources/ai_chat_remote_datasource.dart';
import 'package:habit_tracker/features/ai_chat/data/repositories/ai_chat_repository_impl.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/save_chat_history_usecase.dart';
import 'package:habit_tracker/features/ai_chat/domain/usecases/clear_chat_history_usecase.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/generate_plan/data/datasources/plan_remote_datasource.dart';

class FakeAiChatRemoteDataSource implements AiChatRemoteDataSource {
  String? lastSystemInstruction;
  List<ChatMessageEntity>? lastHistory;

  @override
  void startChatSession({
    required String systemInstruction,
    required List<ChatMessageEntity> history,
  }) {
    lastSystemInstruction = systemInstruction;
    lastHistory = history;
  }

  @override
  Stream<String> sendMessageStream(String message) async* {
    yield 'Chunk 1';
    yield 'Chunk 2';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late AiChatLocalDataSourceImpl localDataSource;
  late FakeAiChatRemoteDataSource remoteDataSource;
  late AiChatRepositoryImpl repository;
  late GetChatHistoryUseCase getChatHistoryUseCase;
  late SaveChatHistoryUseCase saveChatHistoryUseCase;
  late ClearChatHistoryUseCase clearChatHistoryUseCase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('ai_clean_arch_test_');
    Hive.init(tempDir.path);

    localDataSource = AiChatLocalDataSourceImpl();
    remoteDataSource = FakeAiChatRemoteDataSource();
    repository = AiChatRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );

    getChatHistoryUseCase = GetChatHistoryUseCase(repository);
    saveChatHistoryUseCase = SaveChatHistoryUseCase(repository);
    clearChatHistoryUseCase = ClearChatHistoryUseCase(repository);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AI Clean Architecture - AI Chat Feature Tests', () {
    test('ChatMessageModel serialization and entity conversion works properly', () {
      final now = DateTime.now();
      final model = ChatMessageModel(
        text: 'Hello Coach',
        isUser: true,
        hasError: false,
        timestamp: now,
      );

      final json = model.toJson();
      expect(json['text'], 'Hello Coach');
      expect(json['isUser'], true);
      expect(json['hasError'], false);

      final fromJson = ChatMessageModel.fromJson(json);
      expect(fromJson.text, model.text);
      expect(fromJson.isUser, model.isUser);
      expect(fromJson.hasError, model.hasError);

      final entity = model.copyWith(text: 'Updated Text');
      expect(entity.text, 'Updated Text');
      expect(entity.isUser, true);
    });

    test('AiChatLocalDataSource saves, retrieves, and clears chat history', () async {
      final messages = [
        const ChatMessageModel(text: 'Msg 1', isUser: true),
        const ChatMessageModel(text: 'Reply 1', isUser: false),
      ];

      await localDataSource.saveChatHistory(messages);
      final loaded = await localDataSource.getChatHistory();

      expect(loaded.length, 2);
      expect(loaded[0].text, 'Msg 1');
      expect(loaded[1].text, 'Reply 1');

      await localDataSource.clearChatHistory();
      final afterClear = await localDataSource.getChatHistory();
      expect(afterClear, isEmpty);
    });

    test('AiChatRepository and UseCases interact and coordinate layers cleanly', () async {
      final messages = [
        const ChatMessageEntity(text: 'What should I do?', isUser: true),
      ];

      final saveResult = await saveChatHistoryUseCase(messages);
      expect(saveResult.isRight(), isTrue);

      final getResult = await getChatHistoryUseCase();
      expect(getResult.isRight(), isTrue);
      getResult.fold(
        (failure) => fail('Should not fail'),
        (loaded) {
          expect(loaded.length, 1);
          expect(loaded.first.text, 'What should I do?');
        },
      );

      repository.initChatSession(
        systemInstruction: 'Coaching Instruction',
        history: messages,
      );
      expect(remoteDataSource.lastSystemInstruction, 'Coaching Instruction');
      expect(remoteDataSource.lastHistory?.length, 1);

      final streamChunks = await repository.sendMessageStream('Ping').toList();
      expect(streamChunks, ['Chunk 1', 'Chunk 2']);

      final clearResult = await clearChatHistoryUseCase();
      expect(clearResult.isRight(), isTrue);
    });
  });

  group('AI Clean Architecture - Generate Plan Dedicated Service Tests', () {
    test('PlanRemoteDataSourceImpl is decoupled and instantiable with GeminiService', () {
      final geminiService = GeminiService();
      final planRemoteDataSource = PlanRemoteDataSourceImpl(
        geminiService: geminiService,
      );

      expect(planRemoteDataSource, isNotNull);
      expect(planRemoteDataSource.geminiService, equals(geminiService));
    });
  });
}
