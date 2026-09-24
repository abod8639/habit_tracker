import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_utils.dart';
import '../../data/datasources/theme_storage.dart';
import '../../domain/entities/theme_entity.dart';
import '../../domain/usecases/save_theme_settings_usecase.dart';
import '../../domain/usecases/sync_theme_with_cloud_usecase.dart';
import '../../domain/usecases/upload_theme_settings_usecase.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/generated/l10n.dart';

class ThemeController extends GetxController {
  static const String defaultTheme = 'github_dark_green';

  final ThemeStorageService _storageService = Get.find<ThemeStorageService>();

  // Observable state
  late final Rx<ThemeMode> themeMode;
  late final RxString currentTheme;
  late final RxBool useCustomBackground;
  late final Rx<Color> customBackgroundColor;
  late final Rx<ThemeData> lightTheme;
  late final Rx<ThemeData> darkTheme;

  // Use Cases
  final SaveThemeSettingsUseCase _saveThemeSettingsUseCase = Get.find();
  final SyncThemeWithCloudUseCase _syncThemeWithCloudUseCase = Get.find();
  final UploadThemeSettingsUseCase _uploadThemeSettingsUseCase = Get.find();
  final FirestoreService _firestoreService = Get.find();

  // Getters
  List<String> get availableThemes => themeColors.keys.toList();

  ThemeController() {
    _initInitialTheme();
  }

  void _initInitialTheme() {
    try {
      final savedTheme = _storageService.getThemeName(defaultTheme);
      final themeKey =
          themeColors.containsKey(savedTheme) ? savedTheme : defaultTheme;
      currentTheme = themeKey.obs;

      final themeData = themeColors[themeKey]!;
      final isDark = ThemeUtils.isDarkTheme(themeData);

      final savedMode = _storageService.getThemeMode();
      final initialMode = savedMode == ThemeMode.system
          ? (isDark ? ThemeMode.dark : ThemeMode.light)
          : savedMode;
      themeMode = initialMode.obs;

      final isCustomBg = _storageService.getUseCustomBackground();
      useCustomBackground = isCustomBg.obs;

      final customBg = _storageService.getCustomBackgroundColor();
      customBackgroundColor = (customBg ?? Colors.transparent).obs;

      final customBgColor = isCustomBg ? customBg : null;
      lightTheme = ThemeUtils.buildThemeData(
        forceDark: false,
        colors: themeData,
        isDarkTheme: isDark,
        customBackground: customBgColor,
      ).obs;

      darkTheme = ThemeUtils.buildThemeData(
        forceDark: true,
        colors: themeData,
        isDarkTheme: isDark,
        customBackground: customBgColor,
      ).obs;
    } catch (_) {
      _applyDefaultThemeInitial();
    }
  }

  void _applyDefaultThemeInitial() {
    currentTheme = defaultTheme.obs;
    final themeData = themeColors[defaultTheme]!;
    final isDark = ThemeUtils.isDarkTheme(themeData);
    themeMode = (isDark ? ThemeMode.dark : ThemeMode.light).obs;
    useCustomBackground = false.obs;
    customBackgroundColor = Colors.transparent.obs;
    lightTheme = ThemeUtils.buildThemeData(
      forceDark: false,
      colors: themeData,
      isDarkTheme: isDark,
      customBackground: null,
    ).obs;
    darkTheme = ThemeUtils.buildThemeData(
      forceDark: true,
      colors: themeData,
      isDarkTheme: isDark,
      customBackground: null,
    ).obs;
  }

  @override
  void onInit() {
    super.onInit();
    if (_firestoreService.isUserLoggedIn) {
      _syncWithCloud();
    }
  }

  Future<void> _syncWithCloud() async {
    final result = await _syncThemeWithCloudUseCase();
    result.fold(
      (failure) =>
          debugPrint('Error syncing theme from cloud: ${failure.message}'),
      (entity) {
        if (entity != null) {
          currentTheme.value = entity.themeName;
          final themeData = themeColors[entity.themeName];
          final isDark = themeData != null
              ? ThemeUtils.isDarkTheme(themeData)
              : true;
          themeMode.value = entity.themeMode == ThemeMode.system
              ? (isDark ? ThemeMode.dark : ThemeMode.light)
              : entity.themeMode;
          useCustomBackground.value = entity.useCustomBackground;
          customBackgroundColor.value =
              entity.customBackgroundColor ?? Colors.transparent;
          _buildAndApply();
        }
      },
    );
  }

  Future<void> _saveCurrentSettings() async {
    final entity = ThemeEntity(
      themeName: currentTheme.value,
      themeMode: themeMode.value,
      useCustomBackground: useCustomBackground.value,
      customBackgroundColor: useCustomBackground.value
          ? customBackgroundColor.value
          : null,
    );

    final result = await _saveThemeSettingsUseCase(entity);
    result.fold(
      (failure) =>
          debugPrint('Error saving theme settings locally: ${failure.message}'),
      (_) {
        update();
        if (_firestoreService.isUserLoggedIn) {
          _uploadToCloud(entity);
        }
      },
    );
  }

  Future<void> _uploadToCloud(ThemeEntity entity) async {
    final result = await _uploadThemeSettingsUseCase(entity);
    result.fold(
      (failure) =>
          debugPrint('Error uploading theme settings: ${failure.message}'),
      (_) => debugPrint('Theme settings uploaded successfully'),
    );
  }

  void changeThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _buildAndApply();
    _saveCurrentSettings();
  }

  void changeCustomTheme(String themeName) {
    if (themeColors.containsKey(themeName)) {
      currentTheme.value = themeName;
      final isDark = ThemeUtils.isDarkTheme(themeColors[themeName]!);
      themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
      _buildAndApply();
      _saveCurrentSettings();
    } else {
      Get.snackbar(S.current.error, S.current.themeNotFound);
    }
  }

  void changeBackgroundColor(Color color) {
    customBackgroundColor.value = color;
    useCustomBackground.value = true;
    _buildAndApply();
    _saveCurrentSettings();
  }

  void resetBackgroundColor() {
    useCustomBackground.value = false;
    _buildAndApply();
    _saveCurrentSettings();
  }

  void _buildAndApply() {
    _buildBothThemes();
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(themeMode.value);
    Get.changeTheme(
      themeMode.value == ThemeMode.dark ? darkTheme.value : lightTheme.value,
    );
    update();
  }

  void _buildBothThemes() {
    final themeData = themeColors[currentTheme.value];
    if (themeData == null) return;

    final isDarkTheme = ThemeUtils.isDarkTheme(themeData);
    final customBg = useCustomBackground.value
        ? customBackgroundColor.value
        : null;

    lightTheme.value = ThemeUtils.buildThemeData(
      forceDark: false,
      colors: themeData,
      isDarkTheme: isDarkTheme,
      customBackground: customBg,
    );

    darkTheme.value = ThemeUtils.buildThemeData(
      forceDark: true,
      colors: themeData,
      isDarkTheme: isDarkTheme,
      customBackground: customBg,
    );
  }
}
