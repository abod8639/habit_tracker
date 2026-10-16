import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:habit_tracker/core/database/app_database.dart';

/// Fast, in-memory cached Key-Value storage backed by SQLite (AppDatabase/AppMetadata).
/// Replaces Hive boxes with zero external dependencies and instant O(1) synchronous reads.
class KeyValueStorage {
  final AppDatabase _db;
  final Map<String, String> _cache = {};
  bool _isInitialized = false;

  KeyValueStorage(this._db);

  /// Pre-loads all stored key-value pairs into memory during app bootstrap.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final records = await _db.select(_db.appMetadata).get();
      for (final r in records) {
        _cache[r.key] = r.value;
      }
      _isInitialized = true;
    } catch (_) {
      // Allow fallback if database table is being created
    }
  }

  /// Synchronous instant lookup for string values.
  String? getString(String key, {String? defaultValue}) {
    return _cache[key] ?? defaultValue;
  }

  /// Sets a string value with immediate in-memory update and asynchronous SQLite persistence.
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _db.into(_db.appMetadata).insertOnConflictUpdate(
          AppMetadataCompanion(
            key: Value(key),
            value: Value(value),
          ),
        );
  }

  /// Synchronous instant lookup for boolean values.
  bool getBool(String key, {bool defaultValue = false}) {
    final val = _cache[key];
    if (val == null) return defaultValue;
    return val == 'true' || val == '1';
  }

  /// Sets a boolean value.
  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }

  /// Synchronous instant lookup for integer values.
  int? getInt(String key, {int? defaultValue}) {
    final val = _cache[key];
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  /// Sets an integer value.
  Future<void> setInt(String key, int value) async {
    await setString(key, value.toString());
  }

  /// Synchronous instant lookup for JSON objects.
  Map<String, dynamic>? getJson(String key) {
    final val = _cache[key];
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  /// Synchronous instant lookup for JSON lists.
  List<dynamic>? getJsonList(String key) {
    final val = _cache[key];
    if (val == null) return null;
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) return decoded;
    } catch (_) {}
    return null;
  }

  /// Sets any JSON serializable object.
  Future<void> setJson(String key, dynamic value) async {
    final jsonStr = jsonEncode(value);
    await setString(key, jsonStr);
  }

  /// Removes a key from both memory and SQLite storage.
  Future<void> remove(String key) async {
    _cache.remove(key);
    await (_db.delete(_db.appMetadata)..where((t) => t.key.equals(key))).go();
  }

  /// Clears all keys from memory and SQLite storage.
  Future<void> clear() async {
    _cache.clear();
    await _db.delete(_db.appMetadata).go();
  }
}
