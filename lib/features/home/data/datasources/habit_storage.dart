// habit_storage.dart
// import 'package:flutter/material.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:hive/hive.dart';

/// Storage constants and helper methods for the Habit Tracker app
class HabitStorage {
  // Box names
  static const String boxName = "Habit_db";
  static const String backupVaultBox = "Habit_vault_db";

  // Storage keys
  static const String habitListKey = "TODOLIST";
  static const String lastResetDateKey = "LAST_RESET_DATE";
  static const String dayCountKey = "DAY_COUNT";
  static const String startDayKey = "START_DAY";
  static const String lastSavedDateKey = "LAST_SAVED_DATE";
  static const String habitStrengthPrefix = "TODAY_HABIT";

  // Default values
  static const int defaultDayCount = 1;

  static List<HabitModel> defaultHabits = [
    HabitModel(
      id: '1',
      name: "Default Habit 1",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    HabitModel(
      id: '2',
      name: "Default Habit 2",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
    HabitModel(
      id: '3',
      name: "Default Habit 3",
      isCompleted: false,
      createdAt: DateTime.now(),
    ),
  ];
}

/// Initialize the Habit database and ensure data is loaded properly
Future<void> initializeBox(Box box, dynamic db) async {
  try {
    if (box.get(HabitStorage.habitListKey) == null) {
      // First time initialization
      box.put(HabitStorage.habitListKey, HabitStorage.defaultHabits);
      box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
      box.put(HabitStorage.startDayKey, todaysDateFormatted());

      // Set initial last reset date
      final now = DateTime.now();
      saveLastResetDate(box, now);
    }

    // Always make sure day count exists
    if (box.get(HabitStorage.dayCountKey) == null) {
      box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
    }

    // Always ensure lastSavedDate is initialized
    if (box.get(HabitStorage.lastSavedDateKey) == null) {
      box.put(HabitStorage.lastSavedDateKey, todaysDateFormatted());
    }
  } catch (e) {
    // Attempt recovery
    _recoverFromInitializationError(box);
  }
}

/// Save the last reset date to track habit resets
void saveLastResetDate(Box box, DateTime date) {
  box.put(HabitStorage.lastResetDateKey, date.toIso8601String());
}

/// Get the last reset date or null if not set
DateTime? getLastResetDate(Box box) {
  try {
    final String? dateStr = box.get(HabitStorage.lastResetDateKey);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  } catch (e) {
    return null;
  }
}

/// Recovery method to handle initialization errors
void _recoverFromInitializationError(Box box) {
  try {
    // Reset to default state
    box.put(HabitStorage.habitListKey, HabitStorage.defaultHabits);
    box.put(HabitStorage.dayCountKey, HabitStorage.defaultDayCount);
    box.put(HabitStorage.startDayKey, todaysDateFormatted());
    saveLastResetDate(box, DateTime.now());
  } catch (e) {
    // Recovery failed
  }
}
