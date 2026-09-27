import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../domain/entities/habit_stats_entity.dart';
import '../../domain/usecases/get_overall_stats_usecase.dart';
import '../../domain/usecases/get_overall_trend_usecase.dart';
import '../../domain/usecases/get_individual_habit_trends_usecase.dart';
import '../../domain/usecases/get_today_habits_summary_usecase.dart';

class HabitStatsController extends GetxController {
  final GetOverallStatsUseCase getOverallStatsUseCase;
  final GetOverallTrendUseCase getOverallTrendUseCase;
  final GetIndividualHabitTrendsUseCase getIndividualHabitTrendsUseCase;
  final GetTodayHabitsSummaryUseCase getTodayHabitsSummaryUseCase;

  HabitStatsController({
    required this.getOverallStatsUseCase,
    required this.getOverallTrendUseCase,
    required this.getIndividualHabitTrendsUseCase,
    required this.getTodayHabitsSummaryUseCase,
  });

  // Reactive state
  final Rx<HabitStatsEntity?> stats = Rx<HabitStatsEntity?>(null);
  final RxList<FlSpot> overallTrend = <FlSpot>[].obs;
  final RxMap<String, List<FlSpot>> individualTrends =
      <String, List<FlSpot>>{}.obs;
  final RxList<Map<String, dynamic>> todaySummary =
      <Map<String, dynamic>>[].obs;

  final RxInt daysPeriod = 7.obs;
  final RxBool isWeeklyView = true.obs;
  final RxBool showAllHabits = true.obs;
  final RxList<String> habitNames = <String>[].obs;
  final RxBool isLoading = false.obs;
  bool _isRefreshing = false;

  @override
  void onInit() {
    super.onInit();
    _loadInitialQuickData();
    refreshStats();
  }

  Future<void> _loadInitialQuickData() async {
    try {
      final summary = await getTodayHabitsSummaryUseCase();
      if (summary.isNotEmpty) {
        if (todaySummary.isEmpty) {
          todaySummary.assignAll(summary);
        }
        if (stats.value == null) {
          final total = summary.length;
          final completed =
              summary.where((h) => h['completed'] == true).length;
          final rate = total > 0 ? (completed / total) * 100 : 0.0;
          stats.value = HabitStatsEntity(
            totalHabits: total,
            completedHabits: completed,
            completionRate: rate,
            streak: 0,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> refreshStats() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      if (stats.value == null) {
        isLoading.value = true;
      }

      final results = await Future.wait([
        getOverallStatsUseCase(),
        getOverallTrendUseCase(daysPeriod.value),
        getIndividualHabitTrendsUseCase(daysPeriod.value),
        getTodayHabitsSummaryUseCase(),
      ]);

      stats.value = results[0] as HabitStatsEntity;
      overallTrend.assignAll(results[1] as List<FlSpot>);

      final trends = results[2] as Map<String, List<FlSpot>>?;
      if (trends != null) {
        individualTrends.assignAll(trends);
        habitNames.assignAll(trends.keys.toList());
      }

      todaySummary.assignAll(results[3] as List<Map<String, dynamic>>);
    } finally {
      isLoading.value = false;
      _isRefreshing = false;
    }
  }

  void togglePeriod() async {
    isWeeklyView.value = !isWeeklyView.value;
    daysPeriod.value = isWeeklyView.value ? 7 : 30;

    try {
      final results = await Future.wait([
        getOverallTrendUseCase(daysPeriod.value),
        getIndividualHabitTrendsUseCase(daysPeriod.value),
      ]);
      overallTrend.assignAll(results[0] as List<FlSpot>);
      final trends = results[1] as Map<String, List<FlSpot>>?;
      if (trends != null) {
        individualTrends.assignAll(trends);
        habitNames.assignAll(trends.keys.toList());
      }
    } catch (_) {}
  }

  void toggleShowAllHabits() {
    showAllHabits.toggle();
  }
}
