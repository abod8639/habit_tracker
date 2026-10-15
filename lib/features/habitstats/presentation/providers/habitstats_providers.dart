import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_state.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';
import 'package:habit_tracker/features/habitstats/domain/entities/habit_stats_entity.dart';
import 'package:habit_tracker/features/habitstats/domain/repositories/habit_stats_repository.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_habit_stats_bundle_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_individual_habit_trends_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_overall_stats_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_overall_trend_usecase.dart';
import 'package:habit_tracker/features/habitstats/domain/usecases/get_today_habits_summary_usecase.dart';

// Data Source
final habitStatsLocalDataSourceProvider =
    Provider<HabitStatsLocalDataSource>((ref) {
  final box = Hive.isBoxOpen(HabitStorage.boxName)
      ? Hive.box(HabitStorage.boxName)
      : null;
  return HabitStatsLocalDataSourceImpl(myBox: box);
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
final getHabitStatsBundleUseCaseProvider =
    Provider<GetHabitStatsBundleUseCase>((ref) {
  final repo = ref.watch(habitStatsRepositoryProvider);
  return GetHabitStatsBundleUseCase(repo);
});

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

// Habit Stats State
class HabitStatsState {
  final HabitStatsEntity? stats;
  final List<FlSpot> overallTrend;
  final Map<String, List<FlSpot>> individualTrends;
  final List<HabitEntity> todaySummary;
  final int daysPeriod;
  final bool isWeeklyView;
  final bool showAllHabits;
  final String? selectedHabitName;
  final List<String> habitNames;
  final bool isLoading;

  const HabitStatsState({
    this.stats,
    this.overallTrend = const [],
    this.individualTrends = const {},
    this.todaySummary = const [],
    this.daysPeriod = 7,
    this.isWeeklyView = true,
    this.showAllHabits = true,
    this.selectedHabitName,
    this.habitNames = const [],
    this.isLoading = false,
  });

  HabitStatsState copyWith({
    HabitStatsEntity? stats,
    List<FlSpot>? overallTrend,
    Map<String, List<FlSpot>>? individualTrends,
    List<HabitEntity>? todaySummary,
    int? daysPeriod,
    bool? isWeeklyView,
    bool? showAllHabits,
    String? Function()? selectedHabitName,
    List<String>? habitNames,
    bool? isLoading,
  }) {
    return HabitStatsState(
      stats: stats ?? this.stats,
      overallTrend: overallTrend ?? this.overallTrend,
      individualTrends: individualTrends ?? this.individualTrends,
      todaySummary: todaySummary ?? this.todaySummary,
      daysPeriod: daysPeriod ?? this.daysPeriod,
      isWeeklyView: isWeeklyView ?? this.isWeeklyView,
      showAllHabits: showAllHabits ?? this.showAllHabits,
      selectedHabitName: selectedHabitName != null ? selectedHabitName() : this.selectedHabitName,
      habitNames: habitNames ?? this.habitNames,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Habit Stats Notifier
class HabitStatsNotifier extends Notifier<HabitStatsState> {
  bool _isRefreshing = false;
  bool _needsRefresh = false;

  @override
  HabitStatsState build() {
    // 1. Reactive listener: immediately syncs stats when habits change (0 ms lag)
    ref.listen(habitNotifierProvider, (previous, next) {
      if (previous?.habits != next.habits ||
          previous?.localHeatmapDateSet != next.localHeatmapDateSet) {
        _updateLiveStats(next);
        refreshStats();
      }
    });

    // 2. Synchronous initial calculation from current in-memory habits
    final habitState = ref.read(habitNotifierProvider);
    final habits = habitState.habits;
    final int totalHabits = habits.length;
    final int completedHabits = habits.where((h) => h.isCompleted).length;
    final double completionRate = totalHabits > 0
        ? (completedHabits / totalHabits) * 100
        : 0.0;

    final initialStats = HabitStatsEntity(
      totalHabits: totalHabits,
      completedHabits: completedHabits,
      completionRate: completionRate,
      streak: habitState.streak,
      bestStreak: habitState.bestStreak,
    );

    // 3. Pre-populate initial individual trends from habits
    final initialIndividualTrends = <String, List<FlSpot>>{};
    for (var habit in habits) {
      initialIndividualTrends[habit.name] = List.generate(
        7,
        (i) => FlSpot(i.toDouble(), (i == 6 && habit.isCompleted) ? 1.0 : 0.0),
      );
    }

    // 4. Schedule fresh historical data fetch
    Future.microtask(() {
      refreshStats();
    });

    return HabitStatsState(
      stats: initialStats,
      todaySummary: habits,
      individualTrends: initialIndividualTrends,
      habitNames: habits.map((h) => h.name).toList(),
      isLoading: false,
    );
  }

  void _updateLiveStats(HabitState habitState) {
    final habits = habitState.habits;
    final int totalHabits = habits.length;
    final int completedHabits = habits.where((h) => h.isCompleted).length;
    final double completionRate = totalHabits > 0
        ? (completedHabits / totalHabits) * 100
        : 0.0;

    final updatedStats = HabitStatsEntity(
      totalHabits: totalHabits,
      completedHabits: completedHabits,
      completionRate: completionRate,
      streak: habitState.streak,
      bestStreak: habitState.bestStreak,
    );

    final currentTrends = Map<String, List<FlSpot>>.from(state.individualTrends);
    for (var habit in habits) {
      final existingSpots = currentTrends[habit.name];
      if (existingSpots != null && existingSpots.isNotEmpty) {
        final lastIdx = existingSpots.length - 1;
        existingSpots[lastIdx] = FlSpot(
          lastIdx.toDouble(),
          habit.isCompleted ? 1.0 : 0.0,
        );
      } else {
        currentTrends[habit.name] = List.generate(
          state.daysPeriod,
          (i) => FlSpot(
            i.toDouble(),
            (i == state.daysPeriod - 1 && habit.isCompleted) ? 1.0 : 0.0,
          ),
        );
      }
    }

    state = state.copyWith(
      stats: updatedStats,
      todaySummary: habits,
      individualTrends: currentTrends,
      habitNames: habits.map((h) => h.name).toList(),
    );
  }

  Future<void> refreshStats() async {
    if (_isRefreshing) {
      _needsRefresh = true;
      return;
    }
    _isRefreshing = true;
    _needsRefresh = false;

    try {
      final getBundle = ref.read(getHabitStatsBundleUseCaseProvider);
      final result = await getBundle(state.daysPeriod);

      result.fold(
        (failure) {
          state = state.copyWith(isLoading: false);
        },
        (bundle) {
          final overallSpots = bundle.overallTrend
              .map((p) => FlSpot(p.x, p.y))
              .toList();

          final indTrends = bundle.individualTrends.map(
            (key, points) => MapEntry(
              key,
              points.map((p) => FlSpot(p.x, p.y)).toList(),
            ),
          );

          state = state.copyWith(
            stats: bundle.overallStats,
            overallTrend: overallSpots,
            individualTrends: indTrends,
            habitNames: indTrends.keys.toList(),
            todaySummary: bundle.todayHabits,
            isLoading: false,
          );
        },
      );
    } finally {
      _isRefreshing = false;
      if (_needsRefresh) {
        _needsRefresh = false;
        refreshStats();
      }
    }
  }

  void togglePeriod() async {
    final newIsWeekly = !state.isWeeklyView;
    final newDays = newIsWeekly ? 7 : 30;

    state = state.copyWith(
      isWeeklyView: newIsWeekly,
      daysPeriod: newDays,
    );

    try {
      final getBundle = ref.read(getHabitStatsBundleUseCaseProvider);
      final result = await getBundle(newDays);

      result.fold(
        (_) {},
        (bundle) {
          final overallSpots = bundle.overallTrend
              .map((p) => FlSpot(p.x, p.y))
              .toList();

          final indTrends = bundle.individualTrends.map(
            (key, points) => MapEntry(
              key,
              points.map((p) => FlSpot(p.x, p.y)).toList(),
            ),
          );

          state = state.copyWith(
            stats: bundle.overallStats,
            overallTrend: overallSpots,
            individualTrends: indTrends,
            habitNames: indTrends.keys.toList(),
            todaySummary: bundle.todayHabits,
          );
        },
      );
    } catch (_) {}
  }

  void toggleShowAllHabits() {
    state = state.copyWith(showAllHabits: !state.showAllHabits);
  }

  void selectHabit(String? habitName) {
    if (state.selectedHabitName == habitName) {
      state = state.copyWith(selectedHabitName: () => null);
    } else {
      state = state.copyWith(
        selectedHabitName: () => habitName,
        showAllHabits: true,
      );
    }
  }
}

final habitStatsNotifierProvider =
    NotifierProvider<HabitStatsNotifier, HabitStatsState>(() {
  return HabitStatsNotifier();
});
