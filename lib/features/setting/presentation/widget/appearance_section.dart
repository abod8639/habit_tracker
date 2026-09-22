import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/lang_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_lang.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/utils/restart_widget.dart';
import 'package:habit_tracker/features/theme/presentation/pages/theme_page.dart';

Widget buildAppearanceSection(AnimationController animationController) {
  final langController = Get.find<LangController>();
  return Builder(
    builder: (context) {
      return Column(
        children: [
          AnimatedSettingTile(
            animationController: animationController,
            index: 5,
            icon: Icons.palette_rounded,
            title: S.current.themepage,
            subtitle: S.current.changeAppTheme,
            onTap: () => Get.to(
              () => const ThemePage(),
              transition: Transition.rightToLeftWithFade,
              duration: const Duration(milliseconds: 400),
            ),
          ),
          Obx(
            () => buildAnimatedSettingLang(
              context,
              icon: Icons.language_rounded,
              currentValue: langController.language.value,
              entries: const [
                DropdownMenuEntry(value: "sys", label: "  System Language  "),
                DropdownMenuEntry(value: "ar", label: "  العربية "),
                DropdownMenuEntry(value: "en", label: "  English  "),
              ],
              onChanged: (value) async {
                if (value != null) {
                  await langController.changeLanguage(value);
                  if (context.mounted) {
                    RestartWidget.restartApp(context);
                  }
                }
              },
              textColor: Theme.of(context).colorScheme.onSurface,
              animationController: animationController,
              index: 6,
            ),
          ),
        ],
      );
    },
  );
}
