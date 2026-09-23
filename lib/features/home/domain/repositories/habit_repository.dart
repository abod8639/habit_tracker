import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/habit_entity.dart';

abstract class HabitRepository {
  Future<Either<Failure, List<HabitEntity>>> getHabits();
  Future<Either<Failure, void>> addHabit(String name);
  Future<Either<Failure, void>> addMultipleHabits(List<String> names);
  Future<Either<Failure, void>> editHabit(String id, String newName);
  Future<Either<Failure, void>> deleteHabit(String id);
  Future<Either<Failure, void>> toggleHabit(String id, bool isCompleted);
  Future<Either<Failure, void>> reorderHabits(int oldIndex, int newIndex);
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData();
  Future<Either<Failure, void>> updateHabitColor(String id, int colorValue);
  Future<Either<Failure, void>> updateHabitOrder(List<String> ids);
  bool isUserLoggedIn();
  List<String> getLocalTombstones();
  void clearLocalTombstones();
  
  // Date and Reset logic
  Future<Either<Failure, DateTime?>> getLastResetDate();
  Future<Either<Failure, void>> saveLastResetDate(DateTime date);
  Future<Either<Failure, void>> resetHabitsCompletion();
  Future<Either<Failure, void>> incrementDayCount([int amount = 1]);
  Future<Either<Failure, void>> saveHabitCompletionToHistory(String habitIdOrName, bool isCompleted, DateTime date, {String? habitName});
  Future<Either<Failure, Map<String, int>>> getCompletionStatusForDate(DateTime date);
  Future<Either<Failure, Map<String, Map<DateTime, bool>>>> getHabitHistoryMap(int days);
  String getStartDate();
  Future<Either<Failure, void>> clearLocalData({String? earliestDateStr});
}
