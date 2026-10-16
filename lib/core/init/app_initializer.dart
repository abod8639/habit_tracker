import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/database/app_database.dart';
import 'package:habit_tracker/core/database/migrators/hive_to_sql_migrator.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/facade/habit_facade_impl.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Centralized application bootstrap and infrastructure initializer.
class AppInitializer {
  AppInitializer._();

  static late FirestoreService firestoreService;
  static late ThemeStorageService themeStorage;
  static late SettingsStorage settingsStorage;
  static late LangStorage langStorage;
  static late AppDatabase database;
  static NotificationService? notificationService;
  static FcmService? fcmService;

  /// Initializes storage adapters, Hive boxes, environment variables,
  /// core infrastructure services, and localization.
  static Future<void> init() async {
    try {
      // 1. Initialize Hive and register adapters
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HabitModelAdapter());
      }

      // 2. Open necessary Hive boxes concurrently with corruption recovery
      await Future.wait([
        _openBoxSafely(HabitStorage.boxName),
        _openBoxSafely(HabitStorage.backupVaultBox),
        _openBoxSafely(ThemeStorageService.themeBox),
        _openBoxSafely(LangStorage.boxName),
        _openBoxSafely(SettingsStorage.boxName),
      ]);

      // 3. Initialize SQLite Drift Database & run migration from Hive if needed
      database = AppDatabase();
      final migrator = HiveToSqlMigrator(database);
      await migrator.migrateIfNeeded();

      // 4. Register cross-feature contracts
      HabitFacadeImpl.register();

      // 5. Load Environment variables
      try {
        await dotenv.load(fileName: '.env');
      } catch (_) {
        // .env is optional
      }

      // 6. Initialize independent infrastructure services concurrently
      firestoreService = FirestoreService();
      langStorage = LangStorage(Hive.box(LangStorage.boxName));

      await Future.wait([
        () async {
          themeStorage = await ThemeStorageService.init();
        }(),
        () async {
          final sStorage = SettingsStorage();
          await sStorage.init();
          settingsStorage = sStorage;
        }(),
        () async {
          try {
            final notif = NotificationService();
            await notif.init();
            notificationService = notif;
          } catch (e) {
            debugPrint('NotificationService initialization error: $e');
          }
        }(),
        () async {
          try {
            final fcm = FcmService();
            await fcm.init();
            fcmService = fcm;
          } catch (e) {
            debugPrint('FcmService initialization error: $e');
          }
        }(),
      ]);

      // 5. Initialize Localization so S.current is never null on startup or hot restart
      try {
        final langBox = Hive.box(LangStorage.boxName);
        final langCode = langBox.get(
          LangStorage.languageKey,
          defaultValue: LangStorage.defaultLanguage,
        );
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

  /// Opens a Hive box safely. If corrupted, deletes and recreates a fresh box.
  static Future<void> _openBoxSafely(String boxName) async {
    if (Hive.isBoxOpen(boxName)) return;

    try {
      await Hive.openBox(boxName);
    } catch (e) {
      await _deleteCorruptedBox(boxName);
      await Hive.openBox(boxName);
    }
  }

  /// Deletes corrupted Hive box files from disk.
  static Future<void> _deleteCorruptedBox(String boxName) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final boxFile = File('${appDocDir.path}/$boxName.hive');
      final lockFile = File('${appDocDir.path}/$boxName.lock');

      if (await boxFile.exists()) await boxFile.delete();
      if (await lockFile.exists()) await lockFile.delete();
    } catch (_) {
      // Ignore deletion errors
    }
  }
}
