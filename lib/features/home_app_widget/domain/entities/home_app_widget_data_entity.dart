import 'package:equatable/equatable.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';

/// Clean Architecture immutable domain entity representing the processed,
/// render-ready snapshot data for the mobile Home Screen widget.
class HomeAppWidgetDataEntity extends Equatable {
  final List<HabitEntity> uncompletedHabits;
  final Map<DateTime, int> heatmapDatasets;
  final int totalCount;
  final int completedCount;
  final DateTime lastUpdated;

  const HomeAppWidgetDataEntity({
    required this.uncompletedHabits,
    required this.heatmapDatasets,
    required this.totalCount,
    required this.completedCount,
    required this.lastUpdated,
  });

  /// Factory providing safe, uninitialized fallback state to prevent NullPointer exceptions.
  factory HomeAppWidgetDataEntity.empty() {
    return HomeAppWidgetDataEntity(
      uncompletedHabits: const [],
      heatmapDatasets: const {},
      totalCount: 0,
      completedCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  bool get isAllCompleted => totalCount > 0 && completedCount == totalCount;
  int get pendingCount => uncompletedHabits.length;
  double get completionRate =>
      totalCount == 0 ? 0.0 : (completedCount / totalCount).clamp(0.0, 1.0);

  HomeAppWidgetDataEntity copyWith({
    List<HabitEntity>? uncompletedHabits,
    Map<DateTime, int>? heatmapDatasets,
    int? totalCount,
    int? completedCount,
    DateTime? lastUpdated,
  }) {
    return HomeAppWidgetDataEntity(
      uncompletedHabits: uncompletedHabits ?? this.uncompletedHabits,
      heatmapDatasets: heatmapDatasets ?? this.heatmapDatasets,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
    uncompletedHabits,
    heatmapDatasets,
    totalCount,
    completedCount,
    lastUpdated,
  ];
}
