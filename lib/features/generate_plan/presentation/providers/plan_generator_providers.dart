import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/providers/core_providers.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/generate_plan/data/datasources/plan_remote_datasource.dart';
import 'package:habit_tracker/features/generate_plan/data/repositories/plan_repository_impl.dart';
import 'package:habit_tracker/features/generate_plan/domain/repositories/plan_repository.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/generate_plan_usecase.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/get_questions_usecase.dart';
import 'package:habit_tracker/features/generate_plan/domain/usecases/save_plan_habits_usecase.dart';

// Data Sources
final planRemoteDataSourceProvider = Provider<PlanRemoteDataSource>((ref) {
  final gemini = ref.watch(geminiServiceProvider);
  return PlanRemoteDataSourceImpl(geminiService: gemini);
});

// Repository
final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final remote = ref.watch(planRemoteDataSourceProvider);
  final habitRepo = ref.watch(habitRepositoryProvider);
  return PlanRepositoryImpl(
    remoteDataSource: remote,
    habitRepository: habitRepo,
  );
});

// Use Cases
final getQuestionsUseCaseProvider = Provider<GetQuestionsUseCase>((ref) {
  return GetQuestionsUseCase(ref.watch(planRepositoryProvider));
});

final generatePlanUseCaseProvider = Provider<GeneratePlanUseCase>((ref) {
  return GeneratePlanUseCase(ref.watch(planRepositoryProvider));
});

final savePlanHabitsUseCaseProvider = Provider<SavePlanHabitsUseCase>((ref) {
  return SavePlanHabitsUseCase(ref.watch(planRepositoryProvider));
});
