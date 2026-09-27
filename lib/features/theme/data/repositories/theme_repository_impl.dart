import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
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

  @override
  ThemeEntity getCachedThemeSettings() {
    return localDataSource.getCachedThemeSettings();
  }

  @override
  Future<Either<Failure, ThemeEntity>> getThemeSettings() async {
    try {
      final settings = await localDataSource.getThemeSettings();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeSettings(ThemeEntity settings) async {
    try {
      final model = ThemeModel.fromEntity(settings);
      await localDataSource.saveThemeSettings(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ThemeEntity?>> syncWithCloud() async {
    try {
      final cloudSettings = await remoteDataSource.syncWithCloud();
      if (cloudSettings != null) {
        await localDataSource.saveThemeSettings(cloudSettings);
      }
      return Right(cloudSettings);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> uploadThemeToCloud(ThemeEntity settings) async {
    try {
      final model = ThemeModel.fromEntity(settings);
      await remoteDataSource.uploadThemeToCloud(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
