import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import '../../domain/entities/category_entity.dart';
import '../models/plan_suggestion_model.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  });
}

/// Dedicated remote AI service for generating personalized habit plans via Gemini.
class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final GeminiService geminiService;

  PlanRemoteDataSourceImpl({required this.geminiService});

  @override
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
  }) async {
    final stringAnswers = userAnswers.map((k, v) => MapEntry(k, v.toString()));
    final prompt = _buildPlanPrompt(category, stringAnswers);

    try {
      final model = geminiService.createModel(
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parsePlanResponse(text, category);
    } catch (e) {
      GeminiService.handleException(e, 'generating plan');
    }
  }

  /// Builds a structured prompt instructing Gemini to return strict JSON habits.
  String _buildPlanPrompt(
    PlanCategory category,
    Map<String, String> answers,
  ) {
    final answersBlock = answers.entries
        .map((e) => '  - ${e.key.replaceAll("_", " ")}: ${e.value}')
        .join('\n');

    final isArabic = Get.isRegistered<LangController>()
        ? Get.find<LangController>().isArabic
        : ((Get.locale?.languageCode ?? Intl.getCurrentLocale()).startsWith(
            'ar',
          ));

    final languageInstruction = isArabic
        ? 'LANGUAGE REQUIREMENT: Generate all habit "name" and "description" fields in natural, high-quality Arabic (اللغة العربية). The "frequency" field must also be in Arabic (e.g. "يومياً" or "3 مرات في الأسبوع").'
        : 'LANGUAGE REQUIREMENT: Generate all habit "name", "description", and "frequency" fields in English.';

    return '''
You are a ${category.coachRole}. A user is setting up a habit tracker and needs a personalised action plan.

CATEGORY: ${category.displayName}

USER PROFILE:
$answersBlock

YOUR TASK:
Generate between 5 and 8 specific, measurable, and achievable daily/weekly habits tailored to this exact user profile. Each habit should directly address their stated goal and personal context.

STRICT OUTPUT FORMAT — return ONLY a raw JSON array, no markdown, no explanation, no text before or after the array:
[
  {
    "name": "Short habit name (max 7 words)",
    "description": "1-2 sentences explaining why this specific habit helps THIS user reach their goal.",
    "frequency": "daily OR X times per week",
    "category": "${category.name}"
  }
]

RULES:
- $languageInstruction
- Habits must be actionable and time-bound where possible (e.g., "Drink 500ml water every morning" not "Drink more water").
- Tailor every habit to the user's answers — do NOT produce generic habits.
- If the user has restrictions or limitations, respect them completely.
- Frequency must be realistic given the user's available time/days.
- Do not include any text, code fences, or explanations outside the JSON array.
''';
  }

  /// Parses the raw Gemini response text into a list of [PlanSuggestionModel].
  List<PlanSuggestionModel> _parsePlanResponse(
    String responseText,
    PlanCategory category,
  ) {
    try {
      // Strip potential markdown code fences from the model output
      String cleaned = responseText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      // Extract the JSON array boundaries
      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');

      if (start == -1 || end == -1 || end <= start) {
        throw const FormatException(
          'No valid JSON array found in AI response.',
        );
      }

      cleaned = cleaned.substring(start, end + 1);

      final List<dynamic> jsonList = json.decode(cleaned) as List<dynamic>;

      if (jsonList.isEmpty) {
        throw const FormatException('AI returned an empty habit list.');
      }

      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(PlanSuggestionModel.fromJson)
          .where((s) => s.name.isNotEmpty)
          .toList();
    } on FormatException catch (e) {
      throw GeminiInvalidResponseException(
        'Could not parse AI response.',
        details: e.message,
      );
    } catch (e) {
      if (e is GeminiException) rethrow;
      throw GeminiUnknownException(
        'Unexpected error parsing plan.',
        originalError: e,
      );
    }
  }
}
