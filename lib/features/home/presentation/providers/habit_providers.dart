import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/clear_local_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/edit_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_completion_status_for_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_heatmap_data_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_start_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/increment_day_count_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reorder_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/toggle_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_color_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_order_usecase.dart';

// Data Sources
final habitVaultDataSourceProvider = Provider<HabitOfflineVaultDataSource>((ref) {
  final vaultBox = Hive.isBoxOpen(HabitStorage.backupVaultBox)
      ? Hive.box(HabitStorage.backupVaultBox)
      : Hive.box(HabitStorage.boxName);
  return HabitOfflineVaultDataSource(vaultBox);
});

final habitLocalDataSourceProvider = Provider<HabitLocalDataSource>((ref) {
  final box = Hive.box(HabitStorage.boxName);
  final vaultDataSource = ref.watch(habitVaultDataSourceProvider);
  return HabitLocalDataSource(box, vaultDataSource: vaultDataSource);
});

// Repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final localDataSource = ref.watch(habitLocalDataSourceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final vaultDataSource = ref.watch(habitVaultDataSourceProvider);
  return HabitRepositoryImpl(
    localDataSource: localDataSource,
    firestoreService: firestoreService,
    vaultDataSource: vaultDataSource,
  );
});

// Use Cases
final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>((ref) {
  return GetHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final addHabitUseCaseProvider = Provider<AddHabitUseCase>((ref) {
  return AddHabitUseCase(ref.watch(habitRepositoryProvider));
});

final addMultipleHabitsUseCaseProvider = Provider<AddMultipleHabitsUseCase>((ref) {
  return AddMultipleHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final editHabitUseCaseProvider = Provider<EditHabitUseCase>((ref) {
  return EditHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  return DeleteHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteMultipleHabitsUseCaseProvider = Provider<DeleteMultipleHabitsUseCase>((ref) {
  return DeleteMultipleHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final toggleHabitUseCaseProvider = Provider<ToggleHabitUseCase>((ref) {
  return ToggleHabitUseCase(ref.watch(habitRepositoryProvider));
});

final reorderHabitsUseCaseProvider = Provider<ReorderHabitsUseCase>((ref) {
  return ReorderHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final getHeatmapDataUseCaseProvider = Provider<GetHeatmapDataUseCase>((ref) {
  return GetHeatmapDataUseCase(ref.watch(habitRepositoryProvider));
});

final isUserLoggedInUseCaseProvider = Provider<IsUserLoggedInUseCase>((ref) {
  return IsUserLoggedInUseCase(ref.watch(habitRepositoryProvider));
});

final updateHabitColorUseCaseProvider = Provider<UpdateHabitColorUseCase>((ref) {
  return UpdateHabitColorUseCase(repository: ref.watch(habitRepositoryProvider));
});

final updateHabitOrderUseCaseProvider = Provider<UpdateHabitOrderUseCase>((ref) {
  return UpdateHabitOrderUseCase(repository: ref.watch(habitRepositoryProvider));
});

final resetDailyHabitsUseCaseProvider = Provider<ResetDailyHabitsUseCase>((ref) {
  return ResetDailyHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final getCompletionStatusForDateUseCaseProvider =
    Provider<GetCompletionStatusForDateUseCase>((ref) {
  return GetCompletionStatusForDateUseCase(ref.watch(habitRepositoryProvider));
});

final getStartDateUseCaseProvider = Provider<GetStartDateUseCase>((ref) {
  return GetStartDateUseCase(ref.watch(habitRepositoryProvider));
});

final incrementDayCountUseCaseProvider = Provider<IncrementDayCountUseCase>((ref) {
  return IncrementDayCountUseCase(ref.watch(habitRepositoryProvider));
});

final clearLocalHabitsUseCaseProvider = Provider<ClearLocalHabitsUseCase>((ref) {
  return ClearLocalHabitsUseCase(ref.watch(habitRepositoryProvider));
});
