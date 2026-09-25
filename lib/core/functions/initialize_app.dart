import 'dart:io';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Centralized application initialization logic
Future<void> initializeApp() async {
  try {
    // 1. Initialize Hive and register adapters
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitModelAdapter());
    }

    // 2. Open necessary Hive boxes with corruption recovery
    await _openBoxSafely(HabitStorage.boxName);
    await _openBoxSafely(ThemeStorageService.themeBox);
    await _openBoxSafely(LangStorage.boxName);
    await _openBoxSafely(SettingsStorage.boxName);

    // 3. Load Environment variables
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env is optional
    }

    // 4. Initialize and register infrastructure services
    Get.put(FirestoreService());

    final themeStorage = await ThemeStorageService.init();
    Get.put(themeStorage);

    final settingsStorage = SettingsStorage();
    await settingsStorage.init();
    Get.put(settingsStorage);

    try {
      final notificationService = NotificationService();
      await notificationService.init();
      Get.put<NotificationService>(notificationService, permanent: true);
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }

    try {
      final fcmService = FcmService();
      await fcmService.init();
      Get.put<FcmService>(fcmService, permanent: true);
    } catch (e) {
      debugPrint('FcmService initialization error: $e');
    }

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
Future<void> _openBoxSafely(String boxName) async {
  if (Hive.isBoxOpen(boxName)) return;

  try {
    await Hive.openBox(boxName);
  } catch (e) {
    await _deleteCorruptedBox(boxName);
    await Hive.openBox(boxName);
  }
}

/// Deletes corrupted Hive box files from disk
Future<void> _deleteCorruptedBox(String boxName) async {
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
