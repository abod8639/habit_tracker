import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/contracts/habit_facade_contract.dart';
import 'package:habit_tracker/core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/plan_suggestion.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import '../datasources/plan_remote_datasource.dart';
import '../datasources/questions_datasource.dart';

class PlanRepositoryImpl implements PlanRepository {
  final PlanRemoteDataSource remoteDataSource;
  final IHabitFacade habitFacade;

  PlanRepositoryImpl({
    required this.remoteDataSource,
    required this.habitFacade,
  });

  @override
  List<QuestionEntity> getQuestions(PlanCategory category) {
    return QuestionsDataSource.forCategory(category);
  }

  @override
  Future<Either<Failure, List<PlanSuggestion>>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  }) async {
    try {
      final suggestions = await remoteDataSource.generatePlan(
        category: category,
        userAnswers: userAnswers,
      );
      return Right(suggestions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePlanHabits(List<String> habitNames) async {
    try {
      await habitFacade.addHabits(habitNames);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
