import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/core/services/home_widget_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/lang_storage.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_storage.dart';

/// Firestore infrastructure service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Analytics service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Home widget sync service provider
final homeWidgetServiceProvider = Provider<HomeWidgetService>((ref) {
  return HomeWidgetService();
});

/// Gemini AI service provider
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

/// Key-Value storage service provider (backed by SQLite)
final keyValueStorageProvider = Provider<KeyValueStorage>((ref) {
  try {
    return AppInitializer.keyValueStorage;
  } catch (_) {
    final db = ref.watch(appDatabaseProvider);
    return KeyValueStorage(db);
  }
});

/// Theme storage service provider
final themeStorageServiceProvider = Provider<ThemeStorageService?>((ref) {
  try {
    return AppInitializer.themeStorage;
  } catch (_) {
    return null;
  }
});

/// Settings storage service provider
final settingsStorageServiceProvider = Provider<SettingsStorage>((ref) {
  try {
    return AppInitializer.settingsStorage;
  } catch (_) {
    final storage = ref.watch(keyValueStorageProvider);
    return SettingsStorage(storage);
  }
});

/// Language storage service provider
final langStorageServiceProvider = Provider<LangStorage>((ref) {
  try {
    return AppInitializer.langStorage;
  } catch (_) {
    final storage = ref.watch(keyValueStorageProvider);
    return LangStorage(storage);
  }
});

/// Local notifications service provider
final notificationServiceProvider = Provider<NotificationService?>((ref) {
  return AppInitializer.notificationService;
});

/// Firebase Cloud Messaging service provider
final fcmServiceProvider = Provider<FcmService?>((ref) {
  return AppInitializer.fcmService;
});

/// Shared HTTP client provider
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});
