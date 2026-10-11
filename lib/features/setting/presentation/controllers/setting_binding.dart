import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import '../../data/datasources/setting_local_datasource.dart';
import '../../data/datasources/setting_remote_datasource.dart';
import '../../data/repositories/setting_repository_impl.dart';
import '../../domain/repositories/setting_repository.dart';
import '../../domain/usecases/get_language_usecase.dart';
import '../../domain/usecases/save_language_usecase.dart';
import '../../domain/usecases/is_notification_enabled_usecase.dart';
import '../../domain/usecases/set_notification_enabled_usecase.dart';
import '../../domain/usecases/get_notification_time_usecase.dart';
import '../../domain/usecases/set_notification_time_usecase.dart';
import '../../domain/usecases/sync_habits_usecase.dart';
import '../../domain/usecases/get_last_sync_time_usecase.dart';
import '../../domain/usecases/clear_all_data_usecase.dart';
import '../../domain/usecases/get_custom_api_key_usecase.dart';
import '../../domain/usecases/save_custom_api_key_usecase.dart';
import '../../domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/core/guards/ai_guard.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import '../widget/ai_api_key_dialog.dart';
import 'lang_controller.dart';
import 'notification_controller.dart';
import 'sync_controller.dart';
import 'ai_settings_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<SettingLocalDataSource>(
      () => SettingLocalDataSourceImpl(
        langBox: Hive.box(LangStorage.boxName),
        settingsBox: Hive.box(SettingsStorage.boxName),
      ),
    );
    Get.lazyPut<SettingRemoteDataSource>(
      () => SettingRemoteDataSourceImpl(Get.find()),
    );

    // Repository
    Get.lazyPut<SettingRepository>(
      () => SettingRepositoryImpl(
        localDataSource: Get.find(),
        remoteDataSource: Get.find(),
        habitLocalDataSource: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetLanguageUseCase(Get.find()));
    Get.lazyPut(() => SaveLanguageUseCase(Get.find()));
    Get.lazyPut(() => IsNotificationEnabledUseCase(Get.find()));
    Get.lazyPut(() => SetNotificationEnabledUseCase(Get.find()));
    Get.lazyPut(() => GetNotificationTimeUseCase(Get.find()));
    Get.lazyPut(() => SetNotificationTimeUseCase(Get.find()));
    Get.lazyPut(() => SyncHabitsUseCase(Get.find()));
    Get.lazyPut(() => GetLastSyncTimeUseCase(Get.find()));
    Get.lazyPut(() => ClearAllDataUseCase(Get.find()));
    Get.lazyPut(() => GetCustomApiKeyUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SaveCustomApiKeyUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => ClearCustomApiKeyUseCase(Get.find()), fenix: true);

    // Controllers
    Get.lazyPut(() => LangController());
    Get.put(NotificationController(), permanent: true);
    Get.lazyPut(() => SyncController());
    Get.lazyPut(
      () => AiSettingsController(
        getCustomApiKeyUseCase: Get.find(),
        saveCustomApiKeyUseCase: Get.find(),
        clearCustomApiKeyUseCase: Get.find(),
      ),
      fenix: true,
    );

    // Wire up AiGuard handlers via DIP
    AiGuard.registerConfigHandler((context) async {
      final controller = Get.isRegistered<AiSettingsController>()
          ? Get.find<AiSettingsController>()
          : Get.put(
              AiSettingsController(
                getCustomApiKeyUseCase: Get.find(),
                saveCustomApiKeyUseCase: Get.find(),
                clearCustomApiKeyUseCase: Get.find(),
              ),
            );
      AiApiKeyDialog.show(context, controller);
    });

    AiGuard.registerHealthCheckHandler(() async {
      if (Get.isRegistered<AiSettingsController>()) {
        final controller = Get.find<AiSettingsController>();
        if (controller.apiKeyStatus.value == ApiKeyStatus.valid) {
          return true;
        }
        return await controller.checkKeyHealth();
      }
      return await GeminiService.isCurrentKeyValid();
    });
  }
}
