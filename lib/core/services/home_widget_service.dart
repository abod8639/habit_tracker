import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home_app_widget/home_app_widget_view.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/generated/l10n.dart';

class _WidgetRenderRequest {
  final List<HabitEntity> habits;
  final Map<DateTime, int> heatmapData;
  final ThemeData? overrideTheme;
  final bool? overrideIsDark;

  const _WidgetRenderRequest({
    required this.habits,
    required this.heatmapData,
    this.overrideTheme,
    this.overrideIsDark,
  });
}

/// Service responsible for managing and synchronizing the mobile home screen widget
/// via `home_widget`. Renders off-screen snapshots of [HomeAppWidgetView] and triggers
/// OS-level widget refreshes.
class HomeWidgetService {
  static const String appWidgetProviderName = 'HabitAppWidgetProvider';
  static const String habitWidgetImageKey = 'habit_widget_image';
  static const String androidQualifiedName =
      'com.example.habit_tracker.HabitAppWidgetProvider';

  bool _isRendering = false;
  _WidgetRenderRequest? _pendingRequest;

  /// Renders the Flutter widget off-screen into an image and updates the native widget.
  Future<void> updateWidget({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
    ThemeData? overrideTheme,
    bool? overrideIsDark,
  }) async {
    // home_widget only runs on Android and iOS
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    if (_isRendering) {
      _pendingRequest = _WidgetRenderRequest(
        habits: habits,
        heatmapData: heatmapData,
        overrideTheme: overrideTheme,
        overrideIsDark: overrideIsDark,
      );
      return;
    }
    _isRendering = true;

    try {
      await _performRender(
        habits: habits,
        heatmapData: heatmapData,
        overrideTheme: overrideTheme,
        overrideIsDark: overrideIsDark,
      );
    } finally {
      _isRendering = false;
      if (_pendingRequest != null) {
        final next = _pendingRequest!;
        _pendingRequest = null;
        updateWidget(
          habits: next.habits,
          heatmapData: next.heatmapData,
          overrideTheme: next.overrideTheme,
          overrideIsDark: next.overrideIsDark,
        );
      }
    }
  }

  Future<void> _performRender({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
    ThemeData? overrideTheme,
    bool? overrideIsDark,
  }) async {
    try {
      final themeStorage = AppInitializer.themeStorage;
      final langStorage = AppInitializer.langStorage;
      final themeName = themeStorage.getThemeName('github_dark_green');
      final colors =
          themeColors[themeName] ?? themeColors['github_dark_green']!;
      final bool isThemeDark = ThemeUtils.isDarkTheme(colors);

      final themeMode = themeStorage.getThemeMode();
      final isDark =
          overrideIsDark ??
          (themeMode == ThemeMode.system
              ? (PlatformDispatcher.instance.platformBrightness ==
                        Brightness.dark ||
                    isThemeDark)
              : themeMode == ThemeMode.dark);

      final customBg = themeStorage.getUseCustomBackground()
          ? themeStorage.getCustomBackgroundColor()
          : null;

      final themeData =
          overrideTheme ??
          ThemeUtils.buildThemeData(
            forceDark: isDark,
            colors: colors,
            isDarkTheme: isDark,
            customBackground: customBg,
          );

      final langCode = langStorage.getCurrentLanguage();
      final effectiveLocale = (langCode == 'ar')
          ? const Locale('ar')
          : (langCode == 'en'
                ? const Locale('en')
                : (PlatformDispatcher.instance.locale.languageCode == 'ar'
                      ? const Locale('ar')
                      : const Locale('en')));

      // Ensure active localization messages are fully loaded for effectiveLocale
      await S.load(effectiveLocale);

      final widgetToRender = Directionality(
        textDirection: effectiveLocale.languageCode == 'en'
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Theme(
          data: themeData,
          child: Material(
            color: Colors.transparent,
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 310),
                devicePixelRatio: 2.5,
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
        logicalSize: const Size(360, 310),
      );

      await HomeWidget.updateWidget(
        name: appWidgetProviderName,
        androidName: appWidgetProviderName,
        qualifiedAndroidName: androidQualifiedName,
      );
    } catch (e, stack) {
      debugPrint('Error updating home_widget: $e\n$stack');
    }
  }
}
