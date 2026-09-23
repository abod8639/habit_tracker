import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';

/// Check if habits need to be reset for a new day
Future<void> checkAndResetHabits() async {
  if (!Get.isRegistered<HabitController>()) return;
  final HabitController c = Get.find<HabitController>();

  try {
    final resetDailyHabitsUseCase = Get.find<ResetDailyHabitsUseCase>();
    final result = await resetDailyHabitsUseCase();

    result.fold(
      (failure) => null, // Silently fail for background check
      (_) async {
        // If reset happened, we need to refresh the controller's state
        await c.refreshData();
      },
    );
  } catch (e) {
    // Error handling
  }
}
