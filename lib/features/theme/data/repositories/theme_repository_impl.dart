import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import '../../domain/entities/theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';
import '../datasources/theme_remote_datasource.dart';
import '../models/theme_model.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource localDataSource;
  final ThemeRemoteDataSource remoteDataSource;

  ThemeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  static const Duration _localTimeout = Duration(seconds: 4);

  @override
  ThemeEntity getCachedThemeSettings() {
    return localDataSource.getCachedThemeSettings();
  }

  @override
  Future<Either<Failure, ThemeEntity>> getThemeSettings() {
    return NetworkErrorHandler.guard(() async {
      return await localDataSource.getThemeSettings().timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, void>> saveThemeSettings(ThemeEntity settings) {
    return NetworkErrorHandler.guard(() async {
      final model = ThemeModel.fromEntity(settings);
      await localDataSource.saveThemeSettings(model).timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, ThemeEntity?>> syncWithCloud() {
    return NetworkErrorHandler.guard(() async {
      final cloudSettings = await remoteDataSource.syncWithCloud();
      if (cloudSettings != null) {
        await localDataSource
            .saveThemeSettings(cloudSettings)
            .timeout(_localTimeout);
      }
      return cloudSettings;
    });
  }

  @override
  Future<Either<Failure, void>> uploadThemeToCloud(ThemeEntity settings) {
    return NetworkErrorHandler.guard(() async {
      final model = ThemeModel.fromEntity(settings);
      await remoteDataSource.uploadThemeToCloud(model);
    });
  }
}
