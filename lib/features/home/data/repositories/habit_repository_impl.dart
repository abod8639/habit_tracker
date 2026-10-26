import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_payload_processor.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import '../models/date_time.dart';

class HabitRepositoryImpl implements HabitRepository {
  final IHabitLocalDataSource localDataSource;
  final FirestoreService firestoreService;
  final HabitOfflineVaultDataSource? vaultDataSource;

  HabitRepositoryImpl({
    required this.localDataSource,
    required this.firestoreService,
    this.vaultDataSource,
  });

  static const Duration _cloudTimeout = Duration(seconds: 15);
  Timer? _uploadHabitsDebounceTimer;

  void _debounceUploadHabits(List<HabitModel> models) {
    _uploadHabitsDebounceTimer?.cancel();
    _uploadHabitsDebounceTimer = Timer(const Duration(milliseconds: 1500), () async {
      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Debounced cloud sync error on toggle: $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, List<HabitEntity>>> getHabits() async {
    return NetworkErrorHandler.guard(() async {
      final models = await localDataSource.fetchHabitsFromDb();
      return await HabitPayloadProcessor.modelsToEntities(models);
    });
  }

  @override
  Future<Either<Failure, void>> addHabit(String name) async {
    return addMultipleHabits([name]);
  }

  @override
  Future<Either<Failure, void>> addMultipleHabits(List<String> names) async {
    return NetworkErrorHandler.guard(() async {
      final models = List<HabitModel>.from(localDataSource.loadHabits());
      final now = DateTime.now();

      final existingNames = models
          .map((m) => m.name.trim().toLowerCase())
          .toSet();
      int addedCount = 0;

      for (final name in names) {
        final trimmedName = name.trim();
        if (trimmedName.isEmpty) continue;

        final normalizedName = trimmedName.toLowerCase();
        if (existingNames.contains(normalizedName)) continue;
        existingNames.add(normalizedName);

        final newModel = HabitModel(
          id: "${now.microsecondsSinceEpoch}_${trimmedName.hashCode}_${models.length}",
          name: trimmedName,
          isCompleted: false,
          createdAt: now,
          updatedAt: now,
          index: models.length,
        );
        models.add(newModel);
        addedCount++;
      }

      if (addedCount == 0) return;

      await localDataSource.saveHabits(models);
      _cachedHeatmapData = null;

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error (habits saved locally): $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> editHabit(String id, String newName) async {
    return NetworkErrorHandler.guard(() async {
      final models = List<HabitModel>.from(localDataSource.loadHabits());
      final index = models.indexWhere((m) => m.id == id);

      if (index != -1) {
        final m = models[index];
        final oldName = m.name;
        models[index] = HabitModel(
          id: m.id,
          name: newName,
          isCompleted: m.isCompleted,
          createdAt: m.createdAt,
          completedAt: m.completedAt,
          colorValue: m.colorValue,
          index: m.index,
          updatedAt: DateTime.now(),
        );

        await localDataSource.saveHabits(models);

        if (oldName != newName) {
          await localDataSource.renameHabitHistory(id, oldName, newName);
          _cachedHeatmapData = null;
        }

        if (firestoreService.isUserLoggedIn) {
          try {
            await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
          } catch (e) {
            debugPrint('Cloud sync error (habits updated locally): $e');
          }
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String id) async {
    return deleteMultipleHabits([id]);
  }

  @override
  Future<Either<Failure, void>> deleteMultipleHabits(List<String> ids) async {
    return NetworkErrorHandler.guard(() async {
      if (ids.isEmpty) return;

      final idSet = ids.toSet();
      final models = List<HabitModel>.from(localDataSource.loadHabits());
      models.removeWhere((m) => idSet.contains(m.id));

      await localDataSource.saveHabits(models);
      _cachedHeatmapData = null;
      localDataSource.addLocalTombstones(ids);

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.deleteHabits(ids).timeout(_cloudTimeout);
          await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error (habits deleted locally): $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> toggleHabit(String id, bool isCompleted) async {
    return NetworkErrorHandler.guard(() async {
      final models = List<HabitModel>.from(localDataSource.loadHabits());
      final index = models.indexWhere((m) => m.id == id);

      if (index != -1) {
        final m = models[index];
        models[index] = HabitModel(
          id: m.id,
          name: m.name,
          isCompleted: isCompleted,
          createdAt: m.createdAt,
          completedAt: isCompleted ? DateTime.now() : null,
          colorValue: m.colorValue,
          index: m.index,
          updatedAt: DateTime.now(),
        );

        await localDataSource.saveHabits(models);
        _cachedHeatmapData = null;
        await localDataSource.saveHabitCompletionHistory(
          m.id,
          isCompleted,
          habitName: m.name,
        );

        final completedCount = models.where((m) => m.isCompleted).length;
        final completionRate = models.isEmpty
            ? 0.0
            : completedCount / models.length;
        await localDataSource.saveHabitStrength(
          todaysDateFormatted(),
          completionRate.toString(),
        );

        if (firestoreService.isUserLoggedIn) {
          try {
            await firestoreService.uploadHabitCompletion(
              m.id,
              todaysDateFormatted(),
              isCompleted,
              completionRate: completionRate.toString(),
            ).timeout(_cloudTimeout);
          } catch (e) {
            debugPrint('Cloud sync error on toggle: $e');
          }
          _debounceUploadHabits(models);
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> reorderHabits(
    int oldIndex,
    int newIndex,
  ) async {
    return NetworkErrorHandler.guard(() async {
      final models = List<HabitModel>.from(localDataSource.loadHabits());

      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final model = models.removeAt(oldIndex);
      models.insert(newIndex, model);

      for (int i = 0; i < models.length; i++) {
        final m = models[i];
        models[i] = HabitModel(
          id: m.id,
          name: m.name,
          isCompleted: m.isCompleted,
          createdAt: m.createdAt,
          completedAt: m.completedAt,
          colorValue: m.colorValue,
          index: i,
          updatedAt: DateTime.now(),
        );
      }

      await localDataSource.saveHabits(models);

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error on reorder: $e');
        }
      }
    });
  }

  Map<DateTime, int>? _cachedHeatmapData;

  @override
  void invalidateHeatmapCache() {
    _cachedHeatmapData = null;
  }

  @override
  Future<Either<Failure, Map<DateTime, int>>> getHeatmapData() async {
    return NetworkErrorHandler.guard(() async {
      final habits = localDataSource.loadHabits();
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      int todayStrength = 0;
      if (habits.isNotEmpty) {
        final completedCount = habits.where((h) => h.isCompleted).length;
        final completionRate = completedCount / habits.length;
        todayStrength = (completionRate * 10).toInt();
        if (todayStrength == 0 && completedCount > 0) todayStrength = 1;
      }

      if (_cachedHeatmapData != null) {
        final cached = Map<DateTime, int>.from(_cachedHeatmapData!);
        cached[normalizedToday] = todayStrength;
        return cached;
      }

      // 1. Get historical data directly from local storage
      final rawHeatmap = await localDataSource.getHeatmapData();

      // 2. Offload processing to background isolate
      final heatmapData = await HabitPayloadProcessor.processHeatmapData(
        rawHeatmap: rawHeatmap,
        habits: habits,
      );

      _cachedHeatmapData = Map<DateTime, int>.from(heatmapData);
      return heatmapData;
    });
  }

  @override
  Future<Either<Failure, void>> updateHabitOrder(List<String> ids) async {
    return NetworkErrorHandler.guard(() async {
      final models = localDataSource.loadHabits();
      final Map<String, HabitModel> modelMap = {for (var m in models) m.id: m};
      final List<HabitModel> reorderedModels = [];

      for (int i = 0; i < ids.length; i++) {
        final m = modelMap[ids[i]];
        if (m != null) {
          reorderedModels.add(
            HabitModel(
              id: m.id,
              name: m.name,
              isCompleted: m.isCompleted,
              createdAt: m.createdAt,
              completedAt: m.completedAt,
              colorValue: m.colorValue,
              index: i,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }

      await localDataSource.saveHabits(reorderedModels);

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(reorderedModels).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error on updateHabitOrder: $e');
        }
      }
    });
  }

  @override
  bool isUserLoggedIn() {
    return firestoreService.isUserLoggedIn;
  }

  @override
  Future<Either<Failure, void>> updateHabitColor(
    String id,
    int colorValue,
  ) async {
    return NetworkErrorHandler.guard(() async {
      final models = localDataSource.loadHabits();
      final index = models.indexWhere((h) => h.id == id);
      if (index == -1) throw const CacheException('Habit not found');

      final m = models[index];
      models[index] = HabitModel(
        id: m.id,
        name: m.name,
        isCompleted: m.isCompleted,
        createdAt: m.createdAt,
        completedAt: m.completedAt,
        colorValue: colorValue,
        index: m.index,
        updatedAt: DateTime.now(),
      );

      await localDataSource.saveHabits(models);

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(models).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error on updateHabitColor: $e');
        }
      }
    });
  }

  @override
  List<String> getLocalTombstones() {
    return localDataSource.getLocalTombstones();
  }

  @override
  void clearLocalTombstones() {
    localDataSource.clearLocalTombstones();
  }

  @override
  Future<Either<Failure, DateTime?>> getLastResetDate() async {
    return NetworkErrorHandler.guard(() async {
      return await localDataSource.getLastResetDate();
    });
  }

  @override
  Future<Either<Failure, void>> saveLastResetDate(DateTime date) async {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.saveLastResetDate(date);
    });
  }

  @override
  Future<Either<Failure, void>> resetHabitsCompletion() async {
    return NetworkErrorHandler.guard(() async {
      final habits = await localDataSource.fetchHabitsFromDb();
      if (habits.isEmpty) return;

      final resetHabits = habits
          .map(
            (h) => HabitModel(
              id: h.id,
              name: h.name,
              isCompleted: false,
              createdAt: h.createdAt,
              completedAt: null,
              colorValue: h.colorValue,
              index: h.index,
              updatedAt: DateTime.now(),
            ),
          )
          .toList();

      await localDataSource.saveHabits(resetHabits);
      _cachedHeatmapData = null;

      if (firestoreService.isUserLoggedIn) {
        try {
          await firestoreService.uploadHabits(resetHabits).timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error on reset: $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, void>> incrementDayCount([int amount = 1]) async {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.incrementDayCount(amount);
    });
  }

  @override
  Future<Either<Failure, void>> saveHabitCompletionToHistory(
    String habitIdOrName,
    bool isCompleted,
    DateTime date, {
    String? habitName,
  }) async {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.saveHabitCompletionToHistory(
        habitIdOrName,
        isCompleted,
        date,
        habitName: habitName,
      );

      if (firestoreService.isUserLoggedIn) {
        final dateStr = convertDateTimeToString(date);
        try {
          await firestoreService
              .uploadHabitCompletion(habitIdOrName, dateStr, isCompleted)
              .timeout(_cloudTimeout);
        } catch (e) {
          debugPrint('Cloud sync error on saveHabitCompletionToHistory: $e');
        }
      }
    });
  }

  @override
  Future<Either<Failure, Map<String, int>>> getCompletionStatusForDate(
    DateTime date,
  ) async {
    return NetworkErrorHandler.guard(() async {
      return await localDataSource.getCompletionStatusForDate(date);
    });
  }

  @override
  Future<Either<Failure, Map<String, Map<DateTime, bool>>>> getHabitHistoryMap(
    int days,
  ) async {
    return NetworkErrorHandler.guard(() async {
      return await localDataSource.getHabitHistoryMap(days);
    });
  }

  @override
  String getStartDate() {
    return localDataSource.getStartDate();
  }

  @override
  Future<Either<Failure, void>> clearLocalData({
    String? earliestDateStr,
  }) async {
    return NetworkErrorHandler.guard(() async {
      await localDataSource.clearAllData(earliestDateStr: earliestDateStr);
      _cachedHeatmapData = null;
    });
  }

  @override
  Future<Either<Failure, void>> backupToVault({String? userId}) async {
    return NetworkErrorHandler.guard(() async {
      String? authUid;
      try {
        if (firestoreService.isUserLoggedIn) {
          authUid = FirebaseAuth.instance.currentUser?.uid;
        }
      } catch (_) {}

      final effectiveUid =
          userId ??
          authUid ??
          localDataSource.getLastUserId() ??
          'offline_user';

      final snapshot = await localDataSource.createSnapshot(
        userId: effectiveUid,
      );
      final vault = vaultDataSource ?? localDataSource.vaultDataSource;
      if (vault != null) {
        await vault.saveBackup(snapshot);
      }
    });
  }

  @override
  Future<Either<Failure, bool>> restoreFromVault({String? userId}) async {
    return NetworkErrorHandler.guard(() async {
      final vault = vaultDataSource ?? localDataSource.vaultDataSource;
      if (vault == null) return false;

      String? authUid;
      try {
        if (firestoreService.isUserLoggedIn) {
          authUid = FirebaseAuth.instance.currentUser?.uid;
        }
      } catch (_) {}

      final effectiveUid = userId ?? authUid;

      final snapshot = effectiveUid != null
          ? vault.getBackup(effectiveUid)
          : vault.getLatestBackup();

      if (snapshot != null) {
        await localDataSource.restoreFromSnapshot(snapshot);
        _cachedHeatmapData = null;
        return true;
      }
      return false;
    });
  }

  @override
  Future<Either<Failure, bool>> hasPendingVaultData({String? userId}) async {
    return NetworkErrorHandler.guard(() async {
      final vault = vaultDataSource ?? localDataSource.vaultDataSource;
      if (vault == null) return false;
      return vault.hasUnsyncedBackup(userId: userId);
    });
  }

  @override
  Future<Either<Failure, void>> markVaultSynced({String? userId}) async {
    return NetworkErrorHandler.guard(() async {
      final vault = vaultDataSource ?? localDataSource.vaultDataSource;
      if (vault != null) {
        String? authUid;
        try {
          if (firestoreService.isUserLoggedIn) {
            authUid = FirebaseAuth.instance.currentUser?.uid;
          }
        } catch (_) {}

        final effectiveUid =
            userId ??
            authUid ??
            localDataSource.getLastUserId() ??
            'offline_user';
        await vault.markBackupSynced(effectiveUid);
      }
    });
  }

  @override
  Future<Either<Failure, void>> clearVault({String? userId}) async {
    return NetworkErrorHandler.guard(() async {
      final vault = vaultDataSource ?? localDataSource.vaultDataSource;
      if (vault != null && userId != null) {
        await vault.clearBackup(userId);
      }
    });
  }
}
