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
    final systemInstruction = _buildSystemInstruction(category);

    try {
      final model = geminiService.createModel(
        systemInstruction: Content.system(systemInstruction),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.4,
          responseSchema: Schema.array(
            description: 'List of 3 to 4 personalized, high-adherence habit suggestions',
            items: Schema.object(
              properties: {
                'name': Schema.string(
                  description:
                      'Concise, actionable habit title (3-6 words) starting with a motivating, relevant emoji',
                ),
                'description': Schema.string(
                  description:
                      '1-2 punchy sentences explaining the exact benefit and the anchor/trigger cue (e.g. after waking up, with lunch)',
                ),
                'frequency': Schema.string(
                  description:
                      'Realistic frequency calibrated to user schedule (e.g. "يومياً", "3 مرات أسبوعياً")',
                ),
                'category': Schema.string(description: 'Category identifier string'),
              },
              requiredProperties: ['name', 'description', 'frequency', 'category'],
            ),
          ),
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parsePlanResponse(text, category);
    } catch (e) {
      GeminiService.handleException(e, 'generating plan');
    }
  }

  /// Constructs an elite behavioral science system instruction for habit architecture.
  String _buildSystemInstruction(PlanCategory category) {
    return '''
You are an elite behavioral scientist and ${category.coachRole}, specializing in the Atomic Habits and Tiny Habits frameworks.
Your objective is to design hyper-personalized, realistic, and highly sustainable habit plans for users.

CORE BEHAVIORAL PRINCIPLES:
1. OPTIMAL COGNITIVE LOAD (3-4 Habits): Do NOT overwhelm the user with too many habits. Focus strictly on 3 to 4 core, high-impact habits that build identity and sustainable momentum.
2. IMPLEMENTATION INTENTIONS & HABIT STACKING: Every habit must include a clear situational cue or anchor (e.g. "Immediately upon waking up", "Right after lunch", "Before opening your laptop").
3. THE 2-MINUTE STARTER RULE: For beginners or users with limited time, minimize initial friction. Emphasize consistency over intensity.
4. ABSOLUTE CONSTRAINT ADHERENCE: Strictly avoid any exercise, food, or activity that contradicts the user's reported physical limitations, injuries, or dietary restrictions. Zero tolerance for violating limitations.
5. PUNCHY, EMOJI-LED TITLES: Every habit name MUST start with a motivating emoji followed by a concise, actionable title (3 to 6 words) suitable for a habit tracker tile.
''';
  }

  /// Builds a structured prompt organizing user answers into clear behavioral context.
  String _buildPlanPrompt(
    PlanCategory category,
    Map<String, String> answers,
  ) {
    final isArabic = Get.isRegistered<LangController>()
        ? Get.find<LangController>().isArabic
        : ((Get.locale?.languageCode ?? Intl.getCurrentLocale()).startsWith(
            'ar',
          ));

    final answersBlock = answers.entries
        .map((e) => '  - ${e.key.replaceAll("_", " ")}: ${e.value}')
        .join('\n');

    final languageInstruction = isArabic
        ? '''
LANGUAGE REQUIREMENT (CRITICAL):
- Generate all habit "name", "description", and "frequency" fields exclusively in natural, high-quality Arabic (اللغة العربية).
- The "name" MUST start with a relevant emoji (e.g. "💧 شرب كأسي ماء عند الاستيقاظ", "🚶‍♂️ مشي نشط 20 دقيقة").
- The "frequency" must be in Arabic (e.g. "يومياً", "3 مرات أسبوعياً", "أيام التدريب").
- The "description" must clearly explain why this habit fits the user and when to execute it (المحفز / الرابط الزمني).'''
        : '''
LANGUAGE REQUIREMENT (CRITICAL):
- Generate all habit "name", "description", and "frequency" fields exclusively in English.
- The "name" MUST start with a relevant emoji (e.g. "💧 Drink 2 glasses of water upon waking", "🚶‍♂️ 20-min brisk walk after lunch").
- The "frequency" must be in English (e.g. "Daily", "3 times a week", "On workout days").
- The "description" must clearly explain why this habit fits the user and when to execute it (trigger/anchor).''';

    return '''
TARGET DOMAIN: ${category.displayName} (${category.name})

USER PROFILE & ASSESSMENTS:
$answersBlock

TASK:
Synthesize the user profile above and construct exactly 3 to 4 deeply personalized, practical habits that guide this specific user to success.

CRITICAL RULES:
- Quantity: Provide between 3 and 4 habits only.
- Strict Personalization: Fit their exact schedule, fitness/skill level, and equipment.
- Safety & Constraints: If any limitations (e.g. injuries, back/knee pain, dietary preferences) are mentioned, respect them completely.
- Format: Return a JSON array matching the required schema.

$languageInstruction
''';
  }

  /// Parses the Gemini response text into a list of [PlanSuggestionModel].
  List<PlanSuggestionModel> _parsePlanResponse(
    String responseText,
    PlanCategory category,
  ) {
    try {
      String cleaned = responseText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final start = cleaned.indexOf('[');
      final end = cleaned.lastIndexOf(']');

      if (start != -1 && end != -1 && end >= start) {
        cleaned = cleaned.substring(start, end + 1);
      }

      final dynamic decoded = json.decode(cleaned);

      if (decoded is! List || decoded.isEmpty) {
        throw const FormatException('AI returned an empty habit list.');
      }

      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(PlanSuggestionModel.fromJson)
          .where((s) => s.name.trim().isNotEmpty)
          .toList();

      if (list.isEmpty) {
        throw const FormatException('No valid habits parsed from response.');
      }

      return list;
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
