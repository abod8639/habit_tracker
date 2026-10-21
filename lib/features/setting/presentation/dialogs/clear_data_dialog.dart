import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/core/utils/restart_widget.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialog for wiping all app data and restarting.
class ClearDataDialog {
  ClearDataDialog._();

  /// Shows confirmation, performs complete data wipe via [ClearAllDataUseCase],
  /// and restarts the application.
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final bool? shouldClear = await _showConfirmationDialog(context);

    if (shouldClear != true || !context.mounted) {
      return;
    }

    try {
      _showLoadingDialog(context);

      final clearAllDataUseCase = ref.read(clearAllDataUseCaseProvider);
      final result = await clearAllDataUseCase();

      // Close loading dialog
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      result.fold(
        (failure) {
          if (context.mounted) _showErrorSnackBar(context, failure.toMessage());
        },
        (_) async {
          if (context.mounted) _showSuccessSnackBar(context);
          await Future.delayed(const Duration(milliseconds: 1000));
          if (context.mounted) {
            RestartWidget.restartApp(context);
          }
        },
      );
    } catch (e, stack) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        final failure = NetworkErrorHandler.handle(e, stack);
        _showErrorSnackBar(context, failure.toMessage());
      }
    }
  }

  static Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return AppConfirmationDialog.show(
      context: context,
      title: S.of(context).clearAllData,
      message: S.of(context).clearAllDataConfirm,
      icon: Icons.delete_forever_rounded,
      confirmText: S.of(context).delete,
      cancelText: S.of(context).cancel,
      isDestructive: true,
    );
  }

  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(S.of(context).clearingData),
            ],
          ),
        );
      },
    );
  }

  static void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).dataClearedSuccess),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).failedToClearData(message)),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}
