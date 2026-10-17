import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/init/app_initializer.dart';
import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  try {
    return AppInitializer.database;
  } catch (_) {
    final db = AppDatabase(NativeDatabase.memory());
    ref.onDispose(() {
      db.close();
    });
    return db;
  }
});
