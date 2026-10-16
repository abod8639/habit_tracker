// Language storage constants and helpers
import 'package:habit_tracker/core/storage/key_value_storage.dart';

class LangStorage {
  static const String boxName = "Lang_db";
  static const String languageKey = "CURRENT_LANGUAGE";
  static const String defaultLanguage = "sys";

  final KeyValueStorage _storage;

  LangStorage(this._storage);

  String getCurrentLanguage() {
    return _storage.getString(languageKey, defaultValue: defaultLanguage)!;
  }

  Future<void> saveLanguage(String languageCode) async {
    await _storage.setString(languageKey, languageCode);
  }

  Future<void> clear() async {
    await _storage.remove(languageKey);
  }
}
