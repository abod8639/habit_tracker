import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';
import '../../domain/repositories/setting_repository.dart';
import '../datasources/setting_local_datasource.dart';
import '../datasources/setting_remote_datasource.dart';

class SettingRepositoryImpl implements SettingRepository {
  final SettingLocalDataSource localDataSource;
  final SettingRemoteDataSource remoteDataSource;
  final IHabitLocalDataSource habitLocalDataSource;

  SettingRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.habitLocalDataSource,
  });

  static const Duration _remoteTimeout = Duration(seconds: 15);
  static const Duration _localTimeout = Duration(seconds: 5);

  @override
  Future<Either<Failure, String>> getLanguage() {
    return NetworkErrorHandler.guard(() async {
      return await localDataSource.getLanguage().timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, void>> saveLanguage(String languageCode) {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.saveLanguage(languageCode).timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, bool>> isNotificationEnabled() {
    return NetworkErrorHandler.guard(() async {
      return localDataSource.isNotificationEnabled();
    });
  }

  @override
  Future<Either<Failure, void>> setNotificationEnabled(bool enabled) {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.setNotificationEnabled(enabled).timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, TimeOfDay?>> getNotificationTime() {
    return NetworkErrorHandler.guard(() async {
      return localDataSource.getNotificationTime();
    });
  }

  @override
  Future<Either<Failure, void>> setNotificationTime(TimeOfDay time) {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.setNotificationTime(time).timeout(_localTimeout);
    });
  }

  @override
  Future<Either<Failure, List<HabitModel>>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  }) {
    return NetworkErrorHandler.guard(() async {
      // 1. Determine local start date (use parameter if provided, else get from local DS)
      final effectiveStartDay =
          localStartDay ?? habitLocalDataSource.getStartDate();

      // 2. Sync habits via remote with timeout
      final mergedHabits = await remoteDataSource
          .syncHabits(
            localHabits,
            localTombstones: localTombstones,
            localStartDay: effectiveStartDay,
          )
          .timeout(
            _remoteTimeout,
            onTimeout: () {
              throw const TimeoutAppException('Syncing habits timed out');
            },
          );

      // 3. Persist habits to local database
      await habitLocalDataSource
          .saveHabits(mergedHabits)
          .timeout(_localTimeout);

      // 4. Sync and persist history (Heatmap data)
      final firestoreService = FirestoreService();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (firestoreService.isUserLoggedIn && currentUser != null) {
        // Find if there's a cloud start day to update locally
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get()
            .timeout(
              _remoteTimeout,
              onTimeout: () {
                throw const TimeoutAppException('Fetching user cloud metadata timed out');
              },
            );

        final cloudStartDay = userDoc.data()?['startDay'] as String?;
        if (cloudStartDay != null && cloudStartDay != effectiveStartDay) {
          habitLocalDataSource.updateStartDate(cloudStartDay);
        }

        final localHistory = await habitLocalDataSource.getAllHabitStrengths();
        final mergedHistory = await firestoreService
            .syncHabitHistory(localHistory)
            .timeout(
              _remoteTimeout,
              onTimeout: () {
                throw const TimeoutAppException('Syncing habit history timed out');
              },
            );

        await habitLocalDataSource
            .saveAllHabitStrengths(mergedHistory)
            .timeout(_localTimeout);

        // 5. Sync AI API key
        final localKey = localDataSource.getCustomGeminiApiKey();
        final remoteKey = await remoteDataSource
            .downloadCustomApiKey()
            .timeout(_remoteTimeout);

        if ((localKey == null || localKey.trim().isEmpty) &&
            remoteKey != null &&
            remoteKey.trim().isNotEmpty) {
          await localDataSource
              .saveCustomGeminiApiKey(remoteKey.trim())
              .timeout(_localTimeout);
        } else if (localKey != null &&
            localKey.trim().isNotEmpty &&
            (remoteKey == null || remoteKey.trim().isEmpty)) {
          await remoteDataSource
              .uploadCustomApiKey(localKey.trim())
              .timeout(_remoteTimeout);
        }
      }

      return mergedHabits;
    });
  }

  @override
  Future<Either<Failure, DateTime?>> getLastSyncTime() {
    return NetworkErrorHandler.guard(() async {
      return await remoteDataSource.getLastSyncTime().timeout(_remoteTimeout);
    });
  }

  @override
  Future<Either<Failure, String?>> getCustomApiKey() {
    return NetworkErrorHandler.guard(() async {
      var key = localDataSource.getCustomGeminiApiKey();
      if (key == null || key.trim().isEmpty) {
        final remoteKey = await remoteDataSource
            .downloadCustomApiKey()
            .timeout(_remoteTimeout);
        if (remoteKey != null && remoteKey.trim().isNotEmpty) {
          key = remoteKey.trim();
          await localDataSource
              .saveCustomGeminiApiKey(key)
              .timeout(_localTimeout);
        }
      }
      return key;
    });
  }

  @override
  Future<Either<Failure, void>> saveCustomApiKey(String key) {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.saveCustomGeminiApiKey(key).timeout(_localTimeout);
      await remoteDataSource.uploadCustomApiKey(key).timeout(_remoteTimeout);
    });
  }

  @override
  Future<Either<Failure, void>> clearCustomApiKey() {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.clearCustomGeminiApiKey().timeout(_localTimeout);
      await remoteDataSource.deleteCustomApiKey().timeout(_remoteTimeout);
    });
  }

  @override
  Future<Either<Failure, void>> clearAllData() {
    return NetworkErrorHandler.guard(() async {
      // 1. Clear Remote Data if logged in
      final firestoreService = FirestoreService();
      if (firestoreService.isUserLoggedIn) {
        await firestoreService.deleteAllUserData().timeout(_remoteTimeout);
      }

      // 2. Clear Local Data
      await localDataSource.clearAllData().timeout(_localTimeout);
      await habitLocalDataSource.clearAllData().timeout(_localTimeout);
    });
  }
}
