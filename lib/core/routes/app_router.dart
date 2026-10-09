import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_binding.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_controller.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:habit_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:habit_tracker/features/enerate_plan/presentation/controllers/plan_generator_controller.dart';
import 'package:habit_tracker/features/enerate_plan/presentation/pages/category_selection_screen.dart';
import 'package:habit_tracker/features/enerate_plan/presentation/pages/plan_result_screen.dart';
import 'package:habit_tracker/features/enerate_plan/presentation/pages/questionnaire_screen.dart';
import 'package:habit_tracker/features/habitstats/presentation/controllers/habitstats_binding.dart';
import 'package:habit_tracker/features/habitstats/presentation/controllers/habitstats_controller.dart';
import 'package:habit_tracker/features/habitstats/presentation/pages/habit_stats_page.dart';
import 'package:habit_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/features/setting/presentation/pages/settings_page.dart';
import 'package:habit_tracker/features/theme/presentation/pages/theme_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = Get.key;

  static GoRouter? _router;
  static GoRouter get router => _router ??= _createRouter();

  static GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.root,
      observers: [
        if (Get.isRegistered<AnalyticsService>()) ...[
          Get.find<AnalyticsService>().getObserver(),
          Get.find<AnalyticsService>().getTimeTrackerObserver(),
        ],
      ],
      routes: [
        GoRoute(
          path: AppRoutes.root,
          name: AppRoutes.root,
          builder: (context, state) => const AuthWrapper(),
        ),
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          name: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.stats,
          name: AppRoutes.stats,
          builder: (context, state) {
            if (!Get.isRegistered<HabitStatsController>()) {
              HabitStatsBinding().dependencies();
            }
            return const HabitStatsPage();
          },
        ),
        GoRoute(
          path: AppRoutes.theme,
          name: AppRoutes.theme,
          builder: (context, state) => const ThemePage(),
        ),
        GoRoute(
          path: AppRoutes.aiCoach,
          name: AppRoutes.aiCoach,
          builder: (context, state) {
            if (!Get.isRegistered<AiChatController>()) {
              AiChatBinding().dependencies();
            }
            return const AiChatPage();
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          builder: (context, state) {
            if (!Get.isRegistered<SyncController>()) {
              SettingBinding().dependencies();
            }
            return const SettingsPage();
          },
        ),
        GoRoute(
          path: AppRoutes.categorySelection,
          name: AppRoutes.categorySelection,
          builder: (context, state) {
            if (!Get.isRegistered<PlanGeneratorController>()) {
              Get.lazyPut<PlanGeneratorController>(
                () => PlanGeneratorController(),
                fenix: true,
              );
            }
            return const CategorySelectionScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.questionnaire,
          name: AppRoutes.questionnaire,
          builder: (context, state) {
            if (!Get.isRegistered<PlanGeneratorController>()) {
              Get.lazyPut<PlanGeneratorController>(
                () => PlanGeneratorController(),
                fenix: true,
              );
            }
            return const QuestionnaireScreen();
          },
        ),
        GoRoute(
          path: AppRoutes.result,
          name: AppRoutes.result,
          builder: (context, state) {
            if (!Get.isRegistered<PlanGeneratorController>()) {
              Get.lazyPut<PlanGeneratorController>(
                () => PlanGeneratorController(),
                fenix: true,
              );
            }
            return const PlanResultScreen();
          },
        ),
      ],
    );
  }
}
