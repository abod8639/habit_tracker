import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/section_title.dart';
import 'package:habit_tracker/core/utils/keyboard_shortcuts.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import 'package:habit_tracker/generated/l10n.dart';
import '../providers/theme_providers.dart';
import '../widgets/theme_card.dart';

class ThemePage extends ConsumerStatefulWidget {
  const ThemePage({super.key});

  @override
  ConsumerState<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends ConsumerState<ThemePage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(
      themeNotifierProvider.select((state) => state.currentTheme),
    );
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final availableThemes = themeColors.keys.toList();

    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) => AppKeyboardShortcuts.handlePageKey(event),
      child: Scaffold(
        appBar: myAppBar(
          context: context,
          title: S.current.themepagetitle,
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
                itemCount: availableThemes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final themeName = availableThemes[index];
                  final colors = themeColors[themeName]!;
                  final isSelected = currentTheme == themeName;

                  return ThemeCard(
                    key: ValueKey(themeName),
                    themeName: themeName,
                    colors: colors,
                    isSelected: isSelected,
                    onTap: () => themeNotifier.changeCustomTheme(themeName),
                  );
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
