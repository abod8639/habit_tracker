import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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

  /// Validates whether an API key is valid and working with the Gemini model
  static Future<bool> validateApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) return false;
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: trimmed,
      );
      final countResult = await model.countTokens([
        Content.text('test'),
      ]).timeout(const Duration(seconds: 8));
      return countResult.totalTokens > 0;
    } catch (e) {
      try {
        final model = GenerativeModel(
          model: modelName,
          apiKey: trimmed,
        );
        final response = await model.generateContent([
          Content.text('ping'),
        ]).timeout(const Duration(seconds: 8));
        return response.text != null && response.text!.isNotEmpty;
      } catch (err) {
        return false;
      }
    }
  }

  /// Checks if the current active API key is valid and operational
  static Future<bool> isCurrentKeyValid() async {
    final key = currentApiKey;
    if (key.isEmpty) return false;
    return validateApiKey(key);
  }

  /// Creates a configured [GenerativeModel] instance with the current active API key.
  GenerativeModel createModel({
    String model = modelName,
    GenerationConfig? generationConfig,
    Content? systemInstruction,
  }) {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw ApiKeyMissingException();
    }
    return GenerativeModel(
      model: model,
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
        model: modelName,
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
