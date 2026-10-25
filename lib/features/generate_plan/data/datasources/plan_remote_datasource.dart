import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ServerException;
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import '../../domain/entities/category_entity.dart';
import '../models/plan_suggestion_model.dart';
import 'plan_payload_processor.dart';

abstract class PlanRemoteDataSource {
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
    List<String> existingHabits = const [],
  });
}

/// Dedicated remote AI service for generating personalized habit plans via Gemini,
/// architected around the Octalysis Gamification & Behavioral Design Framework.
class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final GeminiService geminiService;

  /// Explicit timeout duration for plan generation requests to prevent UI freezing.
  static const Duration requestTimeout = Duration(seconds: 30);

  PlanRemoteDataSourceImpl({required this.geminiService});

  @override
  Future<List<PlanSuggestionModel>> generatePlan({
    required PlanCategory category,
    required Map<String, dynamic> userAnswers,
    List<String> existingHabits = const [],
  }) async {
    final stringAnswers = userAnswers.map(
      (k, v) => MapEntry(k, v is List ? v.join(' + ') : v.toString()),
    );
    final prompt = _buildPlanPrompt(category, stringAnswers, existingHabits);
    final systemInstruction = _buildSystemInstruction(category);

    try {
      final model = geminiService.createModel(
        systemInstruction: Content.system(systemInstruction),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.5,
          responseSchema: Schema.array(
            description:
                'List of 3 to 4 personalized, Octalysis-engineered habit suggestions designed for high intrinsic motivation and effortless daily adherence',
            items: Schema.object(
              properties: {
                'name': Schema.string(
                  description:
                      'Emoji + the concrete action, amount and anchor cue in 3-8 words. This is the ONLY text saved to the daily tracker, so it must stand alone (e.g. "💧 كأسا ماء فور الاستيقاظ")',
                ),
                'description': Schema.string(
                  description:
                      '1-2 sentences: the exact anchor moment, how to do it, and the immediate win the user feels afterwards',
                ),
                'frequency': Schema.string(
                  description:
                      'Daily-checkable rhythm (e.g. "يومياً", "Daily", "يومياً (جلسة كاملة 3 أيام)")',
                ),
                'category': Schema.string(
                  description: 'Category identifier string',
                ),
                'tier': Schema.enumString(
                  enumValues: ['ignition', 'mastery', 'recovery'],
                  description:
                      '"ignition" (tiny 2-minute starter), "mastery" (main skill builder), or "recovery" (reflection, environment or rest)',
                ),
                'personalReason': Schema.string(
                  description:
                      'One short sentence in second person explaining why this habit fits THIS user, quoting or paraphrasing one specific answer they gave',
                ),
                'levelUp': Schema.string(
                  description:
                      'One short sentence describing the next, slightly harder version to unlock after ~2 weeks of consistency',
                ),
                'dailyMinutes': Schema.integer(
                  description:
                      'Realistic minutes this habit takes on a normal day (1-120)',
                ),
              },
              requiredProperties: [
                'name',
                'description',
                'frequency',
                'category',
                'tier',
                'personalReason',
                'levelUp',
                'dailyMinutes',
              ],
            ),
          ),
        ),
      );

      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(
            requestTimeout,
            onTimeout: () => throw const TimeoutAppException(
              'Plan generation request timed out. Please try again.',
            ),
          );
      final text = response.text ?? '';
      return await PlanPayloadProcessor.parsePlanResponse(text);
    } catch (e) {
      if (GeminiService.isModelUnavailableError(e)) {
        final switched = await GeminiService.trySwitchToWorkingModel();
        if (switched != null) {
          try {
            final fallbackModel = geminiService.createModel(
              systemInstruction: Content.system(systemInstruction),
              generationConfig: GenerationConfig(
                responseMimeType: 'application/json',
                temperature: 0.5,
              ),
            );
            final response = await fallbackModel
                .generateContent([Content.text(prompt)])
                .timeout(
                  requestTimeout,
                  onTimeout: () => throw const TimeoutAppException(
                    'Plan generation fallback request timed out. Please try again.',
                  ),
                );
            final text = response.text ?? '';
            return await PlanPayloadProcessor.parsePlanResponse(text);
          } catch (_) {}
        }
      }
      if (e is TimeoutAppException || e is TimeoutException) {
        throw const TimeoutAppException(
          'Plan generation timed out. Please check your connection and try again.',
        );
      }
      if (e is FormatException) {
        throw ParsingException(
          'Failed to process AI plan response: ${e.message}',
        );
      }
      GeminiService.handleException(e, 'generating plan');
    }
  }

  /// System instruction encoding the Octalysis core drives as concrete, testable
  /// habit-design rules (White Hat first, Black Hat only in ethical doses).
  String _buildSystemInstruction(PlanCategory category) {
    return '''
You are a ${category.coachRole} and behavioral designer. You design habits using the Octalysis Framework (Yu-kai Chou) together with BJ Fogg's Tiny Habits and James Clear's Atomic Habits.

PRODUCT CONTEXT (hard constraints):
- The habits go into a simple daily tracker: each habit is ONE checkbox per day and ONLY its `name` is saved. Description, frequency and other fields are shown once, on the plan screen.
- Therefore every `name` must stand alone: emoji + action + amount + anchor cue (e.g. "📖 صفحتان بعد صلاة الفجر", "🚶 10 دقائق مشي بعد الغداء").
- Every habit must be checkable EVERY day. If the full activity is not daily (e.g. 3 workouts a week), make the daily habit the minimum version that keeps the identity alive (e.g. "🧘 دقيقتا إطالة بعد الاستيقاظ") and mention the full sessions in `frequency`/`description`.

PORTFOLIO (3–4 habits, in this order):
1. Exactly ONE "ignition" habit: ≤ 2 minutes, impossible to fail, anchored to something the user already does daily. It protects the streak on bad days (CD2 Accomplishment, ethical CD8 – the streak is worth keeping, never guilt).
2. One or two "mastery" habits: the real progress engine, calibrated to the user's CURRENT level, slightly above comfort (CD2 Accomplishment + CD3 Creativity/Feedback). For at least one of them, offer 2–3 interchangeable variations in the description so the user picks each day (CD3 Empowerment of choice, CD7 freshness).
3. One "recovery" habit: reflection, environment design, preparation or rest that makes the others easier and prevents burnout (CD4 Ownership of their space/tools, CD1 identity reflection).

PERSONALIZATION RULES (most important):
- Every habit must be traceable to specific answers. Use the user's own goal, motivation, level, schedule, equipment and obstacle – never generic advice that could fit anyone.
- `personalReason` must cite one concrete answer in second person ("لأنك ذكرت أن وقتك المتاح 15 دقيقة..." / "Because you said evenings are your free time..."). This is CD3 feedback: the user sees their answers shaped the plan.
- Time budget: the sum of `dailyMinutes` must fit within the time the user said they have. If they gave no time, keep the total ≤ 30 minutes. Beginners: total ≤ 20 minutes.
- The user's reported biggest obstacle must be neutralized by at least one habit (name the obstacle in that habit's personalReason).
- Anchors: prefer the daily anchor moment the user selected. Use real-life Arabic/Islamic daily anchors (prayer times, meals, commute) when the user's language is Arabic and it fits naturally.
- Existing habits: never duplicate a habit the user already tracks; you MAY stack a new habit right after an existing one ("بعد [existing habit]").
- Safety: strictly respect injuries, physical limitations, dietary restrictions and religious dietary rules. If unsure, choose the safer option.

MOTIVATION STYLE:
- White Hat first: frame habits around who the user is becoming (CD1 Epic Meaning) and the immediate win they feel (CD2).
- `levelUp` shows the next tier of mastery to unlock after ~2 weeks (CD2 progression, CD7 anticipation). Keep it a small step, not a leap.
- No shame, fear, punishment or guilt language. No Octalysis jargon ("Core Drive", "White Hat") in any output field.
''';
  }

  /// Builds the user-specific prompt: answers, existing habits and language rules.
  String _buildPlanPrompt(
    PlanCategory category,
    Map<String, String> answers,
    List<String> existingHabits,
  ) {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    final answersBlock = answers.entries
        .where((e) => e.value.trim().isNotEmpty)
        .map((e) => '  - ${e.key.replaceAll("_", " ")}: ${e.value}')
        .join('\n');

    final existingBlock = existingHabits.isEmpty
        ? '  (none yet – this is their first plan)'
        : existingHabits.take(25).map((h) => '  - $h').join('\n');

    final languageInstruction = isArabic
        ? '''
LANGUAGE (ARABIC):
- Write every text field in warm, natural Modern Standard Arabic (عربية بيضاء سلسة، بلا ترجمة حرفية أو مصطلحات تقنية).
- "name": emoji + 3–8 words containing action + amount + cue (e.g. "💧 كأسا ماء فور الاستيقاظ", "🎯 25 دقيقة تركيز بعد العصر").
- "personalReason": يبدأ بـ "لأنك..." ويذكر إجابة محددة للمستخدم.
- "levelUp": يبدأ بـ "بعد أسبوعين:".
- "frequency": e.g. "يومياً"، "يومياً (جلسة كاملة 3 أيام أسبوعياً)".
'''
        : '''
LANGUAGE (ENGLISH):
- Write every text field in natural, encouraging English without jargon.
- "name": emoji + 3–8 words containing action + amount + cue (e.g. "💧 Two glasses of water on waking", "🎯 25-min focus after lunch").
- "personalReason": starts with "Because you..." and cites one specific answer.
- "levelUp": starts with "After 2 weeks:".
- "frequency": e.g. "Daily", "Daily (full session 3x/week)".
''';

    return '''
GROWTH AREA: ${category.displayName} (${category.name})

USER ANSWERS:
$answersBlock

HABITS THE USER ALREADY TRACKS:
$existingBlock

TASK:
Design 3–4 habits for this specific person following every rule in the system instruction. Before writing, silently check: (1) total dailyMinutes fits their time, (2) their obstacle is addressed, (3) each habit is checkable daily, (4) no duplicates with existing habits, (5) each personalReason cites a real answer.
Return ONLY the JSON array, ignition habit first.

$languageInstruction
''';
  }
}
