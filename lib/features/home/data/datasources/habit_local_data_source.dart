import 'package:habit_tracker/features/home/data/datasources/habit_sql_local_data_source.dart';

/// Legacy alias for HabitSqlLocalDataSource using SQLite (Drift).
/// Pure SQLite/Drift local data source implementation preserving interface compatibility.
class HabitLocalDataSource extends HabitSqlLocalDataSource {
  HabitLocalDataSource(super.db, {super.vaultDataSource});
}
