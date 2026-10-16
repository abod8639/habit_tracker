import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../entities/habit_stats_bundle_entity.dart';
import '../entities/habit_stats_entity.dart';
import '../entities/trend_point_entity.dart';

abstract class HabitStatsRepository {
  /// Fetches aggregated stats bundle in a single unified pass.
  Future<Either<Failure, HabitStatsBundleEntity>> getCompleteStatsBundle(
    int days,
  );

  /// Synchronously or quickly retrieves cached stats if available.
  HabitStatsEntity? getCachedStats();

  /// Fetches overall completion stats and streaks.
  Future<Either<Failure, HabitStatsEntity>> getOverallStats();

  /// Fetches overall trend line spots for [days] range.
  Future<Either<Failure, List<TrendPointEntity>>> getOverallTrendData(int days);

  /// Fetches per-habit individual trend spots for [days] range.
  Future<Either<Failure, Map<String, List<TrendPointEntity>>>>
  getIndividualHabitTrends(int days);

  /// Fetches summary of today's habits.
  Future<Either<Failure, List<HabitEntity>>> getTodayHabitsSummary();
}
