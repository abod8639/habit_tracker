import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';

class HabitState {
  final List<HabitEntity> habits;
  final Map<DateTime, int> localHeatmapDateSet;
  final Map<DateTime, int> remoteHeatmapDateSet;
  final List<String> selectedHabitIds;
  final bool isLoading;
  final String errorMessage;
  final Failure? activeFailure;
  final bool isInitialized;

  const HabitState({
    this.habits = const [],
    this.localHeatmapDateSet = const {},
    this.remoteHeatmapDateSet = const {},
    this.selectedHabitIds = const [],
    this.isLoading = false,
    this.errorMessage = '',
    this.activeFailure,
    this.isInitialized = false,
  });

  Map<DateTime, int> get heatmapDateSet => {
    ...remoteHeatmapDateSet,
    ...localHeatmapDateSet,
  };

  bool get isSelectionMode => selectedHabitIds.isNotEmpty;
  bool get hasError => activeFailure != null || errorMessage.isNotEmpty;
  String get displayErrorMessage => activeFailure?.toMessage() ?? errorMessage;

  /// Calculates the current active streak (consecutive days of habit completion).
  int calculateStreak() {
    final heatmap = heatmapDateSet;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedCount = habits.where((h) => h.isCompleted).length;

    int currentStreak = 0;
    // 1. If today has completed habits or recorded completion in heatmap
    final bool isTodayCompleted =
        completedCount > 0 || (heatmap[today] ?? 0) > 0;
    if (isTodayCompleted) {
      currentStreak++;
    }

    // 2. Count consecutive previous calendar days
    int daysBack = 1;
    while (true) {
      final checkDay = DateTime(
        today.year,
        today.month,
        today.day - daysBack,
      );
      final strength = heatmap[checkDay] ?? 0;
      if (strength > 0) {
        currentStreak++;
        daysBack++;
      } else {
        break;
      }
    }
    return currentStreak;
  }

  /// Calculates the all-time best streak (maximum consecutive days of completion).
  int calculateBestStreak() {
    final heatmap = heatmapDateSet;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedCount = habits.where((h) => h.isCompleted).length;

    final activeDates = <DateTime>{};
    heatmap.forEach((date, strength) {
      if (strength > 0) {
        activeDates.add(DateTime(date.year, date.month, date.day));
      }
    });
    if (completedCount > 0) {
      activeDates.add(today);
    }

    if (activeDates.isEmpty) return 0;

    final sortedDates = activeDates.toList()..sort();
    int maxStreak = 0;
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
    return maxStreak;
  }

  int get streak => calculateStreak();
  int get bestStreak => calculateBestStreak();

  String getStartDay(String storedStartDay) {
    final combinedHeatmap = heatmapDateSet;
    if (combinedHeatmap.isNotEmpty) {
      DateTime minDate = combinedHeatmap.keys.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      String minDateStr = convertDateTimeToString(minDate);

      if (storedStartDay.isEmpty) return minDateStr;

      try {
        DateTime storedDate = createDateTimeObject(storedStartDay);
        return minDate.isBefore(storedDate) ? minDateStr : storedStartDay;
      } catch (_) {
        return minDateStr;
      }
    }
    return storedStartDay;
  }

  HabitState copyWith({
    List<HabitEntity>? habits,
    Map<DateTime, int>? localHeatmapDateSet,
    Map<DateTime, int>? remoteHeatmapDateSet,
    List<String>? selectedHabitIds,
    bool? isLoading,
    String? errorMessage,
    Failure? activeFailure,
    bool clearActiveFailure = false,
    bool? isInitialized,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      localHeatmapDateSet: localHeatmapDateSet ?? this.localHeatmapDateSet,
      remoteHeatmapDateSet: remoteHeatmapDateSet ?? this.remoteHeatmapDateSet,
      selectedHabitIds: selectedHabitIds ?? this.selectedHabitIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      activeFailure: clearActiveFailure ? null : (activeFailure ?? this.activeFailure),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
