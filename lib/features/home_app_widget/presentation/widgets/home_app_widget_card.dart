import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/home_app_widget/home_app_widget_view.dart';
import '../providers/home_app_widget_providers.dart';

/// Consumer widget that observes [homeAppWidgetNotifierProvider] with [AsyncValue.when]
/// to render an unshakeable UI with dedicated fallback states and zero-crash guarantee.
class HomeAppWidgetCard extends ConsumerWidget {
  final bool asSliver;
  final EdgeInsetsGeometry? sliverPadding;
  final bool showSnackBarOnError;

  const HomeAppWidgetCard({
    super.key,
    this.showSnackBarOnError = false,
  }) : asSliver = false,
       sliverPadding = null;

  const HomeAppWidgetCard.sliver({
    super.key,
    this.sliverPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    this.showSnackBarOnError = false,
  }) : asSliver = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Optional transient failure listener for SnackBar notifications
    if (showSnackBarOnError) {
      ref.listen<Failure?>(homeAppWidgetFailureProvider, (previous, next) {
        if (next != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(next.toMessage()),
              backgroundColor: theme.colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: theme.colorScheme.onError,
                onPressed: () {
                  ref.read(homeAppWidgetNotifierProvider.notifier).retry();
                },
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      });
    }

    final asyncState = ref.watch(homeAppWidgetNotifierProvider);

    final content = asyncState.when(
      loading: () => _buildLoadingSkeleton(context, isDark),
      error: (error, _) => HomeAppWidgetErrorCard(
        error: error,
        onRetry: () {
          ref.read(homeAppWidgetNotifierProvider.notifier).retry();
        },
      ),
      data: (data) => HomeAppWidgetView(
        habits: data.uncompletedHabits,
        heatmapDatasets: data.heatmapDatasets,
        isDark: isDark,
        primaryColor: theme.colorScheme.primary,
      ),
    );

    if (asSliver) {
      return SliverToBoxAdapter(
        child: Padding(
          padding:
              sliverPadding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Center(child: content),
        ),
      );
    }

    return content;
  }

  Widget _buildLoadingSkeleton(BuildContext context, bool isDark) {
    return Container(
      width: 360,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
      ),
      child: SoftCard(
        borderRadius: 22,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
