import 'package:get/get.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import '../../data/datasources/ai_chat_local_datasource.dart';
import '../../data/datasources/ai_chat_remote_datasource.dart';
import '../../data/repositories/ai_chat_repository_impl.dart';
import '../../domain/repositories/ai_chat_repository.dart';
import '../../domain/usecases/clear_chat_history_usecase.dart';
import '../../domain/usecases/get_chat_history_usecase.dart';
import '../../domain/usecases/save_chat_history_usecase.dart';
import 'ai_chat_controller.dart';

class AiChatBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GeminiService>()) {
      Get.lazyPut(() => GeminiService());
    }

    if (!Get.isRegistered<AiChatLocalDataSource>()) {
      Get.lazyPut<AiChatLocalDataSource>(
        () => AiChatLocalDataSourceImpl(),
      );
    }

    if (!Get.isRegistered<AiChatRemoteDataSource>()) {
      Get.lazyPut<AiChatRemoteDataSource>(
        () => AiChatRemoteDataSourceImpl(geminiService: Get.find<GeminiService>()),
      );
    }

    if (!Get.isRegistered<AiChatRepository>()) {
      Get.lazyPut<AiChatRepository>(
        () => AiChatRepositoryImpl(
          localDataSource: Get.find<AiChatLocalDataSource>(),
          remoteDataSource: Get.find<AiChatRemoteDataSource>(),
        ),
      );
    }

    if (!Get.isRegistered<GetChatHistoryUseCase>()) {
      Get.lazyPut(() => GetChatHistoryUseCase(Get.find<AiChatRepository>()));
    }

    if (!Get.isRegistered<SaveChatHistoryUseCase>()) {
      Get.lazyPut(() => SaveChatHistoryUseCase(Get.find<AiChatRepository>()));
    }

    if (!Get.isRegistered<ClearChatHistoryUseCase>()) {
      Get.lazyPut(() => ClearChatHistoryUseCase(Get.find<AiChatRepository>()));
    }

    if (!Get.isRegistered<AiChatController>()) {
      Get.lazyPut(
        () => AiChatController(
          chatRepository: Get.find<AiChatRepository>(),
          getChatHistoryUseCase: Get.find<GetChatHistoryUseCase>(),
          saveChatHistoryUseCase: Get.find<SaveChatHistoryUseCase>(),
          clearChatHistoryUseCase: Get.find<ClearChatHistoryUseCase>(),
        ),
        fenix: true,
      );
    }
  }
}
