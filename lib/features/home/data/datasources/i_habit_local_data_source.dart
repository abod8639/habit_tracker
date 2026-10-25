import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/habit_vault_data.dart';

abstract class IHabitLocalDataSource {
  HabitOfflineVaultDataSource? get vaultDataSource;
  List<HabitModel> loadHabits();
  Future<void> saveHabits(List<HabitModel> habits);
  Future<void> saveHabitCompletionHistory(
    String habitId,
    bool isCompleted, {
    String? habitName,
  });
  Future<void> renameHabitHistory(
    String habitId,
    String oldName,
    String newName,
  );
  Future<void> saveHabitStrength(String dateStr, String strength);
  Future<void> saveAllHabitStrengths(Map<String, String> strengths);
  Future<Map<DateTime, int>> getHeatmapData();
  Future<Map<String, String>> getAllHabitStrengths();
  List<String> getLocalTombstones();
  void addLocalTombstones(List<String> ids);
  void clearLocalTombstones();
  Future<DateTime?> getLastResetDate();
  Future<void> saveLastResetDate(DateTime date);
  Future<void> incrementDayCount([int amount = 1]);
  Future<void> saveHabitCompletionToHistory(
    String habitIdOrName,
    bool isCompleted,
    DateTime date, {
    String? habitName,
  });
  Future<Map<String, int>> getCompletionStatusForDate(DateTime date);
  Future<Map<String, Map<DateTime, bool>>> getHabitHistoryMap(int days);
  Future<Map<String, Map<String, bool>>> getAllHabitCompletions();
  Future<void> saveAllHabitCompletions(Map<String, Map<String, bool>> completions);
  String getStartDate();
  void updateStartDate(String date);
  Future<void> clearAllData({
    String? earliestDateStr,
    bool backupBeforeClear = false,
    String? userId,
  });
  String? getLastUserId();
  Future<HabitVaultData> createSnapshot({required String userId});
  Future<void> restoreFromSnapshot(HabitVaultData snapshot);
}
