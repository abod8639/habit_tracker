import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_remote_datasource.dart';
import 'package:habit_tracker/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:habit_tracker/features/theme/domain/repositories/theme_repository.dart';
import 'package:habit_tracker/features/theme/domain/usecases/get_theme_settings_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/save_theme_settings_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/sync_theme_with_cloud_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/upload_theme_settings_usecase.dart';

// Data Sources
final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  final storage = ref.watch(themeStorageServiceProvider);
  return ThemeLocalDataSourceImpl(storage);
});

final themeRemoteDataSourceProvider = Provider<ThemeRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return ThemeRemoteDataSourceImpl(firestore);
});

// Repository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final local = ref.watch(themeLocalDataSourceProvider);
  final remote = ref.watch(themeRemoteDataSourceProvider);
  return ThemeRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

// Use Cases
final getThemeSettingsUseCaseProvider = Provider<GetThemeSettingsUseCase>((ref) {
  return GetThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
});

final saveThemeSettingsUseCaseProvider = Provider<SaveThemeSettingsUseCase>((ref) {
  return SaveThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
});

final syncThemeWithCloudUseCaseProvider = Provider<SyncThemeWithCloudUseCase>((ref) {
  return SyncThemeWithCloudUseCase(ref.watch(themeRepositoryProvider));
});

final uploadThemeSettingsUseCaseProvider = Provider<UploadThemeSettingsUseCase>((ref) {
  return UploadThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
});
