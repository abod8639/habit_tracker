import 'package:habit_tracker/core/storage/key_value_storage.dart';
import 'package:habit_tracker/features/home/data/models/habit_vault_data.dart';

/// Persistent offline vault datasource that safeguards habit data, streaks,
/// and completion history across sessions, logouts, token expiries, and offline usage.
/// Backed by SQLite (via KeyValueStorage) with zero Hive dependencies.
class HabitOfflineVaultDataSource {
  final KeyValueStorage _storage;

  HabitOfflineVaultDataSource(this._storage);

  static const String _latestUserKey = 'latest_vault_user_id';
  static const String _pendingListKey = 'pending_vault_user_ids';

  String _getKey(String userId) => 'vault_data_$userId';

  /// Saves a complete habit snapshot into the offline vault.
  Future<void> saveBackup(HabitVaultData data) async {
    final key = _getKey(data.userId);
    await _storage.setJson(key, data.toMap());
    await _storage.setString(_latestUserKey, data.userId);

    // Track list of users with pending data
    final List<String> pendingUsers = getPendingUserIds();
    if (!pendingUsers.contains(data.userId)) {
      pendingUsers.add(data.userId);
      await _storage.setJson(_pendingListKey, pendingUsers);
    }
  }

  /// Retrieves the saved snapshot for a specific user ID.
  HabitVaultData? getBackup(String userId) {
    final key = _getKey(userId);
    final raw = _storage.getJson(key);
    if (raw != null) {
      return HabitVaultData.fromMap(raw);
    }
    return null;
  }

  /// Retrieves the most recent snapshot regardless of user ID.
  HabitVaultData? getLatestBackup() {
    final latestUserId = _storage.getString(_latestUserKey);
    if (latestUserId != null && latestUserId.isNotEmpty) {
      return getBackup(latestUserId);
    }
    final pending = getPendingUserIds();
    if (pending.isNotEmpty) {
      return getBackup(pending.last);
    }
    return null;
  }

  /// Checks if there is an unsynced backup waiting in the vault.
  bool hasUnsyncedBackup({String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      final backup = getBackup(userId);
      return backup != null && !backup.isSynced;
    }

    final pending = getPendingUserIds();
    for (final uid in pending) {
      final backup = getBackup(uid);
      if (backup != null && !backup.isSynced) {
        return true;
      }
    }
    return false;
  }

  /// Marks the backup for a user as successfully synchronized with cloud.
  Future<void> markBackupSynced(String userId) async {
    final backup = getBackup(userId);
    if (backup != null) {
      final updated = HabitVaultData(
        userId: backup.userId,
        habits: backup.habits,
        habitStrengths: backup.habitStrengths,
        startDay: backup.startDay,
        dayCount: backup.dayCount,
        lastResetDate: backup.lastResetDate,
        tombstones: backup.tombstones,
        backedUpAt: backup.backedUpAt,
        isSynced: true,
      );
      await _storage.setJson(_getKey(userId), updated.toMap());

      final List<String> pendingUsers = getPendingUserIds();
      pendingUsers.remove(userId);
      await _storage.setJson(_pendingListKey, pendingUsers);
    }
  }

  /// Removes the user's snapshot from the vault.
  Future<void> clearBackup(String userId) async {
    await _storage.remove(_getKey(userId));
    final List<String> pendingUsers = getPendingUserIds();
    pendingUsers.remove(userId);
    await _storage.setJson(_pendingListKey, pendingUsers);
  }

  /// Returns all user IDs that have pending backups in the vault.
  List<String> getPendingUserIds() {
    final raw = _storage.getJsonList(_pendingListKey);
    if (raw != null) {
      return raw.map((e) => e.toString()).toList();
    }
    return [];
  }
}
