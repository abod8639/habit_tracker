import 'package:habit_tracker/features/home/data/models/habit_model.dart';

/// Storage constants and defaults for the Habit Tracker app
class HabitStorage {
  // Database / Key constants
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
