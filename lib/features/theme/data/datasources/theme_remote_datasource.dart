import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import '../models/theme_model.dart';

abstract class ThemeRemoteDataSource {
  Future<ThemeModel?> syncWithCloud();
  Future<void> uploadThemeToCloud(ThemeModel settings);
}

class ThemeRemoteDataSourceImpl implements ThemeRemoteDataSource {
  final FirestoreService firestoreService;

  ThemeRemoteDataSourceImpl(this.firestoreService);

  static const Duration _remoteTimeout = Duration(seconds: 10);
  static const Duration _isolateTimeout = Duration(seconds: 4);

  @override
  Future<ThemeModel?> syncWithCloud() async {
    final cloudTheme = await firestoreService.downloadTheme().timeout(
      _remoteTimeout,
      onTimeout: () {
        throw const TimeoutAppException('Cloud theme download timed out');
      },
    );

    if (cloudTheme != null) {
      if (cloudTheme.length > 5) {
        return await compute(_isolateParseThemeModel, cloudTheme).timeout(
          _isolateTimeout,
          onTimeout: () => ThemeModel.fromJson(cloudTheme),
        );
      }
      return ThemeModel.fromJson(cloudTheme);
    }
    return null;
  }

  @override
  Future<void> uploadThemeToCloud(ThemeModel settings) async {
    await firestoreService
        .uploadTheme(
          settings.themeName,
          settings.themeMode,
          settings.useCustomBackground,
          settings.customBackgroundColor,
        )
        .timeout(
          _remoteTimeout,
          onTimeout: () {
            throw const TimeoutAppException('Cloud theme upload timed out');
          },
        );
  }

  static ThemeModel _isolateParseThemeModel(Map<String, dynamic> data) {
    return ThemeModel.fromJson(data);
  }
}
