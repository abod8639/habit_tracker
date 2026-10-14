import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/core/services/analytics_service.dart';
import 'package:habit_tracker/core/services/fcm_service.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/core/services/home_widget_service.dart';
import 'package:habit_tracker/core/services/notification_service.dart';
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

/// Theme storage service provider (Hive)
final themeStorageServiceProvider = Provider<ThemeStorageService>((ref) {
  return AppInitializer.themeStorage;
});

/// Settings storage service provider (Hive)
final settingsStorageServiceProvider = Provider<SettingsStorage>((ref) {
  return AppInitializer.settingsStorage;
});

/// Language storage service provider (Hive)
final langStorageServiceProvider = Provider<LangStorage>((ref) {
  return AppInitializer.langStorage;
});

/// Local notifications service provider
final notificationServiceProvider = Provider<NotificationService?>((ref) {
  return AppInitializer.notificationService;
});

/// Firebase Cloud Messaging service provider
final fcmServiceProvider = Provider<FcmService?>((ref) {
  return AppInitializer.fcmService;
});
