import 'package:get/get.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/domain/repositories/habit_repository.dart';
import '../../data/datasources/plan_remote_datasource.dart';
import '../../data/repositories/plan_repository_impl.dart';
import '../../domain/repositories/plan_repository.dart';
import '../../domain/usecases/generate_plan_usecase.dart';
import '../../domain/usecases/get_questions_usecase.dart';
import '../../domain/usecases/save_plan_habits_usecase.dart';
import 'plan_generator_controller.dart';

class PlanGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GeminiService>()) {
      Get.lazyPut(() => GeminiService());
    }

    Get.lazyPut<PlanRemoteDataSource>(
      () => PlanRemoteDataSourceImpl(geminiService: Get.find<GeminiService>()),
    );

    Get.lazyPut<PlanRepository>(
      () => PlanRepositoryImpl(
        remoteDataSource: Get.find<PlanRemoteDataSource>(),
        habitRepository: Get.find<HabitRepository>(),
      ),
    );

    Get.lazyPut(() => GetQuestionsUseCase(Get.find<PlanRepository>()));
    Get.lazyPut(() => GeneratePlanUseCase(Get.find<PlanRepository>()));
    Get.lazyPut(() => SavePlanHabitsUseCase(Get.find<PlanRepository>()));

    Get.lazyPut(
      () => PlanGeneratorController(
        getQuestionsUseCase: Get.find<GetQuestionsUseCase>(),
        generatePlanUseCase: Get.find<GeneratePlanUseCase>(),
        savePlanHabitsUseCase: Get.find<SavePlanHabitsUseCase>(),
      ),
      fenix: true,
    );
  }
}
