import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/plan_suggestion.dart';
import '../entities/question_entity.dart';

abstract class PlanRepository {
  List<QuestionEntity> getQuestions(PlanCategory category);

  Future<Either<Failure, List<PlanSuggestion>>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  });

  Future<Either<Failure, void>> savePlanHabits(List<String> habitNames);
}
