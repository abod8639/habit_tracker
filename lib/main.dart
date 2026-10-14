import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/features/setting/presentation/providers/lang_providers.dart';
import 'package:habit_tracker/features/theme/presentation/providers/theme_providers.dart';
import 'package:habit_tracker/firebase_options.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/utils/restart_widget.dart';
import 'package:habit_tracker/core/error/error_app.dart';
import 'package:habit_tracker/core/routes/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      }

      await AppInitializer.init();

      runApp(
        RestartWidget(
          child: const ProviderScope(
            child: MyApp(),
          ),
        ),
      );
    },
    (error, stack) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        runApp(
          ErrorApp(
            error: error.toString(),
            onRestart: () => main(),
          ),
        );
      });
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langState = ref.watch(langNotifierProvider);
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      routerConfig: AppRouter.router,
      locale: langState.effectiveLocale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.themeMode,
    );
  }
}
