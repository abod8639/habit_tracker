import 'package:equatable/equatable.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'habit_stats_entity.dart';
import 'trend_point_entity.dart';

/// Aggregated domain entity holding complete stats, trends, and today's habits.
class HabitStatsBundleEntity extends Equatable {
  final HabitStatsEntity overallStats;
  final List<TrendPointEntity> overallTrend;
  final Map<String, List<TrendPointEntity>> individualTrends;
  final List<HabitEntity> todayHabits;

  const HabitStatsBundleEntity({
    required this.overallStats,
    required this.overallTrend,
    required this.individualTrends,
    required this.todayHabits,
  });

  @override
  List<Object?> get props => [
    overallStats,
    overallTrend,
    individualTrends,
    todayHabits,
  ];
}
