import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_offline_vault_datasource.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';
import 'package:habit_tracker/features/home/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/clear_local_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/edit_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_completion_status_for_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_heatmap_data_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_start_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/increment_day_count_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reorder_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/toggle_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_color_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_order_usecase.dart';
import 'habit_state.dart';

import 'package:habit_tracker/core/database/database_provider.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_sql_local_data_source.dart';
import 'package:habit_tracker/features/home/data/datasources/i_habit_local_data_source.dart';

// Data Sources
final habitVaultDataSourceProvider = Provider<HabitOfflineVaultDataSource>((ref) {
  final storage = ref.watch(keyValueStorageProvider);
  return HabitOfflineVaultDataSource(storage);
});

final habitSqlLocalDataSourceProvider = Provider<HabitSqlLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final vaultDataSource = ref.watch(habitVaultDataSourceProvider);
  return HabitSqlLocalDataSource(db, vaultDataSource: vaultDataSource);
});

final habitLocalDataSourceProvider = Provider<IHabitLocalDataSource>((ref) {
  return ref.watch(habitSqlLocalDataSourceProvider);
});

// Repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final localDataSource = ref.watch(habitLocalDataSourceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final vaultDataSource = ref.watch(habitVaultDataSourceProvider);
  return HabitRepositoryImpl(
    localDataSource: localDataSource,
    firestoreService: firestoreService,
    vaultDataSource: vaultDataSource,
  );
});

// Use Cases
final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>((ref) {
  return GetHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final addHabitUseCaseProvider = Provider<AddHabitUseCase>((ref) {
  return AddHabitUseCase(ref.watch(habitRepositoryProvider));
});

final addMultipleHabitsUseCaseProvider = Provider<AddMultipleHabitsUseCase>((ref) {
  return AddMultipleHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final editHabitUseCaseProvider = Provider<EditHabitUseCase>((ref) {
  return EditHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteHabitUseCaseProvider = Provider<DeleteHabitUseCase>((ref) {
  return DeleteHabitUseCase(ref.watch(habitRepositoryProvider));
});

final deleteMultipleHabitsUseCaseProvider = Provider<DeleteMultipleHabitsUseCase>((ref) {
  return DeleteMultipleHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final toggleHabitUseCaseProvider = Provider<ToggleHabitUseCase>((ref) {
  return ToggleHabitUseCase(ref.watch(habitRepositoryProvider));
});

final reorderHabitsUseCaseProvider = Provider<ReorderHabitsUseCase>((ref) {
  return ReorderHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final getHeatmapDataUseCaseProvider = Provider<GetHeatmapDataUseCase>((ref) {
  return GetHeatmapDataUseCase(ref.watch(habitRepositoryProvider));
});

final isUserLoggedInUseCaseProvider = Provider<IsUserLoggedInUseCase>((ref) {
  return IsUserLoggedInUseCase(ref.watch(habitRepositoryProvider));
});

final updateHabitColorUseCaseProvider = Provider<UpdateHabitColorUseCase>((ref) {
  return UpdateHabitColorUseCase(repository: ref.watch(habitRepositoryProvider));
});

final updateHabitOrderUseCaseProvider = Provider<UpdateHabitOrderUseCase>((ref) {
  return UpdateHabitOrderUseCase(repository: ref.watch(habitRepositoryProvider));
});

final resetDailyHabitsUseCaseProvider = Provider<ResetDailyHabitsUseCase>((ref) {
  return ResetDailyHabitsUseCase(ref.watch(habitRepositoryProvider));
});

final getCompletionStatusForDateUseCaseProvider =
    Provider<GetCompletionStatusForDateUseCase>((ref) {
  return GetCompletionStatusForDateUseCase(ref.watch(habitRepositoryProvider));
});

final getStartDateUseCaseProvider = Provider<GetStartDateUseCase>((ref) {
  return GetStartDateUseCase(ref.watch(habitRepositoryProvider));
});

final incrementDayCountUseCaseProvider = Provider<IncrementDayCountUseCase>((ref) {
  return IncrementDayCountUseCase(ref.watch(habitRepositoryProvider));
});

final clearLocalHabitsUseCaseProvider = Provider<ClearLocalHabitsUseCase>((ref) {
  return ClearLocalHabitsUseCase(ref.watch(habitRepositoryProvider));
});

// Habit Notifier
class HabitNotifier extends Notifier<HabitState> {
  Timer? _resetCheckTimer;

  @override
  HabitState build() {
    _resetCheckTimer?.cancel();
    _resetCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => checkAndResetDailyHabits(),
    );

    ref.onDispose(() {
      _resetCheckTimer?.cancel();
    });

    Future.microtask(() => _initialize());

    return const HabitState();
  }

  Future<void> retry() => _initialize();

  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');
      final resetDaily = ref.read(resetDailyHabitsUseCaseProvider);
      await resetDaily();

      await _loadHabits();
      await _loadHeatmap();

      _updateHomeWidget();
      state = state.copyWith(isInitialized: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Initialization failed: $e',
      );
    }
  }

  Future<void> _loadHabits() async {
    final getHabits = ref.read(getHabitsUseCaseProvider);
    final result = await getHabits();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (loaded) => state = state.copyWith(habits: loaded),
    );
  }

  Future<void> _loadHeatmap() async {
    final getHeatmap = ref.read(getHeatmapDataUseCaseProvider);
    final result = await getHeatmap();
    result.fold(
      (_) => null,
      (data) => state = state.copyWith(localHeatmapDateSet: data),
    );

    _loadRemoteHeatmap();
  }

  Future<void> _loadRemoteHeatmap() async {
    final firestore = ref.read(firestoreServiceProvider);
    if (!firestore.isUserLoggedIn) return;

    try {
      final remoteData = await firestore.downloadHabitHistory();
      final Map<DateTime, int> parsed = {};

      for (var entry in remoteData.entries) {
        if (entry.key.length == 8) {
          final yyyy = int.parse(entry.key.substring(0, 4));
          final mm = int.parse(entry.key.substring(4, 6));
          final dd = int.parse(entry.key.substring(6, 8));
          final strength = double.tryParse(entry.value) ?? 0.0;
          int parsedStrength = (strength * 10).toInt();
          if (parsedStrength == 0 && strength > 0) {
            parsedStrength = 1;
          }
          parsed[DateTime(yyyy, mm, dd)] = parsedStrength;
        }
      }
      state = state.copyWith(remoteHeatmapDateSet: parsed);
    } catch (_) {}
  }

  Future<void> checkAndResetDailyHabits() async {
    final resetUseCase = ref.read(resetDailyHabitsUseCaseProvider);
    final result = await resetUseCase();
    result.fold((_) => null, (_) => refreshData());
  }

  Future<void> refreshData() async {
    await _loadHabits();
    await _loadHeatmap();
    _updateHomeWidget();
  }

  Future<void> addHabit(String name) async {
    if (name.trim().isEmpty) return;
    final addUseCase = ref.read(addHabitUseCaseProvider);
    final result = await addUseCase(name);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => refreshData(),
    );
  }

  Future<bool> addMultipleHabits(List<String> names) async {
    if (names.isEmpty) return false;
    final addUseCase = ref.read(addMultipleHabitsUseCaseProvider);
    final result = await addUseCase(names);
    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) async {
        await refreshData();
        return true;
      },
    );
  }

  Future<void> editHabit(String id, String newName) async {
    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) return;

    final currentHabits = List<HabitEntity>.from(state.habits);
    final index = currentHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final oldHabit = currentHabits[index];
    if (oldHabit.name == trimmedName) return;

    currentHabits[index] = oldHabit.copyWith(name: trimmedName);
    state = state.copyWith(habits: currentHabits);

    final editUseCase = ref.read(editHabitUseCaseProvider);
    final result = await editUseCase(id, trimmedName);
    await result.fold(
      (failure) async {
        currentHabits[index] = oldHabit;
        state = state.copyWith(
          habits: currentHabits,
          errorMessage: failure.message,
        );
      },
      (_) async => refreshData(),
    );
  }

  Future<void> deleteHabit(String id) async {
    final currentHabits = List<HabitEntity>.from(state.habits);
    final index = currentHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final oldHabit = currentHabits[index];
    currentHabits.removeAt(index);
    state = state.copyWith(habits: currentHabits);
    _updateOptimisticHeatmap();

    final deleteUseCase = ref.read(deleteHabitUseCaseProvider);
    final result = await deleteUseCase(id);

    result.fold(
      (failure) {
        currentHabits.insert(index, oldHabit);
        state = state.copyWith(habits: currentHabits, errorMessage: failure.message);
        _updateOptimisticHeatmap();
      },
      (_) => refreshData(),
    );
  }

  Future<void> toggleHabit(String id, bool value) async {
    final currentHabits = List<HabitEntity>.from(state.habits);
    final index = currentHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final oldHabit = currentHabits[index];
    currentHabits[index] = oldHabit.copyWith(isCompleted: value);
    state = state.copyWith(habits: currentHabits);
    _updateOptimisticHeatmap();
    _updateHomeWidget();

    final toggleUseCase = ref.read(toggleHabitUseCaseProvider);
    final result = await toggleUseCase(id, value);

    result.fold(
      (failure) {
        currentHabits[index] = oldHabit;
        state = state.copyWith(habits: currentHabits, errorMessage: failure.message);
        _updateOptimisticHeatmap();
        _updateHomeWidget();
      },
      (_) => refreshData(),
    );
  }

  void _updateOptimisticHeatmap() {
    final today = createDateTimeObject(todaysDateFormatted());
    final total = state.habits.length;
    final completed = state.habits.where((h) => h.isCompleted).length;

    final updatedLocal = Map<DateTime, int>.from(state.localHeatmapDateSet);
    if (total == 0) {
      updatedLocal.remove(today);
    } else {
      double rate = completed / total;
      int strength = (rate * 10).toInt();
      if (strength == 0 && completed > 0) {
        strength = 1;
      }
      updatedLocal[today] = strength;
    }
    state = state.copyWith(localHeatmapDateSet: updatedLocal);
  }

  Future<void> reorderHabits(int oldIndex, int newIndex, {bool isAdjusted = false}) async {
    if (!isAdjusted && newIndex > oldIndex) {
      newIndex -= 1;
    }
    final currentHabits = List<HabitEntity>.from(state.habits);
    final selectedIds = state.selectedHabitIds;

    final draggedItem = currentHabits[oldIndex];
    if (selectedIds.contains(draggedItem.id) && selectedIds.length > 1) {
      final selectedItems = currentHabits.where((h) => selectedIds.contains(h.id)).toList();
      currentHabits.removeWhere((h) => selectedIds.contains(h.id));
      final insertIndex = newIndex.clamp(0, currentHabits.length);
      currentHabits.insertAll(insertIndex, selectedItems);
    } else {
      final item = currentHabits.removeAt(oldIndex);
      currentHabits.insert(newIndex, item);
    }

    state = state.copyWith(habits: currentHabits);

    final updateOrder = ref.read(updateHabitOrderUseCaseProvider);
    final result = await updateOrder(currentHabits.map((h) => h.id).toList());
    result.fold((_) => _loadHabits(), (_) => null);
  }

  void toggleHabitSelection(String id) {
    final current = List<String>.from(state.selectedHabitIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(selectedHabitIds: current);
  }

  void clearSelection() {
    state = state.copyWith(selectedHabitIds: const []);
  }

  Future<void> deleteSelectedHabits() async {
    final idsToDelete = List<String>.from(state.selectedHabitIds);
    if (idsToDelete.isEmpty) return;

    clearSelection();
    final currentHabits = List<HabitEntity>.from(state.habits);
    currentHabits.removeWhere((h) => idsToDelete.contains(h.id));
    state = state.copyWith(habits: currentHabits);
    _updateOptimisticHeatmap();

    final deleteMultiple = ref.read(deleteMultipleHabitsUseCaseProvider);
    final result = await deleteMultiple(idsToDelete);
    result.fold(
      (failure) => refreshData(),
      (_) => refreshData(),
    );
  }

  Future<void> updateSelectedHabitsColor(Color color) async {
    final ids = List<String>.from(state.selectedHabitIds);
    final colorValue = color.toARGB32();
    final updateColor = ref.read(updateHabitColorUseCaseProvider);

    for (final id in ids) {
      await updateColor(id, colorValue);
    }
    clearSelection();
    await refreshData();
  }

  Future<Map<String, int>> getCompletionStatusForDate(DateTime date) async {
    final useCase = ref.read(getCompletionStatusForDateUseCaseProvider);
    final result = await useCase(date);
    return result.fold((_) => {'total': 0, 'completed': 0}, (d) => d);
  }

  String getStartDay() {
    final getStart = ref.read(getStartDateUseCaseProvider);
    return state.getStartDay(getStart());
  }

  Future<void> resetToDefaultState({bool backupFirst = true}) async {
    state = state.copyWith(isLoading: true);
    final earliestDate = getStartDay();
    if (backupFirst) {
      final repo = ref.read(habitRepositoryProvider);
      await repo.backupToVault();
    }
    final clearUseCase = ref.read(clearLocalHabitsUseCaseProvider);
    await clearUseCase(earliestDateStr: earliestDate);
    state = const HabitState();
    await refreshData();
  }

  void _updateHomeWidget() {
    final homeWidget = ref.read(homeWidgetServiceProvider);
    homeWidget.updateWidget(
      habits: state.habits,
      heatmapData: state.heatmapDateSet,
    );
  }
}

final habitNotifierProvider = NotifierProvider<HabitNotifier, HabitState>(() {
  return HabitNotifier();
});
