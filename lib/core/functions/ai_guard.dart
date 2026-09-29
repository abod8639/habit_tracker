import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/ai_settings_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/features/setting/presentation/widget/ai_api_key_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Guard utility to protect AI feature entry points.
/// Ensures a valid and operational Gemini API key exists before granting access.
class AiGuard {
  AiGuard._();

  /// Resolves the [AiSettingsController] safely, ensuring dependencies are loaded.
  static AiSettingsController? _getController() {
    if (Get.isRegistered<AiSettingsController>()) {
      return Get.find<AiSettingsController>();
    }
    try {
      SettingBinding().dependencies();
      if (Get.isRegistered<AiSettingsController>()) {
        return Get.find<AiSettingsController>();
      }
    } catch (_) {}
    return null;
  }

  /// Verifies if the AI API key is valid and working.
  /// If valid, executes [onValid].
  /// If invalid or missing, prevents navigation and displays a localized
  /// Neumorphic dialog informing the user that an API key is required.
  static Future<bool> protect(
    BuildContext context, {
    required VoidCallback onValid,
  }) async {
    final controller = _getController();
    bool isValid = false;

    if (controller != null) {
      if (controller.apiKeyStatus.value == ApiKeyStatus.valid) {
        isValid = true;
      } else if (controller.apiKeyStatus.value == ApiKeyStatus.unknown) {
        isValid = await controller.checkKeyHealth();
      } else {
        isValid = await controller.checkKeyHealth();
      }
    } else {
      isValid = await GeminiService.isCurrentKeyValid();
    }

    if (isValid) {
      onValid();
      return true;
    }

    // Display localized warning dialog explaining that the key is missing or invalid
    final targetContext = context.mounted ? context : (Get.context ?? context);
    final s = S.of(targetContext);

    final confirmed = await AppConfirmationDialog.show(
      context: targetContext,
      title: s.aiServiceUnavailableTitle,
      message: s.apiKeyRequiredDialogMessage,
      icon: Icons.key_off_rounded,
      confirmText: s.configureApiKey,
      cancelText: s.cancel,
    );

    if (confirmed == true && targetContext.mounted) {
      final activeController = controller ?? _getController();
      if (activeController != null) {
        AiApiKeyDialog.show(targetContext, activeController);
      }
    }

    return false;
  }
}
