import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/domain/usecases/get_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/save_custom_api_key_usecase.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_custom_api_key_usecase.dart';
import 'package:habit_tracker/generated/l10n.dart';

class AiSettingsController extends GetxController {
  final GetCustomApiKeyUseCase getCustomApiKeyUseCase;
  final SaveCustomApiKeyUseCase saveCustomApiKeyUseCase;
  final ClearCustomApiKeyUseCase clearCustomApiKeyUseCase;

  AiSettingsController({
    required this.getCustomApiKeyUseCase,
    required this.saveCustomApiKeyUseCase,
    required this.clearCustomApiKeyUseCase,
  });

  final RxString customApiKey = ''.obs;
  final RxBool isCustom = false.obs;
  final RxBool obscureText = true.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController keyInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadApiKey();
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
        _getString(() => S.current.invalidApiKeyFormat, 'Please enter a valid API key'),
        color: Colors.redAccent,
      );
      return false;
    }

    isLoading.value = true;
    final result = await saveCustomApiKeyUseCase(trimmedKey);
    isLoading.value = false;

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
        keyInputController.text = trimmedKey;
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          _getString(() => S.current.apiKeySavedSuccess, 'API key saved successfully'),
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
        _showNotification(
          _getString(() => S.current.aiApiKeyTitle, 'AI API Key'),
          _getString(() => S.current.apiKeyClearedSuccess, 'Custom API key removed'),
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
