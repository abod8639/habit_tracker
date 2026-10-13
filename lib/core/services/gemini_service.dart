import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/data/datasources/settings_storage.dart';

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
  String? _lastModelName;

  static const String defaultModelName = 'gemini-3-flash-preview';

  /// Ordered list of candidate models to try for maximum compatibility across accounts
  static const List<String> supportedCandidateModels = [
    'gemini-3-flash-preview',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
  ];

  /// Models known to be sunset or deprecated for new Gemini accounts
  static const List<String> deprecatedModels = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-1.5-flash',
    'gemini-1.5-pro',
  ];

  static String? _resolvedModelName;

  /// Backward-compatible alias for the active model name
  static String get modelName => effectiveModelName;

  /// Returns the dynamically resolved working model for the current API key
  static String get effectiveModelName {
    if (_resolvedModelName != null &&
        _resolvedModelName!.isNotEmpty &&
        !deprecatedModels.contains(_resolvedModelName)) {
      return _resolvedModelName!;
    }
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        final savedModel = Get.find<SettingsStorage>().customGeminiModel;
        if (savedModel != null &&
            savedModel.trim().isNotEmpty &&
            !deprecatedModels.contains(savedModel.trim())) {
          _resolvedModelName = savedModel.trim();
          return _resolvedModelName!;
        }
      }
    } catch (_) {}
    return defaultModelName;
  }

  /// Cleans and sanitizes raw API key strings (strips whitespace, quotes, prefixes)
  static String sanitizeApiKey(String rawKey) {
    var key = rawKey.trim();
    if (key.contains('=')) {
      key = key.split('=').last.trim();
    }
    if ((key.startsWith('"') && key.endsWith('"')) ||
        (key.startsWith("'") && key.endsWith("'"))) {
      key = key.substring(1, key.length - 1).trim();
    }
    return key;
  }

  static String get _apiKey {
    // 1. Check custom user-defined API key first
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        final customKey = Get.find<SettingsStorage>().customGeminiApiKey;
        if (customKey != null && customKey.trim().isNotEmpty) {
          return sanitizeApiKey(customKey);
        }
      }
    } catch (_) {}

    // 2. Fallback to compile-time environment variable
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return sanitizeApiKey(envKey);

    // 3. Fallback to .env file
    if (dotenv.isInitialized) {
      final key = dotenv.env['GEMINI_API_KEY'] ?? '';
      return sanitizeApiKey(key);
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

  static void _saveResolvedModel(String model) {
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        Get.find<SettingsStorage>().setCustomGeminiModel(model);
      }
    } catch (_) {}
  }

  /// Resets in-memory cached model instance without wiping persistent storage
  static void resetModelInstance() {
    _resolvedModelName = null;
  }

  /// Explicitly clears the custom resolved model from persistent storage
  static void clearCustomModel() {
    _resolvedModelName = null;
    try {
      if (Get.isRegistered<SettingsStorage>()) {
        Get.find<SettingsStorage>().setCustomGeminiModel(null);
      }
    } catch (_) {}
  }

  /// Validates whether an API key is valid and working with Gemini models.
  /// Dynamically detects the best supported model for this specific key.
  static Future<bool> validateApiKey(String apiKey) async {
    final cleaned = sanitizeApiKey(apiKey);
    if (cleaned.isEmpty) return false;

    // 1. Fast check against Google AI models endpoint (discovers all accessible models)
    final supportedFromApi = <String>[];
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$cleaned',
      );
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('models')) {
          final modelsList = decoded['models'] as List<dynamic>? ?? [];
          for (final item in modelsList) {
            if (item is Map<String, dynamic>) {
              final name =
                  (item['name'] as String? ?? '').replaceFirst('models/', '');
              final methods =
                  (item['supportedGenerationMethods'] as List<dynamic>? ?? [])
                      .map((e) => e.toString())
                      .toList();
              if (methods.contains('generateContent') &&
                  !deprecatedModels.contains(name)) {
                supportedFromApi.add(name);
              }
            }
          }
        }
      } else if (response.statusCode == 400 || response.statusCode == 403) {
        // Explicit invalid key or API blocked
        return false;
      }
    } catch (_) {
      // Network hiccup or test environment, fallback to direct candidate probing
    }

    // 2. Prepare ordered probe candidates: prioritize modern models verified by the API
    final probeList = <String>[];
    for (final candidate in supportedCandidateModels) {
      if (supportedFromApi.isEmpty || supportedFromApi.contains(candidate)) {
        probeList.add(candidate);
      }
    }
    for (final model in supportedFromApi) {
      if (!probeList.contains(model)) {
        probeList.add(model);
      }
    }
    if (probeList.isEmpty) {
      probeList.addAll(supportedCandidateModels);
    }

    // 3. Direct candidate probing: try each candidate model with countTokens
    for (final candidate in probeList) {
      try {
        final model = GenerativeModel(
          model: candidate,
          apiKey: cleaned,
        );
        final countResult = await model.countTokens([
          Content.text('test'),
        ]).timeout(const Duration(seconds: 4));

        if (countResult.totalTokens > 0) {
          _resolvedModelName = candidate;
          _saveResolvedModel(candidate);
          return true;
        }
      } catch (e) {
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('api key not valid') ||
            errStr.contains('api_key_invalid')) {
          return false;
        }
        // If candidate is unavailable or experiencing spike, try next candidate
      }
    }

    // 4. Fallback if countTokens timed out but endpoint returned valid models
    if (supportedFromApi.isNotEmpty) {
      final selected = supportedFromApi.firstWhere(
        (m) => supportedCandidateModels.contains(m),
        orElse: () => defaultModelName,
      );
      _resolvedModelName = selected;
      _saveResolvedModel(selected);
      return true;
    }

    return false;
  }

  /// Checks if the current active API key is valid and operational
  static Future<bool> isCurrentKeyValid() async {
    final key = currentApiKey;
    if (key.isEmpty) return false;
    return validateApiKey(key);
  }

  /// Creates a configured [GenerativeModel] instance with the current active API key.
  GenerativeModel createModel({
    String? model,
    GenerationConfig? generationConfig,
    Content? systemInstruction,
  }) {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw ApiKeyMissingException();
    }
    return GenerativeModel(
      model: model ?? effectiveModelName,
      apiKey: apiKey,
      generationConfig: generationConfig,
      systemInstruction: systemInstruction,
    );
  }

  /// Lazy getter for standard GenerativeModel instance
  GenerativeModel get _model {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw ApiKeyMissingException();
    }

    final targetModel = effectiveModelName;

    if (_modelInstance != null &&
        _lastApiKey == apiKey &&
        _lastModelName == targetModel) {
      return _modelInstance!;
    }

    _lastApiKey = apiKey;
    _lastModelName = targetModel;
    _modelInstance = GenerativeModel(
      model: targetModel,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    return _modelInstance!;
  }

  /// Checks whether an exception indicates the model is unavailable, deprecated, or not found.
  static bool isModelUnavailableError(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('not found') ||
        msg.contains('not supported') ||
        msg.contains('404') ||
        msg.contains('is not found') ||
        msg.contains('no longer available') ||
        msg.contains('not available to new users') ||
        msg.contains('not available') ||
        msg.contains('deprecated');
  }

  /// Automatically tries each alternative candidate model until one succeeds.
  static Future<String?> trySwitchToWorkingModel({String? apiKey}) async {
    final currentKey = apiKey ?? _apiKey;
    if (currentKey.isEmpty) return null;

    for (final candidate in supportedCandidateModels) {
      if (candidate == effectiveModelName) continue;
      try {
        final testModel = GenerativeModel(
          model: candidate,
          apiKey: currentKey,
        );
        final result = await testModel.countTokens([
          Content.text('test'),
        ]).timeout(const Duration(seconds: 4));
        if (result.totalTokens > 0) {
          _resolvedModelName = candidate;
          _saveResolvedModel(candidate);
          resetModelInstance();
          return candidate;
        }
      } catch (e) {
        if (!isModelUnavailableError(e)) {
          // If not explicit unavailable (e.g. temporary timeout), candidate might still work
        }
      }
    }

    // If probing had temporary timeouts, switch to the next candidate model
    for (final candidate in supportedCandidateModels) {
      if (candidate != effectiveModelName) {
        _resolvedModelName = candidate;
        _saveResolvedModel(candidate);
        resetModelInstance();
        return candidate;
      }
    }
    return null;
  }

  /// Evaluates an image using Gemini and extracts distinct habits/tasks.
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

      GenerateContentResponse response;
      try {
        response = await _model.generateContent([
          Content.multi([prompt, imagePart]),
        ]);
      } catch (e) {
        if (isModelUnavailableError(e)) {
          final switchedModel = await trySwitchToWorkingModel();
          if (switchedModel != null) {
            response = await _model.generateContent([
              Content.multi([prompt, imagePart]),
            ]);
          } else {
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      if (response.text == null || response.text!.isEmpty) {
        throw GeminiInvalidResponseException(
          'No response was generated by the AI.',
        );
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
        throw GeminiInvalidResponseException(
          'Expected a JSON list of habits/tasks.',
        );
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
        model: effectiveModelName,
        apiKey: apiKey,
        systemInstruction: systemInstruction != null
            ? Content.system(systemInstruction)
            : null,
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
      if (msg.contains('quota') ||
          msg.contains('limit') ||
          msg.contains('429')) {
        return S.current.geminiQuotaExceeded;
      }
      if (msg.contains('api key') ||
          msg.contains('invalid') ||
          msg.contains('400')) {
        return S.current.geminiApiKeyError;
      }
      return S.current.geminiServerError;
    }
    return S.current.unexpectedError;
  }

  /// Centralized exception analyzer mapping errors to custom GeminiExceptions.
  static Never handleException(Object e, String action) {
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
      if (errorMsg.contains('quota') ||
          errorMsg.contains('limit') ||
          errorMsg.contains('429')) {
        throw GeminiQuotaException(
          'API rate limit exceeded. Please try again later.',
          details: e.message,
        );
      } else if (errorMsg.contains('api key') ||
          errorMsg.contains('invalid') ||
          errorMsg.contains('400')) {
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

  Never _handleException(Object e, String action) => handleException(e, action);
}
