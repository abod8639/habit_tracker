import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Presentation dialog for user logout confirmation.
class LogoutDialog {
  LogoutDialog._();

  /// Displays a confirmation dialog before signing the user out.
  static Future<void> show(
    BuildContext context,
    AuthController authController,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: S.current.logoutConfirmTitle,
      message: S.current.logoutConfirmMessage,
      icon: Icons.logout_rounded,
      confirmText: S.current.logout,
      cancelText: S.current.cancel,
      isDestructive: true,
    );

    if (confirmed == true) {
      await authController.signOut();
    }
  }
}
