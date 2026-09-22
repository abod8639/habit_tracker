import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/domain/usecases/clear_all_data_usecase.dart';
import 'package:habit_tracker/core/utils/restart_widget.dart';

/// Safe function to clear data and restart app
Future<void> clearAppDataAndRestart(BuildContext context) async {
  bool? shouldClear = await _showConfirmationDialog(context);

  if (shouldClear != true || !context.mounted) {
    return; // User cancelled or context unmounted
  }

  try {
    _showLoadingDialog(context);

    final clearAllDataUseCase = Get.find<ClearAllDataUseCase>();
    final result = await clearAllDataUseCase();

    // Close loading dialog
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    result.fold(
      (failure) {
        if (context.mounted) _showErrorSnackBar(context, failure.message);
      },
      (_) async {
        if (context.mounted) _showSuccessSnackBar(context);
        await Future.delayed(const Duration(milliseconds: 1000));
        if (context.mounted) {
          RestartWidget.restartApp(context);
        }
      },
    );
  } catch (e) {
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    if (context.mounted) {
      _showErrorSnackBar(context, e.toString());
    }
  }
}

Future<bool?> _showConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all habits and settings? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      );
    },
  );
}

void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Clearing data...'),
          ],
        ),
      );
    },
  );
}

void _showSuccessSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Data cleared successfully! Restarting app...'),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.green,
    ),
  );
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to clear data: $message'),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    ),
  );
}
