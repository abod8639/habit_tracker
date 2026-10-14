import 'package:flutter/material.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Reusable error view component for displaying errors with a retry action.
class ErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.errorMessage,
    this.onRetry,
  });


  @override
  Widget build(BuildContext context) {
    debugPrint(errorMessage);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).somethingWentWrong,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(S.of(context).tryAgain),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Helper function to build error screen (for backward compatibility)
Widget buildErrorScreen({String? errorMessage, VoidCallback? onRetry}) {
  return ErrorView(
    errorMessage: errorMessage,
    onRetry: onRetry,
  );
}
