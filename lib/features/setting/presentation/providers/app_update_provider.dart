import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/setting/data/datasources/app_update_remote_datasource.dart';
import 'package:habit_tracker/features/setting/data/repositories/app_update_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';
import 'package:habit_tracker/features/setting/domain/repositories/app_update_repository.dart';
import 'package:habit_tracker/features/setting/domain/usecases/check_app_update_usecase.dart';

final appUpdateRemoteDataSourceProvider = Provider<AppUpdateRemoteDataSource>((
  ref,
) {
  final client = ref.watch(httpClientProvider);
  return AppUpdateRemoteDataSourceImpl(client: client);
});

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  final remote = ref.watch(appUpdateRemoteDataSourceProvider);
  return AppUpdateRepositoryImpl(remoteDataSource: remote);
});

final checkAppUpdateUseCaseProvider = Provider<CheckAppUpdateUseCase>((ref) {
  final repo = ref.watch(appUpdateRepositoryProvider);
  return CheckAppUpdateUseCase(repo);
});

/// Evaluates if a newer release exists on GitHub.
/// Returns [AppUpdateInfo] only when [hasUpdate] is true, otherwise returns `null`.
final appUpdateInfoProvider = FutureProvider.autoDispose<AppUpdateInfo?>((
  ref,
) async {
  final useCase = ref.watch(checkAppUpdateUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => null,
    (info) => info.hasUpdate ? info : null,
  );
});
