import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/section_title.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../controllers/theme_controller.dart';
import '../widgets/theme_card.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyboardShortCutsPages(event),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            color: colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            S.current.themepagetitle,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 12.0),
              sliver: SliverToBoxAdapter(
                child: SectionTitle(title: S.current.themepage),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList.separated(
                itemCount: themeController.availableThemes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final themeName = themeController.availableThemes[index];
                  final colors = themeColors[themeName]!;

                  return Obx(() {
                    final isSelected =
                        themeController.currentTheme.value == themeName;
                    return ThemeCard(
                      themeName: themeName,
                      colors: colors,
                      isSelected: isSelected,
                      onTap: () => themeController.changeCustomTheme(themeName),
                    );
                  });
                },
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
