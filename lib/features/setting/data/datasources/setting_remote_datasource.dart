import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';

abstract class SettingRemoteDataSource {
  bool get isUserLoggedIn;
  Future<List<HabitModel>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  });
  Future<DateTime?> getLastSyncTime();
  Future<void> uploadCustomApiKey(String key);
  Future<String?> downloadCustomApiKey();
  Future<void> deleteCustomApiKey();
  Future<String?> getUserStartDay();
  Future<void> deleteAllUserData();
  Future<HabitHistoryCloudBundle> syncHabitHistoryWithCompletions({
    required Map<String, String> localRates,
    required Map<String, Map<String, bool>> localCompletions,
  });
}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
  final FirestoreService _firestoreService;

  SettingRemoteDataSourceImpl(this._firestoreService);

  @override
  bool get isUserLoggedIn => _firestoreService.isUserLoggedIn;

  @override
  Future<List<HabitModel>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  }) async {
    return await _firestoreService.syncHabits(
      localHabits,
      localTombstones: localTombstones ?? [],
      localStartDay: localStartDay,
    );
  }

  @override
  Future<DateTime?> getLastSyncTime() async {
    return await _firestoreService.getLastSyncTime();
  }

  @override
  Future<void> uploadCustomApiKey(String key) async {
    await _firestoreService.uploadCustomApiKey(key);
  }

  @override
  Future<String?> downloadCustomApiKey() async {
    return await _firestoreService.downloadCustomApiKey();
  }

  @override
  Future<void> deleteCustomApiKey() async {
    await _firestoreService.deleteCustomApiKey();
  }

  @override
  Future<void> deleteAllUserData() async {
    await _firestoreService.deleteAllUserData();
  }

  @override
  Future<String?> getUserStartDay() async {
    return await _firestoreService.getUserStartDay();
  }

  @override
  Future<HabitHistoryCloudBundle> syncHabitHistoryWithCompletions({
    required Map<String, String> localRates,
    required Map<String, Map<String, bool>> localCompletions,
  }) async {
    return await _firestoreService.syncHabitHistoryWithCompletions(
      localRates: localRates,
      localCompletions: localCompletions,
    );
  }
}
