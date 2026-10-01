import 'package:habit_tracker/core/routes/app_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';

Future<void> navigateToLogin() async {
  final settingsStorage = SettingsStorage();
  await settingsStorage.init();
  await settingsStorage.setSkippedLogin(false);
  AppRouter.router.go(AppRoutes.login);
}
