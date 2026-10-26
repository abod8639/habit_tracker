import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/providers/time_validation_provider.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Full-screen blocking guard displayed when device date/time manipulation is detected.
class InvalidTimeScreen extends ConsumerStatefulWidget {
  final DateTime? deviceTime;

  const InvalidTimeScreen({
    super.key,
    this.deviceTime,
  });

  @override
  ConsumerState<InvalidTimeScreen> createState() => _InvalidTimeScreenState();
}

class _InvalidTimeScreenState extends ConsumerState<InvalidTimeScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    try {
      final result = await ref
          .read(timeValidationNotifierProvider.notifier)
          .validate();

      if (!mounted) return;

      if (result.isTampered) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    S.of(context).invalidTimeStillIncorrect,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mdRadius,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final validationState = ref.watch(timeValidationNotifierProvider);
    final currentTime =
        validationState.deviceTime ?? widget.deviceTime ?? DateTime.now();

    final formattedDeviceTime = DateFormat(
      'yyyy-MM-dd • hh:mm a',
      'en',
    ).format(currentTime);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Warning / Clock Icon
                  PageEntranceTransition(
                    index: 0,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.softCard(isDark: isDark),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(
                            alpha: 0.35,
                          ),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          Positioned(
                            right: 18,
                            bottom: 18,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_rounded,
                                size: 22,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  PageEntranceTransition(
                    index: 1,
                    child: Text(
                      S.of(context).invalidTimeTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Detailed Description
                  PageEntranceTransition(
                    index: 2,
                    child: Text(
                      S.of(context).invalidTimeDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.72,
                        ),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current device time badge
                  PageEntranceTransition(
                    index: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppRadius.mdRadius,
                        boxShadow: AppShadows.softCard(isDark: isDark),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smartphone_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              S
                                  .of(context)
                                  .invalidTimeDeviceTime(formattedDeviceTime),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Retry Neumorphic Button
                  PageEntranceTransition(
                    index: 4,
                    child: _isRetrying || validationState.isValidating
                        ? Container(
                            height: 48,
                            width: 170,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: AppRadius.lgRadius,
                              boxShadow: AppShadows.softCard(isDark: isDark),
                            ),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : NeumorphicButton(
                            text: S.of(context).tryAgain,
                            icon: Icons.refresh_rounded,
                            onPressed: _handleRetry,
                            width: 170,
                            height: 48,
                            borderRadius: AppRadius.lgRadius,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
