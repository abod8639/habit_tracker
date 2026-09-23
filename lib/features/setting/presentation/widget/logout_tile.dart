import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/show_logout_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

Widget buildLogoutTile(AnimationController animationController) {
  final authController = Get.find<AuthController>();
  final user = authController.currentUser;
  if (user != null) {
    return AnimatedSettingTile(
      animationController: animationController,
      index: 2,
    icon: Icons.logout_rounded,
    title: S.current.logout,
    subtitle: S.current.logoutFromAccount,
    textColor: Colors.red,
    onTap: () => showLogoutDialog(authController),
  );
  }else{
    return SizedBox.shrink();
  }
}
