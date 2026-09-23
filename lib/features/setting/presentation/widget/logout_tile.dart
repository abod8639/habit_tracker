import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/show_logout_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LogoutTile extends StatelessWidget {
  final AnimationController animationController;

  const LogoutTile({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final themeColors = Theme.of(context).colorScheme;

    return AnimatedSettingTile(
      animationController: animationController,
      index: 2,
      icon: Icons.logout_rounded,
      title: S.current.logout,
      subtitle: S.current.logoutFromAccount,
      textColor: themeColors.error,
      onTap: () => showLogoutDialog(authController, context),
    );
  }
}

Widget buildLogoutTile(AnimationController animationController) {
  return LogoutTile(animationController: animationController);
}
