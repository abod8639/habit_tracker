import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_local_datasource.dart';
import 'package:habit_tracker/features/setting/data/datasources/setting_remote_datasource.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/setting/data/repositories/setting_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/repositories/setting_repository.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_all_data_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_language_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_last_sync_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_notification_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/is_notification_enabled_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_language_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/set_notification_enabled_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/set_notification_time_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/sync_habits_usecase.dart';

// Data Sources
final settingLocalDataSourceProvider = Provider<SettingLocalDataSource>((ref) {
  return SettingLocalDataSourceImpl(
    langBox: Hive.box(LangStorage.boxName),
    settingsBox: Hive.box(SettingsStorage.boxName),
  );
});

final settingRemoteDataSourceProvider = Provider<SettingRemoteDataSource>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return SettingRemoteDataSourceImpl(firestoreService);
});

// Repository
final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  final localDataSource = ref.watch(settingLocalDataSourceProvider);
  final remoteDataSource = ref.watch(settingRemoteDataSourceProvider);
  final habitLocalDataSource = ref.watch(habitLocalDataSourceProvider);
  return SettingRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    habitLocalDataSource: habitLocalDataSource,
  );
});

// Use Cases
final getLanguageUseCaseProvider = Provider<GetLanguageUseCase>((ref) {
  return GetLanguageUseCase(ref.watch(settingRepositoryProvider));
});

final saveLanguageUseCaseProvider = Provider<SaveLanguageUseCase>((ref) {
  return SaveLanguageUseCase(ref.watch(settingRepositoryProvider));
});

final isNotificationEnabledUseCaseProvider = Provider<IsNotificationEnabledUseCase>((ref) {
  return IsNotificationEnabledUseCase(ref.watch(settingRepositoryProvider));
});

final setNotificationEnabledUseCaseProvider = Provider<SetNotificationEnabledUseCase>((ref) {
  return SetNotificationEnabledUseCase(ref.watch(settingRepositoryProvider));
});

final getNotificationTimeUseCaseProvider = Provider<GetNotificationTimeUseCase>((ref) {
  return GetNotificationTimeUseCase(ref.watch(settingRepositoryProvider));
});

final setNotificationTimeUseCaseProvider = Provider<SetNotificationTimeUseCase>((ref) {
  return SetNotificationTimeUseCase(ref.watch(settingRepositoryProvider));
});

final syncHabitsUseCaseProvider = Provider<SyncHabitsUseCase>((ref) {
  return SyncHabitsUseCase(ref.watch(settingRepositoryProvider));
});

final getLastSyncTimeUseCaseProvider = Provider<GetLastSyncTimeUseCase>((ref) {
  return GetLastSyncTimeUseCase(ref.watch(settingRepositoryProvider));
});

final clearAllDataUseCaseProvider = Provider<ClearAllDataUseCase>((ref) {
  return ClearAllDataUseCase(ref.watch(settingRepositoryProvider));
});

final getCustomApiKeyUseCaseProvider = Provider<GetCustomApiKeyUseCase>((ref) {
  return GetCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});

final saveCustomApiKeyUseCaseProvider = Provider<SaveCustomApiKeyUseCase>((ref) {
  return SaveCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});

final clearCustomApiKeyUseCaseProvider = Provider<ClearCustomApiKeyUseCase>((ref) {
  return ClearCustomApiKeyUseCase(ref.watch(settingRepositoryProvider));
});
