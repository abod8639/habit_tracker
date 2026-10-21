import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../../domain/entities/habit_entity.dart';

/// Background Isolate processor for habit payloads, conversions, and statistics calculations.
/// Ensures heavy mapping and date aggregations do not block the main UI thread.
class HabitPayloadProcessor {
  HabitPayloadProcessor._();

  /// Offloads mapping of [HabitModel]s to [HabitEntity]s to a background isolate if the list is large.
  static Future<List<HabitEntity>> modelsToEntities(List<HabitModel> models) {
    if (models.isEmpty) return Future.value(const []);
    if (models.length < 25) {
      return Future.value(models.map((m) => m.toEntity()).toList());
    }
    return compute(_isolateModelsToEntities, models);
  }

  static List<HabitEntity> _isolateModelsToEntities(List<HabitModel> models) {
    return models.map((m) => m.toEntity()).toList();
  }

  /// Offloads heatmap data calculation and normalization to a background isolate.
  static Future<Map<DateTime, int>> processHeatmapData({
    required Map<DateTime, int> rawHeatmap,
    required List<HabitModel> habits,
  }) {
    if (habits.length < 25 && rawHeatmap.length < 50) {
      return Future.value(_computeHeatmapSync(rawHeatmap, habits));
    }
    return compute(_isolateProcessHeatmap, {
      'raw': rawHeatmap,
      'habits': habits,
    });
  }

  static Map<DateTime, int> _computeHeatmapSync(
    Map<DateTime, int> rawHeatmap,
    List<HabitModel> habits,
  ) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    int todayStrength = 0;
    if (habits.isNotEmpty) {
      final completedCount = habits.where((h) => h.isCompleted).length;
      final completionRate = completedCount / habits.length;
      todayStrength = (completionRate * 10).toInt();
      if (todayStrength == 0 && completedCount > 0) todayStrength = 1;
    }

    final result = Map<DateTime, int>.from(rawHeatmap);
    result[normalizedToday] = todayStrength;
    return result;
  }

  static Map<DateTime, int> _isolateProcessHeatmap(Map<String, dynamic> data) {
    final raw = data['raw'] as Map<DateTime, int>;
    final habits = data['habits'] as List<HabitModel>;
    return _computeHeatmapSync(raw, habits);
  }
}
