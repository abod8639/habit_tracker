import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';

abstract class AppUpdateRepository {
  /// Checks GitHub for the latest release and compares with the installed version.
  Future<Either<Failure, AppUpdateInfo>> checkForUpdate({String? currentVersion});
}
