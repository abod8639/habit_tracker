import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// A reusable, Material 3 compliant confirmation dialog for the application.
/// Ensures consistent design language, semantic theming, and adheres to the DRY principle.
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? confirmText;
  final String? cancelText;
  final bool isDestructive;
  final Widget? customContent;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.confirmText,
    this.cancelText,
    this.isDestructive = false,
    this.customContent,
    this.onConfirm,
    this.onCancel,
  });

  /// Displays the confirmation dialog and returns true if confirmed, false otherwise.
  static Future<bool?> show({
    BuildContext? context,
    required String title,
    required String message,
    IconData? icon,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    Widget? customContent,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final targetContext = context ?? Get.overlayContext ?? Get.context;
    if (targetContext == null) return Future.value(false);

    return showDialog<bool>(
      context: targetContext,
      builder: (dialogContext) => AppConfirmationDialog(
        title: title,
        message: message,
        icon: icon,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        customContent: customContent,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;
    final primaryColor = isDestructive ? themeColors.error : themeColors.primary;
    final onPrimaryColor = isDestructive ? themeColors.onError : themeColors.onPrimary;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      icon: icon != null
          ? Icon(
              icon,
              size: 28,
              color: primaryColor,
            )
          : null,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: themeColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (customContent != null) ...[
            const SizedBox(height: 12),
            customContent!,
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: Text(cancelText ?? S.of(context).cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimaryColor,
          ),
          child: Text(
            confirmText ??
                (isDestructive
                    ? S.of(context).delete
                    : S.of(context).save),
          ),
        ),
      ],
    );
  }
}
