import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource_impl.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_local_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email_usecase.dart';
import '../../domain/usecases/sign_up_with_email_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_auth_state_usecase.dart';
import '../../domain/usecases/set_skip_login_usecase.dart';
import '../../domain/usecases/get_skip_login_status_usecase.dart';
import 'auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    final settingsStorage = Get.find<SettingsStorage>();

    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
    Get.lazyPut<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(settingsStorage),
    );

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find(),
        localDataSource: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => SignInWithEmailUseCase(Get.find()));
    Get.lazyPut(() => SignUpWithEmailUseCase(Get.find()));
    Get.lazyPut(() => SignInWithGoogleUseCase(Get.find()));
    Get.lazyPut(() => SignOutUseCase(Get.find()));
    Get.lazyPut(() => ResetPasswordUseCase(Get.find()));
    Get.lazyPut(() => GetAuthStateUseCase(Get.find()));
    Get.lazyPut(() => SetSkipLoginUseCase(Get.find()));
    Get.lazyPut(() => GetSkipLoginStatusUseCase(Get.find()));

    // Controller
    Get.lazyPut(() => AuthController());
  }
}
