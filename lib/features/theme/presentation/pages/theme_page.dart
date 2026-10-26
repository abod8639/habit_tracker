import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';
import 'package:habit_tracker/core/components/page_entrance_transition.dart';
import 'package:habit_tracker/core/components/section_title.dart';
import 'package:habit_tracker/core/error/failures.dart';
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
    // Listen to theme failures and show floating SnackBar with Retry action
    ref.listen<Failure?>(themeFailureProvider, (previous, next) {
      if (next != null) {
        final s = S.maybeOf(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(next.toMessage()),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: s?.tryAgain ?? 'Retry',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).retry();
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final currentTheme = ref.watch(
      themeNotifierProvider.select((state) => state.currentTheme),
    );
    final availableThemes = themeColors.keys.toList();

    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (KeyEvent event) => AppKeyboardShortcuts.handlePageKey(event),
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            MySliverAppBar(
              title: S.current.themepagetitle,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 12.0),
              sliver: SliverToBoxAdapter(
                child: PageEntranceTransition(
                  index: 0,
                  child: SectionTitle(title: S.current.themepage),
                ),
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
                  final colors = themeColors[themeName] ??
                      themeColors[ThemeNotifier.defaultTheme]!;
                  final isSelected = currentTheme == themeName;

                  return PageEntranceTransition(
                    index: index + 1,
                    child: ThemeCard(
                      key: ValueKey(themeName),
                      themeName: themeName,
                      colors: colors,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(themeNotifierProvider.notifier)
                          .changeCustomTheme(themeName),
                    ),
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
