import 'package:get/get.dart';
import 'package:habit_tracker/features/home/data/datasources/habit_local_data_source.dart';
import 'package:habit_tracker/features/home/data/repositories/habit_repository_impl.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/add_multiple_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/delete_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/edit_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_heatmap_data_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/is_user_logged_in_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reorder_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/toggle_habit_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/reset_daily_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_completion_status_for_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_color_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/update_habit_order_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/get_start_date_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/clear_local_habits_usecase.dart';
import 'package:habit_tracker/features/home/domain/usecases/increment_day_count_usecase.dart';
import 'package:habit_tracker/core/services/firestore_service.dart';
import 'package:hive/hive.dart';
import '../controllers/habit_controller.dart';
import '../../data/datasources/habit_storage.dart';

class HabitBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    final box = Hive.box(HabitStorage.boxName);
    Get.lazyPut(() => HabitLocalDataSource(box));
    Get.lazyPut(() => FirestoreService());
    

    // Repository
    Get.lazyPut<HabitRepository>(
      () => HabitRepositoryImpl(
        localDataSource: Get.find(),
        firestoreService: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetHabitsUseCase(Get.find()));
    Get.lazyPut(() => AddHabitUseCase(Get.find()));
    Get.lazyPut(() => AddMultipleHabitsUseCase(Get.find()));
    Get.lazyPut(() => EditHabitUseCase(Get.find()));
    Get.lazyPut(() => DeleteHabitUseCase(Get.find()));
    Get.lazyPut(() => ToggleHabitUseCase(Get.find()));
    Get.lazyPut(() => ReorderHabitsUseCase(Get.find()));
    Get.lazyPut(() => GetHeatmapDataUseCase(Get.find()));
    Get.lazyPut(() => IsUserLoggedInUseCase(Get.find()));
    Get.lazyPut(() => UpdateHabitColorUseCase(repository: Get.find()));
    Get.lazyPut(() => UpdateHabitOrderUseCase(repository: Get.find()));
    Get.lazyPut(() => ResetDailyHabitsUseCase(Get.find()));
    Get.lazyPut(() => GetCompletionStatusForDateUseCase(Get.find()));
    Get.lazyPut(() => GetStartDateUseCase(Get.find()));
    Get.lazyPut(() => IncrementDayCountUseCase(Get.find()));
    Get.lazyPut(() => ClearLocalHabitsUseCase(Get.find()));


    // Controller
    Get.lazyPut(() => HabitController());
  }
}
