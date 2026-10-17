import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';
import 'package:habit_tracker/features/setting/domain/repositories/app_update_repository.dart';

class CheckAppUpdateUseCase {
  final AppUpdateRepository repository;

  CheckAppUpdateUseCase(this.repository);

  Future<Either<Failure, AppUpdateInfo>> call({String? currentVersion}) {
    return repository.checkForUpdate(currentVersion: currentVersion);
  }
}
