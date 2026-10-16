import 'package:habit_tracker/core/storage/key_value_storage.dart';
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
  final KeyValueStorage? storage;
  static const String statsCacheKey = 'HABIT_STATS_CACHE';

  HabitStatsLocalDataSourceImpl({this.storage});

  @override
  HabitStatsModel? getCachedStats() {
    try {
      if (storage == null) return null;
      final raw = storage!.getJson(statsCacheKey);
      if (raw != null) {
        return HabitStatsModel.fromMap(raw);
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> cacheStats(HabitStatsModel stats) async {
    try {
      if (storage == null) return;
      await storage!.setJson(statsCacheKey, stats.toMap());
    } catch (_) {}
  }

  @override
  Future<void> clearCache() async {
    try {
      if (storage == null) return;
      await storage!.remove(statsCacheKey);
    } catch (_) {}
  }
}
