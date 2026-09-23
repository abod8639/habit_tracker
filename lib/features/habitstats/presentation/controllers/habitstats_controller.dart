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

  @override
  void onInit() {
    super.onInit();
    refreshStats();
  }

  Future<void> refreshStats() async {
    try {
      isLoading.value = true;
      stats.value = await getOverallStatsUseCase();
      overallTrend.assignAll(await getOverallTrendUseCase(daysPeriod.value));

      final trends = await getIndividualHabitTrendsUseCase(daysPeriod.value);
      if (trends != null) {
        individualTrends.assignAll(trends);
        habitNames.assignAll(trends.keys.toList());
      }

      todaySummary.assignAll(await getTodayHabitsSummaryUseCase());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePeriod() {
    isWeeklyView.value = !isWeeklyView.value;
    daysPeriod.value = isWeeklyView.value ? 7 : 30;
    refreshStats();
  }

  void toggleShowAllHabits() {
    showAllHabits.toggle();
  }
}
