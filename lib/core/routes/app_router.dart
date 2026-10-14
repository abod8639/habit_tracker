import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/features/about/presentation/page/about_page.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:habit_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:habit_tracker/features/generate_plan/presentation/pages/category_selection_screen.dart';
import 'package:habit_tracker/features/generate_plan/presentation/pages/plan_result_screen.dart';
import 'package:habit_tracker/features/generate_plan/presentation/pages/questionnaire_screen.dart';
import 'package:habit_tracker/features/habitstats/presentation/pages/habit_stats_page.dart';
import 'package:habit_tracker/features/home/presentation/pages/home_screen.dart';
import 'package:habit_tracker/features/setting/presentation/pages/settings_page.dart';
import 'package:habit_tracker/features/theme/presentation/pages/theme_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final AnalyticsService _analytics = AnalyticsService();

  static GoRouter? _router;
  static GoRouter get router => _router ??= _createRouter();

  static GoRouter _createRouter() {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.root,
      observers: [
        _analytics.getObserver(),
        _analytics.getTimeTrackerObserver(),
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
          builder: (context, state) => const HabitStatsPage(),
        ),
        GoRoute(
          path: AppRoutes.theme,
          name: AppRoutes.theme,
          builder: (context, state) => const ThemePage(),
        ),
        GoRoute(
          path: AppRoutes.aiCoach,
          name: AppRoutes.aiCoach,
          builder: (context, state) => const AiChatPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.categorySelection,
          name: AppRoutes.categorySelection,
          builder: (context, state) => const CategorySelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.questionnaire,
          name: AppRoutes.questionnaire,
          builder: (context, state) => const QuestionnaireScreen(),
        ),
        GoRoute(
          path: AppRoutes.result,
          name: AppRoutes.result,
          builder: (context, state) => const PlanResultScreen(),
        ),
        GoRoute(
          path: AppRoutes.about,
          name: AppRoutes.about,
          builder: (context, state) => const AboutPage(),
        ),
      ],
    );
  }
}
