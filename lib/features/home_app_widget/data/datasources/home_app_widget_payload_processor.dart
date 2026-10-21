import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import '../../domain/entities/home_app_widget_data_entity.dart';
import '../models/home_app_widget_snapshot_model.dart';

/// Background Isolate processor for preparing and filtering Home Screen Widget payloads.
/// Slices heatmap date windows, filters uncompleted habits, and parses large payloads
/// in an Isolate via [compute] to prevent UI freezing.
class HomeAppWidgetPayloadProcessor {
  HomeAppWidgetPayloadProcessor._();

  static const Duration _isolateTimeout = Duration(seconds: 5);

  /// Prepares the widget snapshot data, offloading to an Isolate via [compute]
  /// when payload sizes exceed thresholds, guarded by explicit timeouts.
  static Future<HomeAppWidgetDataEntity> processWidgetData({
    required List<HabitEntity> habits,
    required Map<DateTime, int> heatmapData,
  }) async {
    try {
      if (habits.length < 25 && heatmapData.length < 55) {
        return _processSync(habits, heatmapData);
      }

      return await compute(_isolateProcessWidgetData, {
        'habits': habits,
        'heatmap': heatmapData,
      }).timeout(
        _isolateTimeout,
        onTimeout: () {
          throw const TimeoutAppException(
            'Isolate widget data processing timed out',
          );
        },
      );
    } catch (e) {
      if (e is TimeoutAppException) rethrow;
      throw ParsingException('Failed to process widget data payload: $e');
    }
  }

  /// Parses large JSON payloads in a background Isolate to prevent main thread blocking.
  static Future<HomeAppWidgetSnapshotModel> computeParseJsonPayload(
    String rawJson,
  ) async {
    try {
      if (rawJson.length < 2048) {
        return HomeAppWidgetSnapshotModel.fromJson(rawJson);
      }

      return await compute(_isolateParseJson, rawJson).timeout(
        _isolateTimeout,
        onTimeout: () {
          throw const TimeoutAppException(
            'Isolate payload parsing timed out',
          );
        },
      );
    } catch (e) {
      if (e is TimeoutAppException) rethrow;
      throw ParsingException('Failed to parse snapshot payload in isolate: $e');
    }
  }

  static HomeAppWidgetDataEntity _processSync(
    List<HabitEntity> habits,
    Map<DateTime, int> heatmapData,
  ) {
    final uncompleted = habits.where((h) => !h.isCompleted).toList();
    final completedCount = habits.length - uncompleted.length;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final startDate = normalizedToday.subtract(const Duration(days: 55));

    // Slice heatmap to relevant window for widget display
    final Map<DateTime, int> slicedHeatmap = {};
    for (final entry in heatmapData.entries) {
      final date = entry.key;
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (!normalizedDate.isBefore(startDate) &&
          !normalizedDate.isAfter(normalizedToday)) {
        slicedHeatmap[normalizedDate] = entry.value;
      }
    }

    return HomeAppWidgetDataEntity(
      uncompletedHabits: uncompleted,
      heatmapDatasets: slicedHeatmap,
      totalCount: habits.length,
      completedCount: completedCount,
      lastUpdated: today,
    );
  }

  static HomeAppWidgetDataEntity _isolateProcessWidgetData(
    Map<String, dynamic> params,
  ) {
    final habits = params['habits'] as List<HabitEntity>;
    final heatmap = params['heatmap'] as Map<DateTime, int>;
    return _processSync(habits, heatmap);
  }

  static HomeAppWidgetSnapshotModel _isolateParseJson(String jsonString) {
    return HomeAppWidgetSnapshotModel.fromJson(jsonString);
  }
}
