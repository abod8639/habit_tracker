import 'package:get/get.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import '../../data/datasources/theme_local_datasource.dart';
import '../../data/datasources/theme_remote_datasource.dart';
import '../../data/repositories/theme_repository_impl.dart';
import '../../domain/repositories/theme_repository.dart';
import '../../domain/usecases/get_theme_settings_usecase.dart';
import '../../domain/usecases/save_theme_settings_usecase.dart';
import '../../domain/usecases/sync_theme_with_cloud_usecase.dart';
import '../../domain/usecases/upload_theme_settings_usecase.dart';
import 'theme_controller.dart';

class ThemeBinding extends Bindings {
  @override
  void dependencies() {
    // Services (Already initialized in main/initialize_app)
    final themeStorage = Get.find<ThemeStorageService>();
    final firestoreService = Get.find<FirestoreService>();

    // Data Sources
    Get.lazyPut<ThemeLocalDataSource>(
      () => ThemeLocalDataSourceImpl(themeStorage),
    );
    Get.lazyPut<ThemeRemoteDataSource>(
      () => ThemeRemoteDataSourceImpl(firestoreService),
    );

    // Repository
    Get.lazyPut<ThemeRepository>(
      () => ThemeRepositoryImpl(
        localDataSource: Get.find(),
        remoteDataSource: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetThemeSettingsUseCase(Get.find()));
    Get.lazyPut(() => SaveThemeSettingsUseCase(Get.find()));
    Get.lazyPut(() => SyncThemeWithCloudUseCase(Get.find()));
    Get.lazyPut(() => UploadThemeSettingsUseCase(Get.find()));

    // Controller
    Get.lazyPut(() => ThemeController());
  }
}
