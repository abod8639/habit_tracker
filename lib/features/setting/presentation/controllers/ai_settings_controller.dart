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
  late final TextEditingController keyInputController;

  @override
  void onInit() {
    super.onInit();
    keyInputController = TextEditingController();
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

  Future<bool> saveApiKey(String rawKey) async {
    final trimmedKey = rawKey.trim();
    if (trimmedKey.isEmpty) {
      Get.snackbar(
        S.current.aiApiKeyTitle,
        S.current.invalidApiKeyFormat,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    isLoading.value = true;
    final result = await saveCustomApiKeyUseCase(trimmedKey);
    isLoading.value = false;

    return result.fold(
      (failure) {
        Get.snackbar(
          S.current.aiApiKeyTitle,
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      },
      (_) {
        customApiKey.value = trimmedKey;
        isCustom.value = true;
        keyInputController.text = trimmedKey;
        Get.snackbar(
          S.current.aiApiKeyTitle,
          S.current.apiKeySavedSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
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
        Get.snackbar(
          S.current.aiApiKeyTitle,
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      },
      (_) {
        customApiKey.value = '';
        isCustom.value = false;
        keyInputController.text = '';
        Get.snackbar(
          S.current.aiApiKeyTitle,
          S.current.apiKeyClearedSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withValues(alpha: 0.8),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
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
