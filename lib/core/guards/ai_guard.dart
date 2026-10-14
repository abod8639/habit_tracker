import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/generated/l10n.dart';

typedef AiKeyConfigCallback = Future<void> Function(BuildContext context);
typedef AiKeyHealthCheckCallback = Future<bool> Function();

/// Guard utility to protect AI feature entry points.
/// Adheres to Clean Architecture and Dependency Inversion Principle (DIP).
class AiGuard {
  AiGuard._();

  static AiKeyConfigCallback? _configHandler;
  static AiKeyHealthCheckCallback? _healthCheckHandler;

  /// Registers a feature-level callback to configure the AI API key.
  static void registerConfigHandler(AiKeyConfigCallback handler) {
    _configHandler = handler;
  }

  /// Registers a feature-level health check callback.
  static void registerHealthCheckHandler(AiKeyHealthCheckCallback handler) {
    _healthCheckHandler = handler;
  }

  /// Verifies if the AI API key is configured and available.
  /// If valid, executes [onValid] immediately without blocking navigation on slow network calls.
  /// If invalid or missing, prevents navigation and displays a localized dialog.
  static Future<bool> protect(
    BuildContext context, {
    required VoidCallback onValid,
  }) async {
    final bool isValid = _healthCheckHandler != null
        ? await _healthCheckHandler!()
        : GeminiService.hasValidKey;

    if (isValid) {
      onValid();
      return true;
    }

    if (!context.mounted) return false;

    // Display localized warning dialog explaining that the key is missing or invalid
    final s = S.of(context);

    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: s.aiServiceUnavailableTitle,
      message: s.apiKeyRequiredDialogMessage,
      icon: Icons.key_off_rounded,
      confirmText: s.configureApiKey,
      cancelText: s.cancel,
    );

    if (confirmed == true && context.mounted) {
      if (_configHandler != null) {
        await _configHandler!(context);
      }
    }

    return false;
  }
}
