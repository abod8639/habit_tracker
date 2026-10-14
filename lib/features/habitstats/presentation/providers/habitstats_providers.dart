import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';
import 'package:habit_tracker/features/habitstats/domain/repositories/habit_stats_repository.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_individual_habit_trends_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_overall_stats_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_overall_trend_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_today_habits_summary_usecase.dart';

// Data Source
final habitStatsLocalDataSourceProvider = Provider<HabitStatsLocalDataSource>((ref) {
  final habitRepo = ref.watch(habitRepositoryProvider);
  return HabitStatsLocalDataSource(
    myBox: Hive.box(HabitStorage.boxName),
    habitRepository: habitRepo,
  );
});

// Repository
final habitStatsRepositoryProvider = Provider<HabitStatsRepository>((ref) {
  final local = ref.watch(habitStatsLocalDataSourceProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  return HabitStatsRepositoryImpl(
    localDataSource: local,
    habitRepository: habitRepo,
  );
});

// Use Cases
final getOverallStatsUseCaseProvider = Provider<GetOverallStatsUseCase>((ref) {
  final repo = ref.watch(habitStatsRepositoryProvider);
  return GetOverallStatsUseCase(repo);
});

final getOverallTrendUseCaseProvider = Provider<GetOverallTrendUseCase>((ref) {
  final repo = ref.watch(habitStatsRepositoryProvider);
  return GetOverallTrendUseCase(repo);
});

final getIndividualHabitTrendsUseCaseProvider =
    Provider<GetIndividualHabitTrendsUseCase>((ref) {
  final repo = ref.watch(habitStatsRepositoryProvider);
  return GetIndividualHabitTrendsUseCase(repo);
});

final getTodayHabitsSummaryUseCaseProvider =
    Provider<GetTodayHabitsSummaryUseCase>((ref) {
  final repo = ref.watch(habitStatsRepositoryProvider);
  return GetTodayHabitsSummaryUseCase(repo);
});
