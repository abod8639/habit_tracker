import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

PreferredSizeWidget myAppBar({
  required String title,
  required BuildContext context,
  List<Widget>? actions,
}) {
  ThemeData theme = Theme.of(context);
  return AppBar(
    backgroundColor: theme.scaffoldBackgroundColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    leadingWidth: 56,
    leading: Center(
      child: NeumorphicIconButton.square(
        size: 40,
        iconSize: 18,
        icon: Icons.arrow_back_ios_new_rounded,
        accentColor: theme.colorScheme.onSurface,
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.back();
          }
        },
      ),
    ),
    title: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.3,
        shadows: AppShadows.bloom(
          isDark: theme.brightness == Brightness.dark,
          color: theme.colorScheme.onPrimary,
          blur: 2,
          spread: 0.2,
        ),
      ),
    ),
    centerTitle: true,
    actions: actions,
  );
}
