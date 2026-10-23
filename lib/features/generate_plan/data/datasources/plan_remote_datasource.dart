import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart' hide ServerException;
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
            description:
                'List of 3 to 4 personalized, Octalysis-engineered habit suggestions designed for high intrinsic motivation and effortless daily adherence',
            items: Schema.object(
              properties: {
                'name': Schema.string(
                  description:
                      'Concise, inspiring habit title (3-6 words) starting with a relevant motivating emoji that evokes competence and ownership',
                ),
                'description': Schema.string(
                  description:
                      '1-2 impactful sentences combining the exact implementation trigger (when/where) with an Octalysis White Hat psychological reward (identity, mastery, or immediate win state)',
                ),
                'frequency': Schema.string(
                  description:
                      'Realistic frequency calibrated to user capacity and sustainable momentum (e.g. "يومياً", "3 مرات أسبوعياً", "Daily", "3 times a week")',
                ),
                'category': Schema.string(
                  description: 'Category identifier string',
                ),
              },
              requiredProperties: [
                'name',
                'description',
                'frequency',
                'category',
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
                temperature: 0.4,
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
        throw ParsingException('Failed to process AI plan response: ${e.message}');
      }
      GeminiService.handleException(e, 'generating plan');
    }
  }

  /// Constructs an elite Octalysis-aligned behavioral science system instruction for habit architecture.
  String _buildSystemInstruction(PlanCategory category) {
    return '''
You are an elite Human-Focused Behavioral Architect and ${category.coachRole}, combining the **Octalysis Gamification Framework** (pioneered by Yu-kai Chou / The Octalysis Group) with evidence-based habit science (BJ Fogg's Tiny Habits & James Clear's Atomic Habits).

Your mission is to engineer a hyper-personalized portfolio of **3 to 4 sustainable habits** that transform the user's goals into an engaging daily journey driven by intrinsic motivation rather than exhausting willpower.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OCTALYSIS HABIT ARCHITECTURE PRINCIPLES (MANDATORY)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. COGNITIVE LOAD & PORTFOLIO BALANCE (3–4 Habits Only):
   - Never overwhelm the user. Construct a balanced portfolio of 3 to 4 synergistic habits:
     • At least ONE **2-Minute Ignition Habit** (frictionless daily win to protect their streak and trigger Core Drive 2: Accomplishment).
     • One or two **Core Mastery Habits** calibrated to their exact level and schedule.
     • One **Recovery, Environment, or Reflection Habit** that reinforces Core Drive 3 (Empowerment & Feedback) and prevents burnout.

2. WHITE HAT MOTIVATION & EPIC MEANING (Core Drive 1 & Core Drive 2):
   - Frame every habit around *who the user is becoming* and the immediate *Win State* they will feel upon completion—not as a dry chore or punishment.
   - Do NOT mention technical Octalysis jargon (like "Core Drive 1" or "White Hat") inside the JSON output; weave the psychology naturally into the habit title and description.

3. IMPLEMENTATION INTENTIONS & HABIT STACKING (Trigger + Action + Reward):
   - Every habit `description` MUST specify a concrete daily anchor/cue ("فور الاستيقاظ...", "بعد وجبة الغداء مباشرة...", "قبل فتح الحاسوب...", "Right after pouring your morning coffee...") paired with its emotional or physical payoff.

4. ETHICAL SCARCITY & MICRO-BOXING (Core Drive 6 & 2-Minute Rule):
   - Especially for beginners or busy users, bound habits with clear, non-intimidating time/quantity limits (e.g., "10 دقائق مركزة", "كأسين من الماء", "صفحتين فقط") so starting feels effortless.

5. ZERO-TOLERANCE SAFETY & CONSTRAINT ADHERENCE:
   - Strictly honor all reported physical limitations, injuries (e.g., knee pain, lower back issues), and dietary restrictions. Never suggest a movement or food that conflicts with the user's safety profile.

6. PUNCHY, EMOJI-LED TITLES:
   - Every habit `name` MUST begin with ONE motivating, context-accurate emoji followed by a crisp, action-oriented title (3 to 6 words) suitable for a mobile habit tracker card.
''';
  }

  /// Builds a structured prompt organizing user answers into an Octalysis-informed behavioral profile.
  String _buildPlanPrompt(
    PlanCategory category,
    Map<String, String> answers,
  ) {
    final isArabic = Intl.getCurrentLocale().startsWith('ar');

    final answersBlock = answers.entries
        .map((e) => '  - ${e.key.replaceAll("_", " ")}: ${e.value}')
        .join('\n');

    final languageInstruction = isArabic
        ? '''
LANGUAGE & TONE REQUIREMENT (CRITICAL - ARABIC):
- Generate all habit "name", "description", and "frequency" fields exclusively in eloquent, warm, modern standard Arabic (لغة عربية بيضاء راقية، محفزة، وسلسة، خالية من الركاكة أو الترجمة الحرفية).
- "name": MUST start with one relevant emoji followed by 3–6 inspiring words (e.g., "💧 كأسا ماء لتنشيط الجسد صباحاً", "🚶‍♂️ مشي نشط 20 دقيقة بعد الغداء", "🎯 25 دقيقة تركيز عميق بلا مشتتات").
- "description": 1–2 rich sentences that state (1) the exact trigger/anchor moment in their day, and (2) the immediate sense of accomplishment or identity gain (بدون استخدام مصطلحات تقنية).
- "frequency": Clear Arabic frequency matching their availability (e.g., "يومياً", "3 مرات أسبوعياً", "4 أيام أسبوعياً").
'''
        : '''
LANGUAGE & TONE REQUIREMENT (CRITICAL - ENGLISH):
- Generate all habit "name", "description", and "frequency" fields exclusively in natural, inspiring, human-focused English.
- "name": MUST start with one relevant emoji followed by 3–6 punchy, motivating words (e.g., "💧 Two glasses of water upon waking", "🚶‍♂️ 20-min brisk walk after lunch", "🎯 25-min deep focus sprint").
- "description": 1–2 crisp sentences stating (1) the exact daily trigger/anchor cue, and (2) the immediate win state or identity benefit they unlock.
- "frequency": Clear English frequency calibrated to their schedule (e.g., "Daily", "3 times a week", "4 days a week").
''';

    return '''
TARGET GROWTH DOMAIN: ${category.displayName} (${category.name})

USER ONBOARDING & BEHAVIORAL PROFILE:
$answersBlock

ARCHITECTURAL TASK:
Analyze the user's starting baseline, deeper motivation, schedule capacity, and friction points above. Design an interconnected system of **3 to 4 high-adherence habits** tailored specifically to this human being.

CRITICAL EXECUTION RULES:
- Quantity: Return strictly 3 to 4 habits.
- Progressive Calibration: Match their current fitness/study/skill stage so they experience an immediate "Early Win" on Day 1 without feeling overwhelmed.
- Obstacle Bypass: If the user mentioned a specific challenge (e.g., procrastination, low focus, low water intake) or physical/dietary constraint, design at least one habit specifically engineered to neutralize that friction point safely.
- Output Format: Return ONLY a valid JSON array matching the required schema.

$languageInstruction
''';
  }
}