import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/bindings/initial_binding.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_controller.dart';
import 'package:habit_tracker/firebase_options.dart';
import 'package:habit_tracker/core/functions/initialize_app.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/utils/restart_widget.dart';
import 'package:habit_tracker/core/error/error_app.dart';
import 'package:habit_tracker/features/auth/presentation/widgets/auth_wrapper.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      }

      await initializeApp();

      InitialBinding().dependencies();

      runApp(RestartWidget(child: const MyApp()));
    },
    (error, stack) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        runApp(ErrorApp(error: error.toString()));
      });
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LangController controllerLanguage = Get.find<LangController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final AnalyticsService analyticsService = Get.find<AnalyticsService>();

    return Obx(
      () => GetMaterialApp(
        initialBinding: InitialBinding(),
        locale: Locale(controllerLanguage.language.value),
        navigatorObservers: [
          analyticsService.getObserver(),
          analyticsService.getTimeTrackerObserver(),
        ],

        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        supportedLocales: S.delegate.supportedLocales,

        debugShowCheckedModeBanner: false,
        title: 'Habit Tracker',
        defaultTransition: Transition.fadeIn,
        smartManagement: SmartManagement.full,

        theme: themeController.lightTheme.value,
        darkTheme: themeController.darkTheme.value,
        themeMode: themeController.themeMode.value,

        getPages: appPages,
        home: const AuthWrapper(),
      ),
    );
  }
}
