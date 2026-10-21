import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
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
final habitStatsLocalDataSourceProvider = Provider<HabitStatsLocalDataSource>((
  ref,
) {
  final storage = ref.watch(keyValueStorageProvider);
  return HabitStatsLocalDataSourceImpl(storage: storage);
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
final getHabitStatsBundleUseCaseProvider = Provider<GetHabitStatsBundleUseCase>(
  (ref) {
    final repo = ref.watch(habitStatsRepositoryProvider);
    return GetHabitStatsBundleUseCase(repo);
  },
);

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
  final Failure? activeFailure;

  const HabitStatsState({
    this.stats,
    this.overallTrend = const [],
    this.individualTrends = const {},
    this.todaySummary = const [],
    this.daysPeriod = 7,
    this.isWeeklyView = true,
    this.showAllHabits = false,
    this.selectedHabitName,
    this.habitNames = const [],
    this.isLoading = false,
    this.activeFailure,
  });

  bool get hasError => activeFailure != null;

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
    Failure? activeFailure,
    bool clearFailure = false,
  }) {
    return HabitStatsState(
      stats: stats ?? this.stats,
      overallTrend: overallTrend ?? this.overallTrend,
      individualTrends: individualTrends ?? this.individualTrends,
      todaySummary: todaySummary ?? this.todaySummary,
      daysPeriod: daysPeriod ?? this.daysPeriod,
      isWeeklyView: isWeeklyView ?? this.isWeeklyView,
      showAllHabits: showAllHabits ?? this.showAllHabits,
      selectedHabitName: selectedHabitName != null
          ? selectedHabitName()
          : this.selectedHabitName,
      habitNames: habitNames ?? this.habitNames,
      isLoading: isLoading ?? this.isLoading,
      activeFailure: clearFailure
          ? null
          : (activeFailure ?? this.activeFailure),
    );
  }
}

// Habit Stats Notifier
class HabitStatsNotifier extends AsyncNotifier<HabitStatsState> {
  List<FlSpot> _weeklyOverallTrend = const [];
  List<FlSpot> _monthlyOverallTrend = const [];
  Map<String, List<FlSpot>> _weeklyIndividualTrends = const {};
  Map<String, List<FlSpot>> _monthlyIndividualTrends = const {};
  bool _isDisposed = false;
  Future<void>? _activeRefreshFuture;

  @override
  FutureOr<HabitStatsState> build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _activeRefreshFuture = null;
    });

    // 1. Reactive listener: immediately syncs stats when habits change (0 ms lag)
    ref.listen(habitNotifierProvider, (previous, next) {
      if (_isDisposed) return;
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

    // 3. Pre-populate initial trends for both weekly and monthly from in-memory habits
    final initialWeeklyInd = <String, List<FlSpot>>{};
    final initialMonthlyInd = <String, List<FlSpot>>{};
    for (var habit in habits) {
      initialWeeklyInd[habit.name] = List.generate(
        7,
        (i) => FlSpot(i.toDouble(), (i == 6 && habit.isCompleted) ? 1.0 : 0.0),
      );
      initialMonthlyInd[habit.name] = List.generate(
        30,
        (i) => FlSpot(i.toDouble(), (i == 29 && habit.isCompleted) ? 1.0 : 0.0),
      );
    }
    _weeklyIndividualTrends = initialWeeklyInd;
    _monthlyIndividualTrends = initialMonthlyInd;

    final rate = totalHabits > 0 ? (completedHabits / totalHabits) : 0.0;
    _weeklyOverallTrend = List.generate(
      7,
      (i) => FlSpot(i.toDouble(), i == 6 ? rate : 0.0),
    );
    _monthlyOverallTrend = List.generate(
      30,
      (i) => FlSpot(i.toDouble(), i == 29 ? rate : 0.0),
    );

    // 4. Schedule fresh historical data fetch
    Future.microtask(() {
      if (!_isDisposed) {
        refreshStats();
      }
    });

    return HabitStatsState(
      stats: initialStats,
      todaySummary: habits,
      overallTrend: _weeklyOverallTrend,
      individualTrends: initialWeeklyInd,
      habitNames: habits.map((h) => h.name).toList(),
      isLoading: false,
    );
  }

  void _updateLiveStats(HabitState habitState) {
    if (_isDisposed) return;
    final current = state.value ?? const HabitStatsState();
    final habits = habitState.habits;
    final int totalHabits = habits.length;
    final int completedHabits = habits.where((h) => h.isCompleted).length;
    final double completionRate = totalHabits > 0
        ? (completedHabits / totalHabits) * 100
        : 0.0;
    final double rate = totalHabits > 0 ? (completedHabits / totalHabits) : 0.0;

    final updatedStats = HabitStatsEntity(
      totalHabits: totalHabits,
      completedHabits: completedHabits,
      completionRate: completionRate,
      streak: habitState.streak,
      bestStreak: habitState.bestStreak,
    );

    final updatedWeeklyInd =
        Map<String, List<FlSpot>>.from(_weeklyIndividualTrends);
    final updatedMonthlyInd =
        Map<String, List<FlSpot>>.from(_monthlyIndividualTrends);

    for (var habit in habits) {
      final wSpots = updatedWeeklyInd[habit.name];
      if (wSpots != null && wSpots.isNotEmpty) {
        final lastIdx = wSpots.length - 1;
        wSpots[lastIdx] =
            FlSpot(lastIdx.toDouble(), habit.isCompleted ? 1.0 : 0.0);
      } else {
        updatedWeeklyInd[habit.name] = List.generate(
          7,
          (i) => FlSpot(i.toDouble(), (i == 6 && habit.isCompleted) ? 1.0 : 0.0),
        );
      }

      final mSpots = updatedMonthlyInd[habit.name];
      if (mSpots != null && mSpots.isNotEmpty) {
        final lastIdx = mSpots.length - 1;
        mSpots[lastIdx] =
            FlSpot(lastIdx.toDouble(), habit.isCompleted ? 1.0 : 0.0);
      } else {
        updatedMonthlyInd[habit.name] = List.generate(
          30,
          (i) => FlSpot(i.toDouble(), (i == 29 && habit.isCompleted) ? 1.0 : 0.0),
        );
      }
    }

    _weeklyIndividualTrends = updatedWeeklyInd;
    _monthlyIndividualTrends = updatedMonthlyInd;

    if (_weeklyOverallTrend.isNotEmpty) {
      final lastIdx = _weeklyOverallTrend.length - 1;
      _weeklyOverallTrend[lastIdx] = FlSpot(lastIdx.toDouble(), rate);
    }
    if (_monthlyOverallTrend.isNotEmpty) {
      final lastIdx = _monthlyOverallTrend.length - 1;
      _monthlyOverallTrend[lastIdx] = FlSpot(lastIdx.toDouble(), rate);
    }

    final activeOverall =
        current.isWeeklyView ? _weeklyOverallTrend : _monthlyOverallTrend;
    final activeInd = current.isWeeklyView
        ? _weeklyIndividualTrends
        : _monthlyIndividualTrends;

    state = AsyncValue.data(
      current.copyWith(
        stats: updatedStats,
        todaySummary: habits,
        overallTrend: activeOverall,
        individualTrends: activeInd,
        habitNames: habits.map((h) => h.name).toList(),
      ),
    );
  }

  static List<FlSpot> _extractWeeklyTrend(List<FlSpot> monthlyTrend) {
    if (monthlyTrend.isEmpty) return const [];
    if (monthlyTrend.length <= 7) {
      return List.generate(
        monthlyTrend.length,
        (i) => FlSpot(i.toDouble(), monthlyTrend[i].y),
      );
    }
    final sublist = monthlyTrend.sublist(monthlyTrend.length - 7);
    return List.generate(
      7,
      (i) => FlSpot(i.toDouble(), sublist[i].y),
    );
  }

  static Map<String, List<FlSpot>> _extractWeeklyIndividualTrends(
    Map<String, List<FlSpot>> monthlyTrends,
  ) {
    return monthlyTrends.map((key, spots) {
      if (spots.isEmpty) return MapEntry(key, const <FlSpot>[]);
      if (spots.length <= 7) {
        return MapEntry(
          key,
          List.generate(spots.length, (i) => FlSpot(i.toDouble(), spots[i].y)),
        );
      }
      final sublist = spots.sublist(spots.length - 7);
      return MapEntry(
        key,
        List.generate(7, (i) => FlSpot(i.toDouble(), sublist[i].y)),
      );
    });
  }

  Future<void> refreshStats() {
    if (_activeRefreshFuture != null) {
      return _activeRefreshFuture!;
    }
    final future = _executeRefresh();
    _activeRefreshFuture = future;
    return future;
  }

  Future<void> _executeRefresh() async {
    final current = state.value ?? const HabitStatsState();
    state = AsyncValue.data(
      current.copyWith(isLoading: true, clearFailure: true),
    );

    try {
      final getBundle = ref.read(getHabitStatsBundleUseCaseProvider);
      final result = await getBundle(30);

      if (_isDisposed) return;

      result.fold(
        (failure) {
          state = AsyncValue.data(
            current.copyWith(
              isLoading: false,
              activeFailure: failure,
            ),
          );
        },
        (bundle) {
          _monthlyOverallTrend = bundle.overallTrend
              .map((p) => FlSpot(p.x, p.y))
              .toList();

          _monthlyIndividualTrends = bundle.individualTrends.map(
            (key, points) => MapEntry(
              key,
              points.map((p) => FlSpot(p.x, p.y)).toList(),
            ),
          );

          _weeklyOverallTrend = _extractWeeklyTrend(_monthlyOverallTrend);
          _weeklyIndividualTrends =
              _extractWeeklyIndividualTrends(_monthlyIndividualTrends);

          final activeOverall =
              current.isWeeklyView ? _weeklyOverallTrend : _monthlyOverallTrend;
          final activeInd = current.isWeeklyView
              ? _weeklyIndividualTrends
              : _monthlyIndividualTrends;

          state = AsyncValue.data(
            current.copyWith(
              stats: bundle.overallStats,
              overallTrend: activeOverall,
              individualTrends: activeInd,
              habitNames: bundle.individualTrends.keys.toList(),
              todaySummary: bundle.todayHabits,
              isLoading: false,
              clearFailure: true,
            ),
          );
        },
      );
    } catch (e, stack) {
      if (_isDisposed) return;
      final failure = NetworkErrorHandler.handle(e, stack);
      state = AsyncValue.data(
        current.copyWith(
          isLoading: false,
          activeFailure: failure,
        ),
      );
    } finally {
      _activeRefreshFuture = null;
    }
  }

  void togglePeriod() {
    final current = state.value ?? const HabitStatsState();
    final newIsWeekly = !current.isWeeklyView;
    final newDays = newIsWeekly ? 7 : 30;

    final targetOverallTrend =
        newIsWeekly ? _weeklyOverallTrend : _monthlyOverallTrend;
    final targetIndividualTrends =
        newIsWeekly ? _weeklyIndividualTrends : _monthlyIndividualTrends;

    state = AsyncValue.data(
      current.copyWith(
        isWeeklyView: newIsWeekly,
        daysPeriod: newDays,
        overallTrend: targetOverallTrend,
        individualTrends: targetIndividualTrends,
      ),
    );

    if (targetOverallTrend.isEmpty) {
      refreshStats();
    }
  }

  void toggleShowAllHabits() {
    final current = state.value ?? const HabitStatsState();
    state = AsyncValue.data(
      current.copyWith(showAllHabits: !current.showAllHabits),
    );
  }

  void selectHabit(String? habitName) {
    final current = state.value ?? const HabitStatsState();
    if (current.selectedHabitName == habitName) {
      state = AsyncValue.data(
        current.copyWith(selectedHabitName: () => null),
      );
    } else {
      state = AsyncValue.data(
        current.copyWith(
          selectedHabitName: () => habitName,
          showAllHabits: true,
        ),
      );
    }
  }
}

final habitStatsNotifierProvider =
    AsyncNotifierProvider<HabitStatsNotifier, HabitStatsState>(() {
  return HabitStatsNotifier();
});
