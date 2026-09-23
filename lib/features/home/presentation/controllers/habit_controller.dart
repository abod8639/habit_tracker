import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/edit_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_heatmap_data_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_completion_status_for_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/toggle_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_color_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_order_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/clear_local_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_start_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/increment_day_count_usecase.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/core/functions/check_and_reset_habits.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:habit_tracker/features/home/data/models/date_time.dart';

class HabitController extends GetxController {
  // Use Cases
  final GetHabitsUseCase _getHabitsUseCase = Get.find();
  final AddHabitUseCase _addHabitUseCase = Get.find();
  final AddMultipleHabitsUseCase _addMultipleHabitsUseCase = Get.find();
  final EditHabitUseCase _editHabitUseCase = Get.find();
  final DeleteHabitUseCase _deleteHabitUseCase = Get.find();
  final ToggleHabitUseCase _toggleHabitUseCase = Get.find();
  final GetHeatmapDataUseCase _getHeatmapDataUseCase = Get.find();
  final IsUserLoggedInUseCase _isUserLoggedInUseCase = Get.find();
  final ResetDailyHabitsUseCase _resetDailyHabitsUseCase = Get.find();
  final UpdateHabitColorUseCase _updateHabitColorUseCase = Get.find();
  final UpdateHabitOrderUseCase _updateHabitOrderUseCase = Get.find();
  final GetCompletionStatusForDateUseCase _getCompletionStatusForDateUseCase =
      Get.find();
  final GetStartDateUseCase _getStartDateUseCase = Get.find();
  final IncrementDayCountUseCase _incrementDayCountUseCase = Get.find();
  final ClearLocalHabitsUseCase _clearLocalHabitsUseCase = Get.find();

  // State
  final RxList<HabitEntity> habits = <HabitEntity>[].obs;
  final RxMap<DateTime, int> localHeatmapDateSet = <DateTime, int>{}.obs;
  final RxMap<DateTime, int> remoteHeatmapDateSet = <DateTime, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInitialized = false.obs;

  // View Getter for UI (Combines both sources seamlessly)
  Map<DateTime, int> get heatmapDateSet => {
    ...remoteHeatmapDateSet,
    ...localHeatmapDateSet,
  };

  // UI State
  final TextEditingController habitTextController = TextEditingController();
  final RxList<String> selectedHabitIds = <String>[].obs;
  bool get isSelectionMode => selectedHabitIds.isNotEmpty;

  // Internal
  Timer? _resetCheckTimer;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initialize();
    _setupAuthListener();
  }

  Future<void> _initialize() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Perform initial reset check
      await _resetDailyHabitsUseCase();

      await _loadHabits();
      await _loadHeatmap();

      // Trigger sync if user is already logged in
      if (isUserLoggedIn()) {
        _syncOnLogin();
      }

      _setupHabitResetChecking();

      isInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Initialization failed: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _setupAuthListener() {
    bool wasLoggedIn = FirebaseAuth.instance.currentUser != null;
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) async {
      if (user != null && isInitialized.value) {
        wasLoggedIn = true;
        _syncOnLogin();
      } else if (user == null && wasLoggedIn && isInitialized.value) {
        wasLoggedIn = false;
        await resetToDefaultState();
      }
    });
  }

  /// Resets all habit data and heatmap state to default
  Future<void> resetToDefaultState() async {
    try {
      isLoading.value = true;
      final earliestDate = getStartDay();

      // 1. Clear in-memory observables
      remoteHeatmapDateSet.clear();
      localHeatmapDateSet.clear();
      habits.clear();
      selectedHabitIds.clear();

      // 2. Clear local storage database
      await _clearLocalHabitsUseCase(earliestDateStr: earliestDate);

      // 3. Refresh controller to clean default state
      await refreshData();
    } catch (e) {
      debugPrint('Error resetting habit state to default: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _syncOnLogin() async {
    if (!Get.isRegistered<SyncController>()) return;
    final syncController = Get.find<SyncController>();

    final result = await syncController.autoSync(
      habits.map((e) => HabitModel.fromEntity(e)).toList(),
    );
    if (result != null) {
      await refreshData();
    }
  }

  Future<void> _loadHabits() async {
    final result = await _getHabitsUseCase();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (loadedHabits) => habits.assignAll(loadedHabits),
    );
  }

  Future<void> _loadHeatmap() async {
    // Load local history fast for immediate UI rendering
    final result = await _getHeatmapDataUseCase();
    result.fold(
      (failure) => null,
      (data) => localHeatmapDateSet.assignAll(data),
    );

    // Fetch remote data in background to prevent UI stall
    _loadRemoteHeatmap();
  }

  Future<void> _loadRemoteHeatmap() async {
    if (!Get.isRegistered<FirestoreService>()) return;
    final firestoreService = Get.find<FirestoreService>();
    if (!firestoreService.isUserLoggedIn) return;

    try {
      final remoteData = await firestoreService.downloadHabitHistory();
      final Map<DateTime, int> parsed = {};

      for (var entry in remoteData.entries) {
        if (entry.key.length == 8) {
          final yyyy = int.parse(entry.key.substring(0, 4));
          final mm = int.parse(entry.key.substring(4, 6));
          final dd = int.parse(entry.key.substring(6, 8));
          final strength = double.tryParse(entry.value) ?? 0.0;
          parsed[DateTime(yyyy, mm, dd)] = (strength * 10).toInt();
        }
      }
      remoteHeatmapDateSet.assignAll(parsed);
    } catch (_) {
      // Background process, errors can be ignored safely
    }
  }

  void _setupHabitResetChecking() {
    _resetCheckTimer?.cancel();
    _resetCheckTimer = Timer.periodic(
      const Duration(minutes: 15),
      (_) => checkAndResetHabits(),
    );
  }

  String getStartDay() {
    String storedStartDay = _getStartDateUseCase();

    final combinedHeatmap = heatmapDateSet;

    // If we have heatmap data, find the earliest date
    if (combinedHeatmap.isNotEmpty) {
      DateTime minDate = combinedHeatmap.keys.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      String minDateStr = convertDateTimeToString(minDate);

      if (storedStartDay.isEmpty) return minDateStr;

      // Return the earlier of the two
      try {
        DateTime storedDate = createDateTimeObject(storedStartDay);
        return minDate.isBefore(storedDate) ? minDateStr : storedStartDay;
      } catch (e) {
        return minDateStr;
      }
    }

    return storedStartDay;
  }

  Future<void> incrementDayCount() async {
    await _incrementDayCountUseCase();
  }

  // --- Public Actions ---

  Future<void> addHabit(String name) async {
    if (name.trim().isEmpty) return;

    final result = await _addHabitUseCase(name);
    result.fold(
      (failure) => _showError(failure.message),
      (_) async {
        try {
          habitTextController.clear();
        } catch (_) {}
        await refreshData();
      },
    );
  }

  Future<bool> addMultipleHabits(List<String> names) async {
    if (names.isEmpty) return false;

    final result = await _addMultipleHabitsUseCase(names);
    return result.fold(
      (failure) {
        _showError(failure.message);
        return false;
      },
      (_) async {
        await refreshData();
        return true;
      },
    );
  }

  Future<void> editHabit(String id, String newName) async {
    if (newName.trim().isEmpty) return;

    final result = await _editHabitUseCase(id, newName);
    result.fold(
      (failure) => _showError(failure.message),
      (_) => _loadHabits(),
    );
  }

  Future<void> deleteHabit(String id) async {
    // 1. Optimistic UI update
    final int index = habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final oldHabit = habits[index];
    habits.removeAt(index);
    _updateOptimisticHeatmap();

    // 2. Perform background delete
    final result = await _deleteHabitUseCase(id);

    result.fold(
      (failure) {
        // 3. Rollback on failure
        habits.insert(index, oldHabit);
        _updateOptimisticHeatmap();
        _showError(failure.message);
      },
      (_) async {
        // 4. Background refresh
        await refreshData();
      },
    );
  }

  Future<void> toggleHabit(String id, bool value) async {
    // 1. Optimistic UI update
    final int index = habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final oldHabit = habits[index];
    habits[index] = oldHabit.copyWith(isCompleted: value);
    habits.refresh(); // Trigger Obx update immediately

    // 1.1 Optimistic Heatmap update
    _updateOptimisticHeatmap();

    // 2. Perform background update
    final result = await _toggleHabitUseCase(id, value);

    result.fold(
      (failure) {
        // 3. Rollback on failure
        habits[index] = oldHabit;
        habits.refresh();
        _updateOptimisticHeatmap();
        _showError(failure.message);
      },
      (_) async {
        // 4. Background refresh to ensure everything is in sync (like Heatmap)
        await refreshData();
      },
    );
  }

  void _updateOptimisticHeatmap() {
    final today = createDateTimeObject(todaysDateFormatted());
    final total = habits.length;
    final completed = habits.where((h) => h.isCompleted).length;

    if (total == 0) {
      localHeatmapDateSet.remove(today);
    } else {
      double rate = completed / total;
      int strength = (rate * 10).toInt();
      if (strength == 0 && completed > 0)
        strength = 1; // Show at least something if partially completed
      localHeatmapDateSet[today] = strength;
    }
  }

  Future<void> reorderHabits(
    int oldIndex,
    int newIndex, {
    bool isAdjusted = false,
  }) async {
    // 1. Optimistic UI update
    if (!isAdjusted && newIndex > oldIndex) {
      newIndex -= 1;
    }

    final draggedItem = habits[oldIndex];
    final isDraggedItemSelected = selectedHabitIds.contains(draggedItem.id);

    if (isDraggedItemSelected && selectedHabitIds.length > 1) {
      // Group reorder: Move all selected habits together to the target position
      // Get all selected habits in their CURRENT list order
      final selectedItems = habits
          .where((h) => selectedHabitIds.contains(h.id))
          .toList();

      // Remove all selected items
      habits.removeWhere((h) => selectedHabitIds.contains(h.id));

      // Calculate a safe insertion index based on the remaining items
      final insertIndex = newIndex.clamp(0, habits.length);
      habits.insertAll(insertIndex, selectedItems);
    } else {
      // Single reorder
      final item = habits.removeAt(oldIndex);
      habits.insert(newIndex, item);
    }

    habits.refresh();

    // 2. Perform background reorder
    final result = await _updateHabitOrderUseCase(
      habits.map((h) => h.id).toList(),
    );

    result.fold(
      (failure) {
        // 3. Rollback on failure
        _loadHabits();
        _showError(failure.message);
      },
      (_) => null, // Successfully saved the new order
    );
  }

  // --- Multi-selection ---

  void toggleHabitSelection(String id) {
    if (selectedHabitIds.contains(id)) {
      selectedHabitIds.remove(id);
    } else {
      selectedHabitIds.add(id);
    }
  }

  void clearSelection() => selectedHabitIds.clear();

  Future<void> deleteSelectedHabits() async {
    for (final id in List.from(selectedHabitIds)) {
      await deleteHabit(id);
    }
    clearSelection();
  }

  Future<void> updateSelectedHabitsColor(Color color) async {
    final idsToUpdate = List<String>.from(selectedHabitIds);
    final colorValue = color.toARGB32();

    for (final id in idsToUpdate) {
      final result = await _updateHabitColorUseCase(id, colorValue);
      result.fold(
        (failure) => _showError(failure.message),
        (_) => null,
      );
    }

    clearSelection();
    await refreshData();
  }

  Future<Map<String, int>> getCompletionStatusForDate(DateTime date) async {
    final result = await _getCompletionStatusForDateUseCase(date);
    return result.fold(
      (failure) => {'total': 0, 'completed': 0},
      (data) => data,
    );
  }

  Future<void> refreshData() async {
    await _loadHabits();
    await _loadHeatmap();
  }

  void _showError(String message) {
    Get.snackbar(S.current.error, message, snackPosition: SnackPosition.BOTTOM);
  }

  bool isUserLoggedIn() => _isUserLoggedInUseCase();

  @override
  void onClose() {
    _authSubscription?.cancel();
    _resetCheckTimer?.cancel();
    habitTextController.dispose();
    super.onClose();
  }
}
