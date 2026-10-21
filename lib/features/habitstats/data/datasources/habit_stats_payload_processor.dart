import 'package:flutter/foundation.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../../domain/entities/habit_stats_bundle_entity.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/entities/trend_point_entity.dart';

/// DTO for passing calculation inputs safely to the background isolate.
class _StatsCalculationParams {
  final List<HabitEntity> habits;
  final Map<DateTime, int> heatmapData;
  final Map<String, Map<DateTime, bool>> historyMap;
  final int days;
  final DateTime now;

  _StatsCalculationParams({
    required this.habits,
    required this.heatmapData,
    required this.historyMap,
    required this.days,
    required this.now,
  });
}

/// Top-level pure worker function executed in an isolated background thread via [compute]
/// to prevent UI freezing (jank) during heavy date math, streak calculations, and trend analysis.
HabitStatsBundleEntity _computeStatsBundleWorker(
  _StatsCalculationParams params,
) {
  final habits = params.habits;
  final heatmapData = params.heatmapData;
  final historyMap = params.historyMap;
  final days = params.days;
  final now = params.now;
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
    final habitHistory = historyMap[habit.id] ?? historyMap[habit.name] ?? {};

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
  }

  return HabitStatsBundleEntity(
    overallStats: overallStats,
    overallTrend: overallTrend,
    individualTrends: individualTrends,
    todayHabits: habits,
  );
}

/// Service to offload heavy statistical and historical date calculations
/// to a background Isolate via [compute] to prevent UI Freezing.
class HabitStatsPayloadProcessor {
  HabitStatsPayloadProcessor._();

  static Future<HabitStatsBundleEntity> calculateBundle({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
    required Map<String, Map<DateTime, bool>> historyMap,
    required int days,
    required DateTime now,
  }) {
    final params = _StatsCalculationParams(
      habits: habits,
      heatmapData: heatmapData,
      historyMap: historyMap,
      days: days,
      now: now,
    );
    return compute(_computeStatsBundleWorker, params);
  }
}
