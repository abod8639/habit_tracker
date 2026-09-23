import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

Future<void> showLogoutDialog(
  AuthController authController, [
  BuildContext? context,
]) async {
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
