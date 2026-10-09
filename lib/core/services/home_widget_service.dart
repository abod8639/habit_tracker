import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home_app_widget/home_app_widget_view.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import 'package:habit_tracker/features/theme/presentation/controllers/theme_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Service responsible for managing and synchronizing the mobile home screen widget
/// via `home_widget`. Renders off-screen snapshots of [HomeAppWidgetView] and triggers
/// OS-level widget refreshes.
class HomeWidgetService extends GetxService {
  static const String appWidgetProviderName = 'HabitAppWidgetProvider';
  static const String habitWidgetImageKey = 'habit_widget_image';
  static const String androidQualifiedName =
      'com.example.habit_tracker.HabitAppWidgetProvider';

  bool _isRendering = false;

  /// Renders the Flutter widget off-screen into an image and updates the native widget.
  Future<void> updateWidget({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) async {
    // home_widget only runs on Android and iOS
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    if (_isRendering) return;
    _isRendering = true;

    try {
      final themeController = Get.isRegistered<ThemeController>()
          ? Get.find<ThemeController>()
          : null;
      final langController = Get.isRegistered<LangController>()
          ? Get.find<LangController>()
          : null;

      final isDark = themeController != null
          ? (themeController.themeMode.value == ThemeMode.dark)
          : false;

      final themeData = isDark
          ? (themeController?.darkTheme.value ?? ThemeData.dark())
          : (themeController?.lightTheme.value ?? ThemeData.light());

      final effectiveLocale =
          langController?.effectiveLocale ?? const Locale('ar');

      final widgetToRender = Directionality(
        textDirection: effectiveLocale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Theme(
          data: themeData,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(380, 480),
                devicePixelRatio: 2.0,
              ),
              child: Localizations(
                locale: effectiveLocale,
                delegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                child: HomeAppWidgetView(
                  habits: habits,
                  heatmapDatasets: heatmapData,
                  isDark: isDark,
                  primaryColor: themeData.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );

      await HomeWidget.renderFlutterWidget(
        widgetToRender,
        key: habitWidgetImageKey,
        logicalSize: const Size(380, 480),
      );

      await HomeWidget.updateWidget(
        name: appWidgetProviderName,
        androidName: appWidgetProviderName,
        qualifiedAndroidName: androidQualifiedName,
      );
    } catch (e, stack) {
      debugPrint('Error updating home_widget: $e\n$stack');
    } finally {
      _isRendering = false;
    }
  }
}
