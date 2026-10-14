import 'package:habit_tracker/features/home/data/datasources/habit_storage.dart';
import 'package:hive/hive.dart';
import '../models/habit_stats_model.dart';

abstract class HabitStatsLocalDataSource {
  /// Retrieves cached stats from local storage if available.
  HabitStatsModel? getCachedStats();

  /// Persists stats to local storage for fast instant load.
  Future<void> cacheStats(HabitStatsModel stats);

  /// Clears cached stats.
  Future<void> clearCache();
}

class HabitStatsLocalDataSourceImpl implements HabitStatsLocalDataSource {
  final Box? myBox;
  static const String statsCacheKey = 'HABIT_STATS_CACHE';

  HabitStatsLocalDataSourceImpl({this.myBox});

  Box? get _box {
    if (myBox != null) return myBox;
    if (Hive.isBoxOpen(HabitStorage.boxName)) {
      return Hive.box(HabitStorage.boxName);
    }
    return null;
  }

  @override
  HabitStatsModel? getCachedStats() {
    try {
      final box = _box;
      if (box == null) return null;
      final raw = box.get(statsCacheKey);
      if (raw != null && raw is Map) {
        return HabitStatsModel.fromMap(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> cacheStats(HabitStatsModel stats) async {
    try {
      final box = _box;
      if (box == null) return;
      await box.put(statsCacheKey, stats.toMap());
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    try {
      final box = _box;
      if (box == null) return;
      await box.delete(statsCacheKey);
    } catch (_) {}
  }
}
