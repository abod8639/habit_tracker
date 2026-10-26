import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Reusable clean Neumorphic error view component for displaying errors with a retry action.
class ErrorView extends StatelessWidget {
  final String? errorMessage;
  final String? title;
  final VoidCallback? onRetry;
  final bool asCard;

  const ErrorView({
    super.key,
    this.errorMessage,
    this.title,
    this.onRetry,
    this.asCard = true,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(errorMessage);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.error.withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.cloud_off_rounded,
            size: 34,
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title ??
              (isArabic
                  ? 'حدث خطأ غير متوقع'
                  : S.of(context).somethingWentWrong),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        if (onRetry != null) ...[
          const SizedBox(height: 20),
          NeumorphicButton(
            text: S.of(context).tryAgain,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            width: 160,
            height: 46,
            borderRadius: AppRadius.lgRadius,
          ),
        ],
      ],
    );

    if (!asCard) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: content,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: ThemeUtils.subtleBorderColor(isDark),
              width: 1.2,
            ),
            boxShadow: AppShadows.softCard(isDark: isDark),
          ),
          child: content,
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
