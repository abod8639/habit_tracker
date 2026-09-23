import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';

abstract class SettingRemoteDataSource {
  Future<List<HabitModel>> syncHabits(
    List<HabitModel> localHabits, {
    List<String>? localTombstones,
    String? localStartDay,
  });
  Future<DateTime?> getLastSyncTime();
}

class SettingRemoteDataSourceImpl implements SettingRemoteDataSource {
  final FirestoreService _firestoreService;

  SettingRemoteDataSourceImpl(this._firestoreService);

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
}
