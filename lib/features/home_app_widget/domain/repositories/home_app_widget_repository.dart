import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../entities/home_app_widget_data_entity.dart';

/// Clean Architecture repository contract for managing OS-level Home App Widget synchronization.
abstract class HomeAppWidgetRepository {
  /// Processes raw habit and heatmap collections into an optimized widget data entity.
  Future<Either<Failure, HomeAppWidgetDataEntity>> processWidgetData({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  });

  /// Triggers off-screen rendering and OS-level widget broadcast with explicit timeouts.
  Future<Either<Failure, void>> renderAndSyncWidget({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  });

  /// Parses raw JSON or serialized snapshot payload with defensive fallbacks and isolate processing.
  Future<Either<Failure, HomeAppWidgetDataEntity>> parseSnapshotPayload(
    String rawPayload,
  );
}
