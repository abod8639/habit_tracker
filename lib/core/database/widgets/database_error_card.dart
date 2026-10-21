import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/database/database_provider.dart';

/// Presentation Fallback Widget that uses AsyncValue.when to render an elegant error UI
/// with a retry mechanism if local database issues occur, avoiding screen crashes.
class DatabaseErrorCard extends ConsumerWidget {
  final Widget? child;
  final VoidCallback? onRetry;

  const DatabaseErrorCard({
    super.key,
    this.child,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbStatus = ref.watch(databaseStatusProvider);
    final theme = Theme.of(context);

    return dbStatus.when(
      data: (_) => child ?? const SizedBox.shrink(),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
      error: (error, _) {
        final message = error.toString().replaceFirst('Exception: ', '');
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storage_rounded,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 10),
                Text(
                  'Database Error',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.tonalIcon(
                  onPressed: () {
                    ref.read(databaseStatusProvider.notifier).checkHealth();
                    onRetry?.call();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry Connection'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
