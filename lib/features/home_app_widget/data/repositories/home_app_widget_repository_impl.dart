import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/services/home_widget_service.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../../domain/entities/home_app_widget_data_entity.dart';
import '../../domain/repositories/home_app_widget_repository.dart';
import '../datasources/home_app_widget_payload_processor.dart';

/// Concrete repository implementation that integrates with [HomeWidgetService]
/// and offloads processing via [HomeAppWidgetPayloadProcessor], fully guarded by [NetworkErrorHandler].
class HomeAppWidgetRepositoryImpl implements HomeAppWidgetRepository {
  final HomeWidgetService homeWidgetService;

  HomeAppWidgetRepositoryImpl({required this.homeWidgetService});

  static const Duration _renderTimeout = Duration(seconds: 10);
  static const Duration _processTimeout = Duration(seconds: 5);

  @override
  Future<Either<Failure, HomeAppWidgetDataEntity>> processWidgetData({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) {
    return NetworkErrorHandler.guard(() async {
      return await HomeAppWidgetPayloadProcessor.processWidgetData(
        habits: habits,
        heatmapData: heatmapData,
      ).timeout(
        _processTimeout,
        onTimeout: () {
          throw const TimeoutAppException(
            'Processing home widget snapshot timed out',
          );
        },
      );
    });
  }

  @override
  Future<Either<Failure, void>> renderAndSyncWidget({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) {
    return NetworkErrorHandler.guard(() async {
      await homeWidgetService
          .updateWidget(
            habits: habits,
            heatmapData: heatmapData,
          )
          .timeout(
            _renderTimeout,
            onTimeout: () {
              throw const TimeoutAppException(
                'Rendering and syncing home widget timed out',
              );
            },
          );
    });
  }

  @override
  Future<Either<Failure, HomeAppWidgetDataEntity>> parseSnapshotPayload(
    String rawPayload,
  ) {
    return NetworkErrorHandler.guard(() async {
      final model = await HomeAppWidgetPayloadProcessor.computeParseJsonPayload(
        rawPayload,
      );
      return model.toEntity();
    });
  }
}
