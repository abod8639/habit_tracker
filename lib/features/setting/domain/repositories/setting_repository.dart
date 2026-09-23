import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

abstract class SettingRepository {
  Future<Either<Failure, String>> getLanguage();
  Future<Either<Failure, void>> saveLanguage(String languageCode);

  Future<Either<Failure, bool>> isNotificationEnabled();
  Future<Either<Failure, void>> setNotificationEnabled(bool enabled);

  Future<Either<Failure, TimeOfDay?>> getNotificationTime();
  Future<Either<Failure, void>> setNotificationTime(TimeOfDay time);

  Future<Either<Failure, List<HabitModel>>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  });
  Future<Either<Failure, DateTime?>> getLastSyncTime();
  Future<Either<Failure, String?>> getCustomApiKey();
  Future<Either<Failure, void>> saveCustomApiKey(String key);
  Future<Either<Failure, void>> clearCustomApiKey();

  Future<Either<Failure, void>> clearAllData();
}
