import 'package:get/get.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_binding.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_binding.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 0. Core Services
    Get.put(AnalyticsService(), permanent: true);

    // 1. Auth Feature Dependencies
    AuthBinding().dependencies();

    // 2. Theme Feature Dependencies
    ThemeBinding().dependencies();

    // 3. Habit Feature (Provides global services like Local DataSource & Firestore)
    HabitBinding().dependencies();

    // 4. Setting Feature (Depends on services from Habit)
    SettingBinding().dependencies();
  }
}
