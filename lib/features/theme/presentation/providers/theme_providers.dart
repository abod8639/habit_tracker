import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_local_datasource.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_remote_datasource.dart';
import 'package:habit_tracker/features/theme/data/repositories/theme_repository_impl.dart';
import 'package:habit_tracker/features/theme/domain/entities/theme_entity.dart';
import 'package:habit_tracker/features/theme/domain/repositories/theme_repository.dart';
import 'package:habit_tracker/features/theme/domain/usecases/get_theme_settings_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/save_theme_settings_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/sync_theme_with_cloud_usecase.dart';
import 'package:habit_tracker/features/theme/domain/usecases/upload_theme_settings_usecase.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'theme_state.dart';

// Data Sources
final themeLocalDataSourceProvider = Provider<ThemeLocalDataSource>((ref) {
  final storage = ref.watch(themeStorageServiceProvider);
  return ThemeLocalDataSourceImpl(storage);
});

final themeRemoteDataSourceProvider = Provider<ThemeRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return ThemeRemoteDataSourceImpl(firestore);
});

// Repository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final local = ref.watch(themeLocalDataSourceProvider);
  final remote = ref.watch(themeRemoteDataSourceProvider);
  return ThemeRepositoryImpl(
    localDataSource: local,
    remoteDataSource: remote,
  );
});

// Use Cases
final getThemeSettingsUseCaseProvider = Provider<GetThemeSettingsUseCase>((
  ref,
) {
  return GetThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
});

final saveThemeSettingsUseCaseProvider = Provider<SaveThemeSettingsUseCase>((
  ref,
) {
  return SaveThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
});

final syncThemeWithCloudUseCaseProvider = Provider<SyncThemeWithCloudUseCase>((
  ref,
) {
  return SyncThemeWithCloudUseCase(ref.watch(themeRepositoryProvider));
});

final uploadThemeSettingsUseCaseProvider = Provider<UploadThemeSettingsUseCase>(
  (ref) {
    return UploadThemeSettingsUseCase(ref.watch(themeRepositoryProvider));
  },
);

// Theme Notifier
class ThemeNotifier extends Notifier<ThemeState> {
  static const String defaultTheme = 'github_dark_green';

  final Map<String, ThemeData> _lightThemeCache = {};
  final Map<String, ThemeData> _darkThemeCache = {};
  Timer? _homeWidgetDebounceTimer;
  bool _isDisposed = false;

  @override
  ThemeState build() {
    _isDisposed = false;

    ref.onDispose(() {
      _isDisposed = true;
      _homeWidgetDebounceTimer?.cancel();
      _homeWidgetDebounceTimer = null;
    });

    final getSettings = ref.watch(getThemeSettingsUseCaseProvider);
    final firestore = ref.watch(firestoreServiceProvider);

    ThemeState initialState;
    try {
      final cachedSettings = getSettings.getCached();
      final themeKey = themeColors.containsKey(cachedSettings.themeName)
          ? cachedSettings.themeName
          : defaultTheme;
      final themeData = themeColors[themeKey]!;
      final isDark = ThemeUtils.isDarkTheme(themeData);
      final initialMode = cachedSettings.themeMode == ThemeMode.system
          ? (isDark ? ThemeMode.dark : ThemeMode.light)
          : cachedSettings.themeMode;
      final customBg = cachedSettings.useCustomBackground
          ? cachedSettings.customBackgroundColor
          : null;

      initialState = ThemeState(
        themeMode: initialMode,
        currentTheme: themeKey,
        useCustomBackground: cachedSettings.useCustomBackground,
        customBackgroundColor:
            cachedSettings.customBackgroundColor ?? Colors.transparent,
        lightTheme: _buildThemeData(themeKey, false, customBg),
        darkTheme: _buildThemeData(themeKey, true, customBg),
      );
    } catch (_) {
      final themeData = themeColors[defaultTheme]!;
      final isDark = ThemeUtils.isDarkTheme(themeData);
      initialState = ThemeState(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        currentTheme: defaultTheme,
        useCustomBackground: false,
        customBackgroundColor: Colors.transparent,
        lightTheme: _buildThemeData(defaultTheme, false, null),
        darkTheme: _buildThemeData(defaultTheme, true, null),
      );
    }

    if (firestore.isUserLoggedIn) {
      Future.microtask(() => syncWithCloud());
    }

    return initialState;
  }

  ThemeData _buildThemeData(String themeKey, bool forceDark, Color? customBg) {
    final themeData = themeColors[themeKey] ?? themeColors[defaultTheme]!;
    final isDark = ThemeUtils.isDarkTheme(themeData);
    final cache = forceDark ? _darkThemeCache : _lightThemeCache;
    final cacheKey = '${themeKey}_${forceDark}_${customBg?.toARGB32()}';

    return cache.putIfAbsent(
      cacheKey,
      () => ThemeUtils.buildThemeData(
        forceDark: forceDark,
        colors: themeData,
        isDarkTheme: isDark,
        customBackground: customBg,
      ),
    );
  }

  Future<void> syncWithCloud() async {
    if (_isDisposed) return;
    state = state.copyWith(isSyncing: true, clearFailure: true);

    final syncUseCase = ref.read(syncThemeWithCloudUseCaseProvider);
    final result = await syncUseCase();
    if (_isDisposed) return;

    result.fold(
      (failure) {
        if (!_isDisposed) {
          state = state.copyWith(
            isSyncing: false,
            activeFailure: failure,
          );
        }
      },
      (entity) {
        if (entity != null) {
          final themeData = themeColors[entity.themeName];
          final isDark = themeData != null
              ? ThemeUtils.isDarkTheme(themeData)
              : true;
          final mode = entity.themeMode == ThemeMode.system
              ? (isDark ? ThemeMode.dark : ThemeMode.light)
              : entity.themeMode;
          final customBg = entity.useCustomBackground
              ? entity.customBackgroundColor
              : null;

          final hasChanged =
              state.currentTheme != entity.themeName ||
              state.themeMode != mode ||
              state.useCustomBackground != entity.useCustomBackground ||
              state.customBackgroundColor !=
                  (entity.customBackgroundColor ?? Colors.transparent);

          if (!hasChanged) {
            if (!_isDisposed) {
              state = state.copyWith(isSyncing: false, clearFailure: true);
            }
            return;
          }

          _lightThemeCache.clear();
          _darkThemeCache.clear();

          if (!_isDisposed) {
            state = state.copyWith(
              currentTheme: entity.themeName,
              themeMode: mode,
              useCustomBackground: entity.useCustomBackground,
              customBackgroundColor:
                  entity.customBackgroundColor ?? Colors.transparent,
              lightTheme: _buildThemeData(entity.themeName, false, customBg),
              darkTheme: _buildThemeData(entity.themeName, true, customBg),
              isSyncing: false,
              clearFailure: true,
            );
            _updateHomeWidget();
          }
        } else {
          final firestore = ref.read(firestoreServiceProvider);
          if (firestore.isUserLoggedIn && !_isDisposed) {
            final uploadUseCase = ref.read(uploadThemeSettingsUseCaseProvider);
            uploadUseCase(
              ThemeEntity(
                themeName: state.currentTheme,
                themeMode: state.themeMode,
                useCustomBackground: state.useCustomBackground,
                customBackgroundColor: state.useCustomBackground
                    ? state.customBackgroundColor
                    : null,
              ),
            );
            state = state.copyWith(isSyncing: false, clearFailure: true);
          }
        }
      },
    );
  }

  void _updateHomeWidget() {
    _homeWidgetDebounceTimer?.cancel();
    _homeWidgetDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed) return;
      try {
        final homeWidget = ref.read(homeWidgetServiceProvider);
        final habitState = ref.read(habitNotifierProvider);
        final isDark = state.themeMode == ThemeMode.dark;
        final activeTheme = isDark ? state.darkTheme : state.lightTheme;
        homeWidget.updateWidget(
          habits: habitState.habits,
          heatmapData: habitState.heatmapDateSet,
          overrideTheme: activeTheme,
          overrideIsDark: isDark,
        );
      } catch (e) {
        debugPrint('Error updating home widget on theme change: $e');
      }
    });
  }

  void changeThemeMode(ThemeMode mode) {
    if (state.themeMode == mode || _isDisposed) return;
    state = state.copyWith(themeMode: mode);
    _saveCurrentSettings();
  }

  void changeCustomTheme(String themeName) {
    if (state.currentTheme == themeName || _isDisposed) return;
    if (themeColors.containsKey(themeName)) {
      final isDark = ThemeUtils.isDarkTheme(themeColors[themeName]!);
      final mode = isDark ? ThemeMode.dark : ThemeMode.light;
      final customBg = state.useCustomBackground
          ? state.customBackgroundColor
          : null;

      state = state.copyWith(
        currentTheme: themeName,
        themeMode: mode,
        lightTheme: _buildThemeData(themeName, false, customBg),
        darkTheme: _buildThemeData(themeName, true, customBg),
      );
      _saveCurrentSettings();
    }
  }

  void changeBackgroundColor(Color color) {
    if (_isDisposed) return;
    _lightThemeCache.clear();
    _darkThemeCache.clear();
    state = state.copyWith(
      useCustomBackground: true,
      customBackgroundColor: color,
      lightTheme: _buildThemeData(state.currentTheme, false, color),
      darkTheme: _buildThemeData(state.currentTheme, true, color),
    );
    _saveCurrentSettings();
  }

  void resetBackgroundColor() {
    if (_isDisposed) return;
    _lightThemeCache.clear();
    _darkThemeCache.clear();
    state = state.copyWith(
      useCustomBackground: false,
      lightTheme: _buildThemeData(state.currentTheme, false, null),
      darkTheme: _buildThemeData(state.currentTheme, true, null),
    );
    _saveCurrentSettings();
  }

  Future<void> _saveCurrentSettings() async {
    if (_isDisposed) return;
    final entity = ThemeEntity(
      themeName: state.currentTheme,
      themeMode: state.themeMode,
      useCustomBackground: state.useCustomBackground,
      customBackgroundColor: state.useCustomBackground
          ? state.customBackgroundColor
          : null,
    );

    // Immediately trigger Home Widget refresh with new theme
    _updateHomeWidget();

    final saveUseCase = ref.read(saveThemeSettingsUseCaseProvider);
    final result = await saveUseCase(entity);
    if (_isDisposed) return;

    result.fold(
      (failure) {
        if (!_isDisposed) {
          state = state.copyWith(activeFailure: failure);
        }
      },
      (_) {
        final firestore = ref.read(firestoreServiceProvider);
        if (firestore.isUserLoggedIn && !_isDisposed) {
          final uploadUseCase = ref.read(uploadThemeSettingsUseCaseProvider);
          uploadUseCase(entity);
        }
      },
    );
  }

  Future<void> retry() => syncWithCloud();
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

/// Exposes active [Failure] from theme operations for SnackBar or banner notifications.
final themeFailureProvider = Provider<Failure?>((ref) {
  return ref.watch(themeNotifierProvider.select((s) => s.activeFailure));
});
