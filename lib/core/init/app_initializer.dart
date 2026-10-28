import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/home/data/facade/habit_facade_impl.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Centralized application bootstrap and infrastructure initializer.
class AppInitializer {
  AppInitializer._();

  static late FirestoreService firestoreService;
  static late ThemeStorageService themeStorage;
  static late SettingsStorage settingsStorage;
  static late LangStorage langStorage;
  static late AppDatabase database;
  static late KeyValueStorage keyValueStorage;
  static NotificationService? notificationService;
  static FcmService? fcmService;

  /// Initializes SQLite database, key-value storage, environment variables,
  /// core infrastructure services, and localization.
  static Future<void> init() async {
    try {
      // 1. Initialize SQLite Drift Database
      database = AppDatabase();

      // 2. Initialize in-memory cached Key-Value storage backed by SQLite
      keyValueStorage = KeyValueStorage(database);
      await keyValueStorage.init();

      // 3. Initialize storage services
      themeStorage = ThemeStorageService(keyValueStorage);
      settingsStorage = SettingsStorage(keyValueStorage);
      langStorage = LangStorage(keyValueStorage);

      // 4. Register cross-feature contracts
      HabitFacadeImpl.register();

      // 5. Load Environment variables
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // .env is optional
      }

      // 6. Initialize independent infrastructure services immediately as singletons
      firestoreService = FirestoreService();
      notificationService = NotificationService();
      fcmService = FcmService();

      // Launch async platform services in background without blocking runApp() or delaying first frame render
      unawaited(_initBackgroundServices());

      // 7. Initialize Localization so S.current is never null on startup or hot restart
      try {
        final langCode = langStorage.getCurrentLanguage();
        Locale initialLocale;
        if (langCode == 'ar') {
          initialLocale = const Locale('ar');
        } else if (langCode == 'en') {
          initialLocale = const Locale('en');
        } else {
          final deviceLocale = PlatformDispatcher.instance.locale;
          initialLocale = deviceLocale.languageCode == 'ar'
              ? const Locale('ar')
              : const Locale('en');
        }
        await S.load(initialLocale);
      } catch (e) {
        debugPrint('Localization initialization error: $e');
      }
    } catch (e) {
      throw Exception('FATAL initialization error: $e');
    }
  }

  /// Initializes background services (Notifications, FCM) asynchronously
  /// without blocking the UI main thread during app bootstrap.
  static Future<void> _initBackgroundServices() async {
    try {
      await Future.wait([
        () async {
          try {
            await notificationService?.init();
          } catch (e) {
            debugPrint('NotificationService initialization error: $e');
          }
        }(),
        () async {
          try {
            await fcmService?.init();
          } catch (e) {
            debugPrint('FcmService initialization error: $e');
          }
        }(),
      ]);
    } catch (e) {
      debugPrint('Background services initialization error: $e');
    }
  }
}
