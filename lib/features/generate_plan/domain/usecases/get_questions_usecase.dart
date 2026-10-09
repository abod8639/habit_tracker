import '../entities/category_entity.dart';
import '../entities/question_entity.dart';
import '../repositories/plan_repository.dart';

class GetQuestionsUseCase {
  final PlanRepository repository;

  GetQuestionsUseCase(this.repository);

  List<QuestionEntity> call(PlanCategory category) {
    return repository.getQuestions(category);
  }
}
