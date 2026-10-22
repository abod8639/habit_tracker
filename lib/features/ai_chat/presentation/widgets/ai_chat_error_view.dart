import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';

/// Clean Architecture Component: Delegating error fallback view to the unified [ErrorView].
class AiChatErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const AiChatErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return ErrorView(
      title: isArabic ? 'تعذر تحميل المحادثة' : 'Failed to load conversation',
      errorMessage: errorMessage,
      onRetry: onRetry,
    );
  }
}

