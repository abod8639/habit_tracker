import 'package:drift/drift.dart';
import 'habits_table.dart';

@DataClassName('HabitCompletionRecord')
@TableIndex(name: 'idx_completions_date', columns: {#dateStr})
@TableIndex(
  name: 'idx_completions_habit_date',
  columns: {#habitId, #dateStr},
  unique: true,
)
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get dateStr => text()(); // e.g. 'YYYYMMDD'
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();
}
