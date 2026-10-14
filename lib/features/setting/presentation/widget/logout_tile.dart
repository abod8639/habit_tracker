import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/features/auth/presentation/dialogs/logout_dialog.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class LogoutTile extends ConsumerWidget {
  final AnimationController animationController;

  const LogoutTile({super.key, required this.animationController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
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
      onTap: () => LogoutDialog.show(context, ref),
    );
  }
}

Widget buildLogoutTile(AnimationController animationController) {
  return LogoutTile(animationController: animationController);
}
