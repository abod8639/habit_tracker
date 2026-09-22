import 'package:fl_chart/fl_chart.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/habit_stats_entity.dart';

class HabitStatsLocalDataSource {
  final Box myBox;
  final HabitRepository habitRepository;

  HabitStatsLocalDataSource({
    required this.myBox,
    required this.habitRepository,
  });

  Future<HabitStatsEntity> getOverallStats() async {
    final result = await habitRepository.getHabits();
    return await result.fold(
      (failure) async => const HabitStatsEntity(
        totalHabits: 0,
        completedHabits: 0,
        completionRate: 0,
        streak: 0,
      ),
      (habits) async {
        final int totalHabits = habits.length;
        final int completedHabits = habits.where((h) => h.isCompleted).length;
        final double completionRate = totalHabits > 0
            ? (completedHabits / totalHabits) * 100
            : 0;

        int streak = 0;
        final heatmapResult = await habitRepository.getHeatmapData();
        heatmapResult.fold(
          (_) => null,
          (heatmapData) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            if ((heatmapData[today] ?? 0) > 0) {
              streak++;
            }

            var checkDay = today.subtract(const Duration(days: 1));
            while (true) {
              final strength = heatmapData[checkDay] ?? 0;
              if (strength > 0) {
                streak++;
                checkDay = checkDay.subtract(const Duration(days: 1));
              } else {
                break;
              }
            }
          },
        );

        return HabitStatsEntity(
          totalHabits: totalHabits,
          completedHabits: completedHabits,
          completionRate: completionRate,
          streak: streak,
        );
      },
    );
  }

  Future<List<FlSpot>> getOverallTrendData(int days) async {
    final habitsResult = await habitRepository.getHabits();
    return await habitsResult.fold(
      (failure) async => List.generate(days, (index) => FlSpot(index.toDouble(), 0.0)),
      (habits) async {
        final heatmapResult = await habitRepository.getHeatmapData();
        return await heatmapResult.fold(
          (failure) async => List.generate(days, (index) => FlSpot(index.toDouble(), 0.0)),
          (heatmapData) async {
            final List<FlSpot> spots = [];
            final now = DateTime.now();
            final maxStrength = 10; // Heatmap data is bounded 0-10

            for (int i = 0; i < days; i++) {
              final normalizedDate = DateTime(now.year, now.month, now.day - (days - 1 - i));
              final completionValue = heatmapData[normalizedDate];

              final strength = completionValue ?? 0;
              final percentage = (strength / maxStrength).clamp(0.0, 1.0);
              spots.add(FlSpot(i.toDouble(), percentage));
            }
            return spots;
          },
        );
      },
    );
  }

  Future<Map<String, List<FlSpot>>> getIndividualHabitTrends(int days) async {
    final habitsResult = await habitRepository.getHabits();
    return await habitsResult.fold(
      (failure) async => {},
      (habits) async {
        final Map<String, List<FlSpot>> individualTrends = {};
        final now = DateTime.now();
        final historyMapResult = await habitRepository.getHabitHistoryMap(days);

        await historyMapResult.fold(
          (failure) async {
            for (var habit in habits) {
              individualTrends[habit.name] = List.generate(
                days,
                (index) => FlSpot(index.toDouble(), 0.0),
              );
            }
          },
          (historyMap) async {
            for (var habit in habits) {
              final List<FlSpot> spots = [];
              final habitHistory = historyMap[habit.name] ?? {};

              for (int i = 0; i < days; i++) {
                final normalizedDate = DateTime(now.year, now.month, now.day - (days - 1 - i));

                final bool? completed = habitHistory[normalizedDate];

                bool isCompleted = completed ?? false;
                if (completed == null && i == days - 1) {
                  isCompleted = habit.isCompleted;
                }

                spots.add(FlSpot(i.toDouble(), isCompleted ? 1.0 : 0.0));
              }
              individualTrends[habit.name] = spots;
            }
          },
        );
        return individualTrends;
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTodayHabitsSummary() async {
    final result = await habitRepository.getHabits();
    return result.fold(
      (failure) => [],
      (habitsList) {
        return List.generate(habitsList.length, (index) {
          final habit = habitsList[index];
          return {
            'id': habit.id,
            'habit': habit.name,
            'completed': habit.isCompleted,
            'createdAt': habit.createdAt,
          };
        });
      },
    );
  }
}

