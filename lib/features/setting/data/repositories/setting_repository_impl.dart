import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import '../../domain/repositories/setting_repository.dart';
import '../datasources/setting_local_datasource.dart';
import '../datasources/setting_remote_datasource.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingLocalDataSource localDataSource;
  final SettingRemoteDataSource remoteDataSource;
  final HabitLocalDataSource habitLocalDataSource;

  SettingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.habitLocalDataSource,
  });

  @override
  Future<Either<Failure, String>> getLanguage() async {
    try {
      final lang = await localDataSource.getLanguage();
      return Right(lang);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLanguage(String languageCode) async {
    try {
      await localDataSource.saveLanguage(languageCode);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isNotificationEnabled() async {
    try {
      return Right(localDataSource.isNotificationEnabled());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationEnabled(bool enabled) async {
    try {
      await localDataSource.setNotificationEnabled(enabled);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TimeOfDay?>> getNotificationTime() async {
    try {
      return Right(localDataSource.getNotificationTime());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationTime(TimeOfDay time) async {
    try {
      await localDataSource.setNotificationTime(time);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HabitModel>>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  }) async {
    try {
      // 1. Determine local start date (use parameter if provided, else get from local DS)
      final effectiveStartDay =
          localStartDay ?? habitLocalDataSource.getStartDate();

      // 2. Sync habits via remote (now includes startDay)
      final mergedHabits = await remoteDataSource.syncHabits(
        localHabits,
        localTombstones: localTombstones,
        localStartDay: effectiveStartDay,
      );

      // 3. Persist habits to local database
      await habitLocalDataSource.saveHabits(mergedHabits);

      // 4. Sync and persist history (Heatmap data)
      final firestoreService = FirestoreService();
      if (firestoreService.isUserLoggedIn) {
        // Find if there's a cloud start day to update locally
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        final cloudStartDay = userDoc.data()?['startDay'] as String?;
        if (cloudStartDay != null && cloudStartDay != effectiveStartDay) {
          habitLocalDataSource.updateStartDate(cloudStartDay);
        }

        final localHistory = await habitLocalDataSource.getAllHabitStrengths();
        final mergedHistory = await firestoreService.syncHabitHistory(
          localHistory,
        );
        await habitLocalDataSource.saveAllHabitStrengths(mergedHistory);

        // 5. Sync AI API key
        final localKey = localDataSource.getCustomGeminiApiKey();
        final remoteKey = await remoteDataSource.downloadCustomApiKey();
        if ((localKey == null || localKey.trim().isEmpty) &&
            remoteKey != null &&
            remoteKey.trim().isNotEmpty) {
          await localDataSource.saveCustomGeminiApiKey(remoteKey.trim());
        } else if (localKey != null &&
            localKey.trim().isNotEmpty &&
            (remoteKey == null || remoteKey.trim().isEmpty)) {
          await remoteDataSource.uploadCustomApiKey(localKey.trim());
        }
      }

      return Right(mergedHabits);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      final time = await remoteDataSource.getLastSyncTime();
      return Right(time);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getCustomApiKey() async {
    try {
      var key = localDataSource.getCustomGeminiApiKey();
      if (key == null || key.trim().isEmpty) {
        final remoteKey = await remoteDataSource.downloadCustomApiKey();
        if (remoteKey != null && remoteKey.trim().isNotEmpty) {
          key = remoteKey.trim();
          await localDataSource.saveCustomGeminiApiKey(key);
        }
      }
      return Right(key);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveCustomApiKey(String key) async {
    try {
      await localDataSource.saveCustomGeminiApiKey(key);
      await remoteDataSource.uploadCustomApiKey(key);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCustomApiKey() async {
    try {
      await localDataSource.clearCustomGeminiApiKey();
      await remoteDataSource.deleteCustomApiKey();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      // 1. Clear Remote Data if logged in
      final firestoreService = FirestoreService();
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.deleteAllUserData();
      }

      // 2. Clear Local Data
      await localDataSource.clearAllData();
      await habitLocalDataSource.clearAllData();

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
