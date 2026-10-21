import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Tactile, Neumorphic error card presentation widget for the Home Screen Widget snapshot.
/// Formats errors using [Failure.toMessage] and provides a retry callback without freezing or crashing the screen.
class HomeAppWidgetErrorCard extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final double width;

  const HomeAppWidgetErrorCard({
    super.key,
    required this.error,
    this.onRetry,
    this.width = 360,
  });

  String _resolveErrorMessage(BuildContext context) {
    if (error is Failure) {
      return (error as Failure).toMessage();
    }
    if (error is String) {
      return error as String;
    }
    if (error != null) {
      return error.toString();
    }
    final s = S.maybeOf(context);
    return s?.somethingWentWrong ?? 'An unexpected error occurred';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final s = S.maybeOf(context);
    final errorMessage = _resolveErrorMessage(context);

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 140),
      child: SoftCard(
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  s?.somethingWentWrong ?? 'Widget Sync Failed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E2024),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.3,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 32,
                child: TextButton.icon(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    s?.tryAgain ?? 'Retry',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
