import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../repositories/home_app_widget_repository.dart';

/// Use case that triggers rendering and updating the OS Home Screen App Widget.
class SyncHomeAppWidgetUseCase {
  final HomeAppWidgetRepository repository;

  SyncHomeAppWidgetUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) {
    return repository.renderAndSyncWidget(
      habits: habits,
      heatmapData: heatmapData,
    );
  }
}
