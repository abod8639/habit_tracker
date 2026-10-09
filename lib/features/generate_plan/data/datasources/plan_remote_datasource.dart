import 'package:habit_tracker/core/services/gemini_service.dart';
import '../../domain/entities/category_entity.dart';
import '../models/plan_suggestion_model.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  });
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final GeminiService geminiService;

  PlanRemoteDataSourceImpl({required this.geminiService});

  @override
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  }) async {
    final stringAnswers = userAnswers.map((k, v) => MapEntry(k, v.toString()));
    final rawSuggestions = await geminiService.generatePlan(
      category: category,
      userAnswers: stringAnswers,
    );
    return rawSuggestions.map(PlanSuggestionModel.fromEntity).toList();
  }
}
