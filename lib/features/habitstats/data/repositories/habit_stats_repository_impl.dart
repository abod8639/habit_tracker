import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import '../../domain/entities/habit_stats_bundle_entity.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/entities/trend_point_entity.dart';
import '../../domain/repositories/habit_stats_repository.dart';
import '../datasources/habit_stats_local_datasource.dart';
import '../models/habit_stats_model.dart';

class HabitStatsRepositoryImpl implements HabitStatsRepository {
  final HabitStatsLocalDataSource localDataSource;
  final HabitRepository habitRepository;

  HabitStatsRepositoryImpl({
    required this.localDataSource,
    required this.habitRepository,
  });

  @override
  HabitStatsEntity? getCachedStats() {
    return localDataSource.getCachedStats();
  }

  @override
  Future<Either<Failure, HabitStatsBundleEntity>> getCompleteStatsBundle(
    int days,
  ) async {
    try {
      final results = await Future.wait([
        habitRepository.getHabits(),
        habitRepository.getHeatmapData(),
        habitRepository.getHabitHistoryMap(days),
      ]);

      final habitsEither = results[0] as Either<Failure, List<HabitEntity>>;
      final heatmapEither = results[1] as Either<Failure, Map<DateTime, int>>;
      final historyMapEither =
          results[2] as Either<Failure, Map<String, Map<DateTime, bool>>>;

      return await habitsEither.fold(
        (failure) => Left(failure),
        (habits) async {
          final heatmapData = heatmapEither.fold(
            (_) => <DateTime, int>{},
            (data) => data,
          );
          final historyMap = historyMapEither.fold(
            (_) => <String, Map<DateTime, bool>>{},
            (data) => data,
          );

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // 1. Calculate overall stats & streak
          final int totalHabits = habits.length;
          final int completedHabits = habits.where((h) => h.isCompleted).length;
          final double completionRate = totalHabits > 0
              ? (completedHabits / totalHabits) * 100
              : 0.0;

          int streak = 0;
          final bool isTodayCompleted =
              completedHabits > 0 || (heatmapData[today] ?? 0) > 0;
          if (isTodayCompleted) {
            streak++;
          }

          int daysBack = 1;
          while (true) {
            final checkDay = DateTime(
              today.year,
              today.month,
              today.day - daysBack,
            );
            final strength = heatmapData[checkDay] ?? 0;
            if (strength > 0) {
              streak++;
              daysBack++;
            } else {
              break;
            }
          }

          // Calculate bestStreak
          final activeDates = <DateTime>{};
          heatmapData.forEach((date, strength) {
            if (strength > 0) {
              activeDates.add(DateTime(date.year, date.month, date.day));
            }
          });
          if (completedHabits > 0) {
            activeDates.add(today);
          }

          int maxStreak = 0;
          if (activeDates.isNotEmpty) {
            final sortedDates = activeDates.toList()..sort();
            int currentRun = 0;
            DateTime? prevDate;
            for (final date in sortedDates) {
              if (prevDate == null) {
                currentRun = 1;
              } else {
                final nextDay = DateTime(
                  prevDate.year,
                  prevDate.month,
                  prevDate.day + 1,
                );
                if (date.isAtSameMomentAs(nextDay)) {
                  currentRun++;
                } else if (date.isAfter(nextDay)) {
                  currentRun = 1;
                }
              }
              if (currentRun > maxStreak) {
                maxStreak = currentRun;
              }
              prevDate = date;
            }
          }

          final overallStats = HabitStatsEntity(
            totalHabits: totalHabits,
            completedHabits: completedHabits,
            completionRate: completionRate,
            streak: streak,
            bestStreak: maxStreak,
          );

          // Save to local cache asynchronously
          await localDataSource.cacheStats(
            HabitStatsModel.fromEntity(overallStats),
          );

          // 2. Calculate overall trend
          const maxStrength = 10;
          final List<TrendPointEntity> overallTrend = [];
          for (int i = 0; i < days; i++) {
            final normalizedDate = DateTime(
              now.year,
              now.month,
              now.day - (days - 1 - i),
            );
            final strength = heatmapData[normalizedDate] ?? 0;
            final percentage = (strength / maxStrength).clamp(0.0, 1.0);
            overallTrend.add(
              TrendPointEntity(
                x: i.toDouble(),
                y: percentage,
                date: normalizedDate,
              ),
            );
          }

          // 3. Calculate individual trends
          final Map<String, List<TrendPointEntity>> individualTrends = {};
          for (var habit in habits) {
            final List<TrendPointEntity> spots = [];
            final habitHistory =
                historyMap[habit.id] ?? historyMap[habit.name] ?? {};

            for (int i = 0; i < days; i++) {
              final normalizedDate = DateTime(
                today.year,
                today.month,
                today.day - (days - 1 - i),
              );

              final bool? completed = habitHistory[normalizedDate];
              bool isCompleted = completed ?? false;
              if (completed == null && i == days - 1) {
                isCompleted = habit.isCompleted;
              }

              spots.add(
                TrendPointEntity(
                  x: i.toDouble(),
                  y: isCompleted ? 1.0 : 0.0,
                  date: normalizedDate,
                ),
              );
            }
            individualTrends[habit.name] = spots;
            // individualTrends[habit.id] = spots;
          }

          return Right(
            HabitStatsBundleEntity(
              overallStats: overallStats,
              overallTrend: overallTrend,
              individualTrends: individualTrends,
              todayHabits: habits,
            ),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HabitStatsEntity>> getOverallStats() async {
    final bundleResult = await getCompleteStatsBundle(7);
    return bundleResult.map((bundle) => bundle.overallStats);
  }

  @override
  Future<Either<Failure, List<TrendPointEntity>>> getOverallTrendData(
    int days,
  ) async {
    final bundleResult = await getCompleteStatsBundle(days);
    return bundleResult.map((bundle) => bundle.overallTrend);
  }

  @override
  Future<Either<Failure, Map<String, List<TrendPointEntity>>>>
  getIndividualHabitTrends(int days) async {
    final bundleResult = await getCompleteStatsBundle(days);
    return bundleResult.map((bundle) => bundle.individualTrends);
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getTodayHabitsSummary() async {
    return habitRepository.getHabits();
  }
}
