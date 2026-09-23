import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';

Future<void> performSync(
  SyncController syncController,
  HabitController habitController,
) async {
  final habitsModels = habitController.habits
      .map((e) => HabitModel.fromEntity(e))
      .toList();
  final result = await syncController.manualSync(habitsModels);
  if (result != null) {
    await habitController.refreshData();
  }
}
