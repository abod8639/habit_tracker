import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/habitstats/data/datasources/habit_stats_local_datasource.dart';
import 'package:habit_tracker/features/habitstats/data/repositories/habit_stats_repository_impl.dart';
import 'package:habit_tracker/features/habitstats/domain/entities/habit_stats_entity.dart';
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

// Habit Stats State
class HabitStatsState {
  final HabitStatsEntity? stats;
  final List<FlSpot> overallTrend;
  final Map<String, List<FlSpot>> individualTrends;
  final List<Map<String, dynamic>> todaySummary;
  final int daysPeriod;
  final bool isWeeklyView;
  final bool showAllHabits;
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
    this.habitNames = const [],
    this.isLoading = false,
  });

  HabitStatsState copyWith({
    HabitStatsEntity? stats,
    List<FlSpot>? overallTrend,
    Map<String, List<FlSpot>>? individualTrends,
    List<Map<String, dynamic>>? todaySummary,
    int? daysPeriod,
    bool? isWeeklyView,
    bool? showAllHabits,
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
      habitNames: habitNames ?? this.habitNames,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Habit Stats Notifier
class HabitStatsNotifier extends Notifier<HabitStatsState> {
  bool _isRefreshing = false;

  @override
  HabitStatsState build() {
    Future.microtask(() {
      _loadInitialQuickData();
      refreshStats();
    });
    return const HabitStatsState();
  }

  Future<void> _loadInitialQuickData() async {
    try {
      final getToday = ref.read(getTodayHabitsSummaryUseCaseProvider);
      final summary = await getToday();
      if (summary.isNotEmpty) {
        final total = summary.length;
        final completed = summary.where((h) => h['completed'] == true).length;
        final rate = total > 0 ? (completed / total) * 100 : 0.0;
        state = state.copyWith(
          todaySummary: summary,
          stats: HabitStatsEntity(
            totalHabits: total,
            completedHabits: completed,
            completionRate: rate,
            streak: 0,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> refreshStats() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      if (state.stats == null) {
        state = state.copyWith(isLoading: true);
      }

      final getOverallStats = ref.read(getOverallStatsUseCaseProvider);
      final getOverallTrend = ref.read(getOverallTrendUseCaseProvider);
      final getIndividualTrends = ref.read(getIndividualHabitTrendsUseCaseProvider);
      final getTodaySummary = ref.read(getTodayHabitsSummaryUseCaseProvider);

      final results = await Future.wait([
        getOverallStats(),
        getOverallTrend(state.daysPeriod),
        getIndividualTrends(state.daysPeriod),
        getTodaySummary(),
      ]);

      final trends = results[2] as Map<String, List<FlSpot>>?;

      state = state.copyWith(
        stats: results[0] as HabitStatsEntity,
        overallTrend: results[1] as List<FlSpot>,
        individualTrends: trends ?? const {},
        habitNames: trends?.keys.toList() ?? const [],
        todaySummary: results[3] as List<Map<String, dynamic>>,
        isLoading: false,
      );
    } finally {
      _isRefreshing = false;
    }
  }

  void togglePeriod() async {
    final newIsWeekly = !state.isWeeklyView;
    final newDays = newIsWeekly ? 7 : 30;

    try {
      final getOverallTrend = ref.read(getOverallTrendUseCaseProvider);
      final getIndividualTrends =
          ref.read(getIndividualHabitTrendsUseCaseProvider);

      final results = await Future.wait([
        getOverallTrend(newDays),
        getIndividualTrends(newDays),
      ]);
      final trends = results[1] as Map<String, List<FlSpot>>?;

      state = state.copyWith(
        isWeeklyView: newIsWeekly,
        daysPeriod: newDays,
        overallTrend: results[0] as List<FlSpot>,
        individualTrends: trends ?? const {},
        habitNames: trends?.keys.toList() ?? const [],
      );
    } catch (_) {
      state = state.copyWith(isWeeklyView: newIsWeekly, daysPeriod: newDays);
    }
  }

  void toggleShowAllHabits() {
    state = state.copyWith(showAllHabits: !state.showAllHabits);
  }
}

final habitStatsNotifierProvider =
    NotifierProvider<HabitStatsNotifier, HabitStatsState>(() {
  return HabitStatsNotifier();
});
