import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/plan_suggestion.dart';
import '../repositories/plan_repository.dart';

class GeneratePlanUseCase {
  final PlanRepository repository;

  GeneratePlanUseCase(this.repository);

  Future<Either<Failure, List<PlanSuggestion>>> call({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  }) {
    return repository.generatePlan(
      category: category,
      userAnswers: userAnswers,
    );
  }
}
