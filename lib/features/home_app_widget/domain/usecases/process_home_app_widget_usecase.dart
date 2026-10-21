import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../entities/home_app_widget_data_entity.dart';
import '../repositories/home_app_widget_repository.dart';

/// Use case for isolating and calculating the snapshot data for Home Screen Widget.
class ProcessHomeAppWidgetUseCase {
  final HomeAppWidgetRepository repository;

  ProcessHomeAppWidgetUseCase(this.repository);

  Future<Either<Failure, HomeAppWidgetDataEntity>> call({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) {
    return repository.processWidgetData(
      habits: habits,
      heatmapData: heatmapData,
    );
  }
}
