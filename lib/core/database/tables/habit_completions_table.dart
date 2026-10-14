import 'package:drift/drift.dart';
import 'habits_table.dart';

@DataClassName('HabitCompletionRecord')
@TableIndex(name: 'idx_completions_date', columns: {#dateStr})
class HabitCompletions extends Table {
  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get dateStr => text()(); // e.g. 'YYYYMMDD'
  BoolColumn get isCompleted => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {habitId, dateStr};
}
