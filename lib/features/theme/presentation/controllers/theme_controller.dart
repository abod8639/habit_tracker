import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_utils.dart';
import '../../domain/entities/theme_entity.dart';
import '../../domain/usecases/get_theme_settings_usecase.dart';
import '../../domain/usecases/save_theme_settings_usecase.dart';
import '../../domain/usecases/sync_theme_with_cloud_usecase.dart';
import '../../domain/usecases/upload_theme_settings_usecase.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';

class ThemeController extends GetxController {
  static const String defaultTheme = 'github_dark_green';

  // Observable state
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString currentTheme = defaultTheme.obs;
  final RxBool useCustomBackground = false.obs;
  final Rx<Color> customBackgroundColor = Colors.transparent.obs;
  final Rx<ThemeData> lightTheme = ThemeData.light().obs;
  final Rx<ThemeData> darkTheme = ThemeData.dark().obs;

  // Use Cases
  final GetThemeSettingsUseCase _getThemeSettingsUseCase = Get.find();
  final SaveThemeSettingsUseCase _saveThemeSettingsUseCase = Get.find();
  final SyncThemeWithCloudUseCase _syncThemeWithCloudUseCase = Get.find();
  final UploadThemeSettingsUseCase _uploadThemeSettingsUseCase = Get.find();
  final FirestoreService _firestoreService = Get.find();

  // Getters
  List<String> get availableThemes => themeColors.keys.toList();

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      await _loadSavedTheme();
      if (_firestoreService.isUserLoggedIn) {
        _syncWithCloud();
      }
    } catch (e) {
      // debugPrint('Error initializing theme: $e');
      _setDefaultTheme();
    }
  }

  Future<void> _loadSavedTheme() async {
    final result = await _getThemeSettingsUseCase();
    result.fold(
      (failure) {
        // debugPrint('Error loading saved theme: ${failure.message}');
        _setDefaultTheme();
      },
      (entity) {
        currentTheme.value = entity.themeName;
        themeMode.value = entity.themeMode;
        useCustomBackground.value = entity.useCustomBackground;
        customBackgroundColor.value = entity.customBackgroundColor ?? Colors.transparent;
        _buildAndApply();
      },
    );
  }

  Future<void> _syncWithCloud() async {
    final result = await _syncThemeWithCloudUseCase();
    result.fold(
      (failure) =>  debugPrint('Error syncing theme from cloud: ${failure.message}'),
      (entity) {
        if (entity != null) {
          currentTheme.value = entity.themeName;
          themeMode.value = entity.themeMode;
          useCustomBackground.value = entity.useCustomBackground;
          customBackgroundColor.value = entity.customBackgroundColor ?? Colors.transparent;
          _buildAndApply();
        }
      },
    );
  }

  void _setDefaultTheme() {
    currentTheme.value = defaultTheme;
    themeMode.value = ThemeMode.system;
    useCustomBackground.value = false;
    customBackgroundColor.value = Colors.transparent;
    _buildAndApply();
  }

  Future<void> _saveCurrentSettings() async {
    final entity = ThemeEntity(
      themeName: currentTheme.value,
      themeMode: themeMode.value,
      useCustomBackground: useCustomBackground.value,
      customBackgroundColor: useCustomBackground.value ? customBackgroundColor.value : null,
    );
    
    final result = await _saveThemeSettingsUseCase(entity);
    result.fold(
      (failure) =>  debugPrint('Error saving theme settings locally: ${failure.message}'),
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
      (failure) =>  debugPrint('Error uploading theme settings: ${failure.message}'),
      (_) =>  debugPrint('Theme settings uploaded successfully'),
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
      _buildAndApply();
      _saveCurrentSettings();
    } else {
      Get.snackbar('Error', 'Theme not found');
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
  }

  void _buildBothThemes() {
    final themeData = themeColors[currentTheme.value];
    if (themeData == null) return;

    final isDarkTheme = ThemeUtils.isDarkTheme(themeData);
    final customBg = useCustomBackground.value ? customBackgroundColor.value : null;

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
