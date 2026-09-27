import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/theme_entity.dart';

abstract class ThemeRepository {
  ThemeEntity getCachedThemeSettings();
  Future<Either<Failure, ThemeEntity>> getThemeSettings();
  Future<Either<Failure, void>> saveThemeSettings(ThemeEntity settings);
  Future<Either<Failure, ThemeEntity?>> syncWithCloud();
  Future<Either<Failure, void>> uploadThemeToCloud(ThemeEntity settings);
}
