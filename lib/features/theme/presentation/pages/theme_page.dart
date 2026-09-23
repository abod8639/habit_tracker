import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/functions/keyboard_shortcuts.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_list.dart';
import '../widgets/section_title.dart';
import '../controllers/theme_controller.dart';

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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: S.current.themepage),
              const SizedBox(height: 12),

              // Theme Mode Selector
              // Obx(() => Center(
              //   child: SegmentedButton<ThemeMode>(
              //     segments: const [
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.system,
              //         label: Text('System'),
              //         icon: Icon(Icons.brightness_auto),
              //       ),
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.light,
              //         label: Text('Light'),
              //         icon: Icon(Icons.light_mode),
              //       ),
              //       ButtonSegment<ThemeMode>(
              //         value: ThemeMode.dark,
              //         label: Text('Dark'),
              //         icon: Icon(Icons.dark_mode),
              //       ),
              //     ],
              //     selected: {themeController.themeMode.value},
              //     onSelectionChanged: (Set<ThemeMode> selection) {
              //       themeController.changeThemeMode(selection.first);
              //     },
              //     showSelectedIcon: false,
              //     style: SegmentedButton.styleFrom(
              //       selectedBackgroundColor: colorScheme.primary,
              //       selectedForegroundColor: colorScheme.onPrimary,
              //     ),
              //   ),
              // )),

              // const SizedBox(height: 32),
              // const SectionTitle(title: 'Choose Theme'),
              // const SizedBox(height: 16),

              // Themes Grid
              Obx(() {
                final currentThemeName = themeController.currentTheme.value;
                final availableThemes = themeController.availableThemes;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: availableThemes.length,

                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final themeName = availableThemes[index];
                    final isSelected = currentThemeName == themeName;
                    final colors = themeColors[themeName]!;

                    return ThemeCard(
                      themeName: themeName,
                      colors: colors,
                      isSelected: isSelected,
                      onTap: () => themeController.changeCustomTheme(themeName),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  final String themeName;
  final Map<String, Color> colors;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.themeName,
    required this.colors,
    required this.isSelected,
    required this.onTap,
  });

  String _formatThemeName(String name) {
    return name.split('_').map((word) => word.capitalizeFirst!).join(' ');
  }

  Map<DateTime, int> _generateDummyData() {
    final Map<DateTime, int> data = {};
    final random = Random();
    final today = DateTime.now();

    for (int i = 0; i < 60; i++) {
      if (random.nextDouble() > 0.3) {
        final date = today.subtract(Duration(days: i));
        data[DateTime(date.year, date.month, date.day)] =
            random.nextInt(10) + 1;
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final primary = colors['primary']!;
    final surface = colors['surface']!;

    // Derived HeatMap colorsets from primary
    final Map<int, Color> activeColorSet = {
      1: primary.withValues(alpha: 0.2),
      3: primary.withValues(alpha: 0.4),
      5: primary.withValues(alpha: 0.6),
      7: primary.withValues(alpha: 0.8),
      10: primary,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primary : primary.withValues(alpha: 0.1),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primary.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: HeatMap(
                  startDate: DateTime.now().subtract(const Duration(days: 55)),
                  endDate: DateTime.now(),
                  datasets: _generateDummyData(),
                  colorMode: ColorMode.color,
                  defaultColor: Colors.grey.withValues(alpha: 0.1),
                  textColor: Colors.grey.withValues(alpha: 0.6),
                  showColorTip: false,
                  showText: false,
                  scrollable: false,
                  size: 16,
                  colorsets: activeColorSet,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  border: Border(
                    top: BorderSide(
                      color: primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatThemeName(themeName),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSelected
                                ? S.of(context).currentlySelected
                                : S.of(context).tapToApply,
                            style: TextStyle(
                              fontSize: 12,
                              color: primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: primary, size: 28)
                    else
                      Row(
                        children: [
                          _colorIndicator(colors['primary']!),
                          _colorIndicator(colors['secondary']!),
                          _colorIndicator(colors['surface']!),
                          _colorIndicator(colors['background']!),
                          _colorIndicator(colors['onPrimary']!),
                          _colorIndicator(colors['onSecondary']!),
                          _colorIndicator(colors['error']!),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorIndicator(Color color) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }
}
