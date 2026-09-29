import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/generated/l10n.dart';

enum ApiKeyStatus {
  unknown,
  validating,
  valid,
  invalid,
}

class AiSettingsController extends GetxController {
  final GetCustomApiKeyUseCase getCustomApiKeyUseCase;
  final SaveCustomApiKeyUseCase saveCustomApiKeyUseCase;
  final ClearCustomApiKeyUseCase clearCustomApiKeyUseCase;
  final Future<bool> Function(String)? apiKeyValidator;

  AiSettingsController({
    required this.getCustomApiKeyUseCase,
    required this.saveCustomApiKeyUseCase,
    required this.clearCustomApiKeyUseCase,
    this.apiKeyValidator,
  });

  final RxString customApiKey = ''.obs;
  final RxBool isCustom = false.obs;
  final RxBool obscureText = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isValidating = false.obs;
  final Rx<ApiKeyStatus> apiKeyStatus = ApiKeyStatus.unknown.obs;
  final TextEditingController keyInputController = TextEditingController();

  bool get isKeyWorking => apiKeyStatus.value == ApiKeyStatus.valid;

  @override
  void onInit() {
    super.onInit();
    loadApiKey().then((_) => checkKeyHealth());
  }

  @override
  void onClose() {
    keyInputController.dispose();
    super.onClose();
  }

  void toggleObscure() {
    obscureText.value = !obscureText.value;
  }

  void _showNotification(String title, String message, {Color? color}) {
    if (Get.context != null) {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: (color ?? Colors.teal).withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> loadApiKey() async {
    final result = await getCustomApiKeyUseCase();
    result.fold(
      (failure) {
        customApiKey.value = '';
        isCustom.value = false;
        keyInputController.text = '';
      },
      (key) {
        if (key != null && key.trim().isNotEmpty) {
          customApiKey.value = key.trim();
          isCustom.value = true;
          keyInputController.text = key.trim();
        } else {
          customApiKey.value = '';
          isCustom.value = false;
          keyInputController.text = '';
        }
      },
    );
  }

  Future<bool> checkKeyHealth({bool force = false}) async {
    final key = GeminiService.currentApiKey;
    if (key.trim().isEmpty) {
      apiKeyStatus.value = ApiKeyStatus.invalid;
      return false;
    }

    if (!force && apiKeyStatus.value == ApiKeyStatus.valid) {
      return true;
    }

    apiKeyStatus.value = ApiKeyStatus.validating;
    final validator = apiKeyValidator ?? GeminiService.validateApiKey;
    final valid = await validator(key);
    apiKeyStatus.value = valid ? ApiKeyStatus.valid : ApiKeyStatus.invalid;
    return valid;
  }

  String _getString(String Function() selector, String fallback) {
    try {
      return selector();
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> saveApiKey(String rawKey) async {
    final trimmedKey = rawKey.trim();
    if (trimmedKey.isEmpty) {
      _showNotification(
        _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
        _getString(
          () => S.current.invalidApiKeyFormat,
          'Please enter a valid API key',
        ),
        color: Colors.redAccent,
      );
      return false;
    }

    isLoading.value = true;
    isValidating.value = true;

    // 1. Verify key before persisting
    final validator = apiKeyValidator ?? GeminiService.validateApiKey;
    final isValid = await validator(trimmedKey);

    if (!isValid) {
      isLoading.value = false;
      isValidating.value = false;
      apiKeyStatus.value = ApiKeyStatus.invalid;
      _showNotification(
        _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
        _getString(
          () => S.current.apiKeyInvalidError,
          'The API key is invalid or has expired. Please verify and try again.',
        ),
        color: Colors.redAccent,
      );
      return false;
    }

    // 2. Persist key
    final result = await saveCustomApiKeyUseCase(trimmedKey);
    isLoading.value = false;
    isValidating.value = false;

    return result.fold(
      (failure) {
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          failure.message,
          color: Colors.redAccent,
        );
        return false;
      },
      (_) {
        customApiKey.value = trimmedKey;
        isCustom.value = true;
        apiKeyStatus.value = ApiKeyStatus.valid;
        keyInputController.text = trimmedKey;
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          _getString(
            () => S.current.apiKeySavedSuccess,
            'API key saved successfully',
          ),
          color: Colors.green,
        );
        return true;
      },
    );
  }

  Future<void> clearApiKey() async {
    isLoading.value = true;
    final result = await clearCustomApiKeyUseCase();
    isLoading.value = false;

    result.fold(
      (failure) {
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          failure.message,
          color: Colors.redAccent,
        );
      },
      (_) {
        customApiKey.value = '';
        isCustom.value = false;
        keyInputController.text = '';
        checkKeyHealth(force: true);
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          _getString(
            () => S.current.apiKeyClearedSuccess,
            'Custom API key removed',
          ),
          color: Colors.orange,
        );
      },
    );
  }

  String get maskedKey {
    final key = customApiKey.value;
    if (key.isEmpty) return '';
    if (key.length <= 10) return '••••••••';
    return '${key.substring(0, 6)}...${key.substring(key.length - 4)}';
  }
}
