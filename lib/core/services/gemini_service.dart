import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/features/categorys/domain/entities/category_entity.dart';
import 'package:habit_tracker/features/categorys/domain/entities/plan_suggestion.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';

// ── CUSTOM GEMINI EXCEPTIONS ──────────────────────────────────────────────────
abstract class GeminiException implements Exception {
  final String message;
  final String? details;

  GeminiException(this.message, {this.details});

  @override
  String toString() => message;
}

class ApiKeyMissingException extends GeminiException {
  ApiKeyMissingException()
      : super('GEMINI_API_KEY is not defined in your environment (.env file).');
}

class GeminiInvalidResponseException extends GeminiException {
  GeminiInvalidResponseException(super.message, {super.details});
}

class GeminiQuotaException extends GeminiException {
  GeminiQuotaException(super.message, {super.details});
}

class GeminiServerException extends GeminiException {
  GeminiServerException(super.message, {super.details});
}

class GeminiUnknownException extends GeminiException {
  GeminiUnknownException(super.message, {Object? originalError})
      : super(details: originalError?.toString());
}

// ── GEMINI SERVICE ────────────────────────────────────────────────────────────
class GeminiService {
  GenerativeModel? _modelInstance;
  String? _lastApiKey;

  static const String modelName = 'gemini-2.5-flash-lite';

  static String get _apiKey {
    // 1. Check custom user-defined API key first
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        final customKey = Get.find<SettingsStorage>().customGeminiApiKey;
        if (customKey != null && customKey.trim().isNotEmpty) {
          return customKey.trim();
        }
      }
    } catch (_) {}

    // 2. Fallback to compile-time environment variable
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey;

    // 3. Fallback to .env file
    if (dotenv.isInitialized) {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    }
    return '';
  }

  /// Whether a custom user-defined API key is currently active
  static bool get hasCustomApiKey {
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        final customKey = Get.find<SettingsStorage>().customGeminiApiKey;
        return customKey != null && customKey.trim().isNotEmpty;
      }
    } catch (_) {}
    return false;
  }

  /// Returns the current active API key (or empty string)
  static String get currentApiKey => _apiKey;

  /// Lazy getter for standard GenerativeModel instance
  GenerativeModel get _model {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw ApiKeyMissingException();
    }

    if (_modelInstance != null && _lastApiKey == apiKey) {
      return _modelInstance!;
    }

    _lastApiKey = apiKey;
    _modelInstance = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    return _modelInstance!;
  }

  /// Evaluates an image using Gemini Pro Vision and extracts distinct habits/tasks.
  Future<List<String>> extractHabitsFromImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final prompt = TextPart(
        'You are an expert habit coach and productivity analyst.\n'
        'Role: You are a professional daily habit and task extractor.\n'
        'Task: Analyze the provided image (handwritten list, schedule, or diet plan) and extract all habits/tasks.\n'
        'Strict Formatting Rules:\n'
        '1. Output ONLY a valid JSON array of strings: ["Category: Emoji Task", "Category: Emoji Task"].\n'
        '2. NO markdown blocks (e.g., no ```json), NO introductory text.\n'
        '3. For grouped items (like under "Breakfast" or "Lunch"), prefix each task with the group name followed by a colon.\n'
        '4. Add a relevant emoji at the beginning of the task text (after the colon if there is a category).\n'
        '   Example: ["Breakfast: 🍳 3 eggs", "Lunch: 🍗 Chicken thighs", "Dinner: 🥩 Beef", "💊 Creatine"]\n'
        '5. Keep each string very short (2-5 words) and actionable.\n'
        '6. If an item is alone without a category, just list its name with an emoji.\n'
        '7. Maintain the original language of the image (Arabic or English).\n'
        '8. Avoid duplicates: If multiple words mean the same thing, output only one.',
      );
      
      final imagePart = DataPart(imageFile.mimeType ?? 'image/jpeg', bytes);

      final response = await _model.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw GeminiInvalidResponseException('No response was generated by the AI.');
      }

      String cleanedText = response.text!.trim();
      // Enforce clean JSON boundary if markdown wraps it
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.replaceFirst('```json\n', '');
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replaceFirst('```\n', '');
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3).trim();
      }

      final decoded = jsonDecode(cleanedText);
      if (decoded is! List) {
        throw GeminiInvalidResponseException('Expected a JSON list of habits/tasks.');
      }

      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      _handleException(e, 'extracting habits from image');
    }
  }

  /// Starts a new chat session with an optional system instruction and history.
  ChatSession startChat({String? systemInstruction, List<Content>? history}) {
    try {
      final apiKey = _apiKey;
      if (apiKey.isEmpty) {
        throw ApiKeyMissingException();
      }

      final chatModel = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
      );

      return chatModel.startChat(history: history);
    } catch (e) {
      _handleException(e, 'starting chat session');
    }
  }

  /// Converts any exception into a user-friendly localized error message.
  static String getErrorMessage(Object e) {
    if (e is ApiKeyMissingException) {
      return S.current.geminiApiKeyError;
    }
    if (e is GeminiQuotaException) {
      return S.current.geminiQuotaExceeded;
    }
    if (e is GeminiServerException) {
      return S.current.geminiServerError;
    }
    if (e is GeminiException) {
      return e.message;
    }
    if (e is GenerativeAIException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('quota') || msg.contains('limit') || msg.contains('429')) {
        return S.current.geminiQuotaExceeded;
      }
      if (msg.contains('api key') || msg.contains('invalid') || msg.contains('400')) {
        return S.current.geminiApiKeyError;
      }
      return S.current.geminiServerError;
    }
    return S.current.unexpectedError;
  }

  /// Centralized exception analyzer mapping errors to custom GeminiExceptions.
  Never _handleException(Object e, String action) {
    if (e is GeminiException) {
      throw e;
    }

    if (e is FormatException) {
      throw GeminiInvalidResponseException(
        'Failed to parse the AI response format during $action.',
        details: e.toString(),
      );
    }

    if (e is GenerativeAIException) {
      final errorMsg = e.message.toLowerCase();
      if (errorMsg.contains('quota') || errorMsg.contains('limit') || errorMsg.contains('429')) {
        throw GeminiQuotaException(
          'API rate limit exceeded. Please try again later.',
          details: e.message,
        );
      } else if (errorMsg.contains('api key') || errorMsg.contains('invalid') || errorMsg.contains('400')) {
        throw GeminiServerException(
          'Invalid or missing API key configuration.',
          details: e.message,
        );
      } else {
        throw GeminiServerException(
          'Gemini server returned an error during $action.',
          details: e.message,
        );
      }
    }

    throw GeminiUnknownException(
      'An unexpected error occurred while $action.',
      originalError: e,
    );
  }

  /// Generates a list of [PlanSuggestion] tailored to the user's answers.
  Future<List<PlanSuggestion>> generatePlan({
    required PlanCategory category,
    required Map<String, String> userAnswers,
  }) async {
    final prompt = _buildPlanPrompt(category, userAnswers);
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      return _parsePlanResponse(text, category);
    } on GenerativeAIException catch (e) {
      _handleException(e, 'generating plan');
    } catch (e) {
      _handleException(e, 'generating plan');
    }
  }

  /// Builds a structured prompt that instructs Gemini to return strict JSON.
  String _buildPlanPrompt(
    PlanCategory category,
    Map<String, String> answers,
  ) {
    final answersBlock = answers.entries
        .map((e) => '  - ${e.key.replaceAll("_", " ")}: ${e.value}')
        .join('\n');

    final isArabic = Get.isRegistered<LangController>()
        ? Get.find<LangController>().isArabic
        : ((Get.locale?.languageCode ?? Intl.getCurrentLocale()).startsWith('ar'));

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

  /// Parses the raw Gemini response text into a list of [PlanSuggestion].
  List<PlanSuggestion> _parsePlanResponse(
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
        throw const FormatException('No valid JSON array found in AI response.');
      }

      cleaned = cleaned.substring(start, end + 1);

      final List<dynamic> jsonList = json.decode(cleaned) as List<dynamic>;

      if (jsonList.isEmpty) {
        throw const FormatException('AI returned an empty habit list.');
      }

      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(PlanSuggestion.fromJson)
          .where((s) => s.name.isNotEmpty) // Guard against empty entries
          .toList();
    } on FormatException catch (e) {
      throw GeminiInvalidResponseException('Could not parse AI response.', details: e.message);
    } catch (e) {
      throw GeminiUnknownException('Unexpected error parsing plan.', originalError: e);
    }
  }
}
