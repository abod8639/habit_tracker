import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import '../../domain/entities/habit_stats_bundle_entity.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/entities/trend_point_entity.dart';
import '../../domain/repositories/habit_stats_repository.dart';
import '../datasources/habit_stats_local_datasource.dart';
import '../datasources/habit_stats_payload_processor.dart';
import '../models/habit_stats_model.dart';

class HabitStatsRepositoryImpl implements HabitStatsRepository {
  final HabitStatsLocalDataSource localDataSource;
  final HabitRepository habitRepository;

  static const Duration requestTimeout = Duration(seconds: 15);

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
  ) {
    return NetworkErrorHandler.guard(() async {
      final results = await Future.wait([
        habitRepository.getHabits(),
        habitRepository.getHeatmapData(),
        habitRepository.getHabitHistoryMap(days),
      ]).timeout(
        requestTimeout,
        onTimeout: () => throw const TimeoutAppException(
          'Habit stats calculation request timed out. Please try again.',
        ),
      );

      final habitsEither = results[0] as Either<Failure, List<HabitEntity>>;
      final heatmapEither = results[1] as Either<Failure, Map<DateTime, int>>;
      final historyMapEither =
          results[2] as Either<Failure, Map<String, Map<DateTime, bool>>>;

      return habitsEither.fold(
        (failure) => throw failure,
        (habits) async {
          final heatmapData = heatmapEither.fold(
            (_) => <DateTime, int>{},
            (data) => data,
          );
          final historyMap = historyMapEither.fold(
            (_) => <String, Map<DateTime, bool>>{},
            (data) => data,
          );

          final bundle = await HabitStatsPayloadProcessor.calculateBundle(
            habits: habits,
            heatmapData: heatmapData,
            historyMap: historyMap,
            days: days,
            now: DateTime.now(),
          );

          unawaited(
            localDataSource.cacheStats(
              HabitStatsModel.fromEntity(bundle.overallStats),
            ),
          );

          return bundle;
        },
      );
    });
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
  Future<Either<Failure, List<HabitEntity>>> getTodayHabitsSummary() {
    return habitRepository.getHabits();
  }
}
